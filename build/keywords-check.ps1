<#
.SYNOPSIS
   Re-scrape the hugoDocs function reference and report how it differs from the committed
   extraction in hugen/_hugodocs.

.DESCRIPTION
   Without -Ref: builds at the hugoDocs version pinned in hugen/hugodocs/hugo.toml, so a
   difference means the pin was bumped without refreshing the extraction. `-Update`
   adopts the fresh scrape.

   With -Ref <branch|tag|version>: builds against that ref instead to see how far upstream
   has moved beyond the pin. The ref goes in through a generated config overlay and is
   resolved by Hugo to a concrete pseudo-version, which is always reported back
   (.ResolvedVersion). Without -Update, the pin is left untouched and go.mod / go.sum /
   hugo.direct.sum are restored afterwards. With -Update, the resolved version is written
   as the new pin in hugo.toml instead of being restored, and the snapshot is refreshed -
   i.e. -Ref -Update adopts that ref as the new pin.

   Reporting only unless -Update is given; never fails a build. Called by build.ps1 and
   directly by CI, so keep it POSIX-path clean.

.OUTPUTS
   The PSCustomObject returned by build/keywords-diff.ps1, plus a ResolvedVersion property
   when -Ref was given.

.EXAMPLE
   ./build/keywords-check.ps1 -Update

.EXAMPLE
   ./build/keywords-check.ps1 -Ref master -Notice

.EXAMPLE
   ./build/keywords-check.ps1 -Ref master -Update
#>
[CmdLetBinding()]
param(
   # the Hugo module doing the scraping (default: <repo>/hugen/hugodocs)
   [Parameter(Mandatory = $false)][string]$SourceDir,
   # the committed snapshot (default: <repo>/hugen/_hugodocs)
   [Parameter(Mandatory = $false)][string]$SnapshotDir,
   # where the fresh extraction is written (default: <repo>/work/hugodocs[-<ref>])
   [Parameter(Mandatory = $false)][string]$TargetDir,
   # hugoDocs branch/tag/version to compare against instead of the pinned one
   [Parameter(Mandatory = $false)][string]$Ref,
   # adopt the fresh extraction as the committed snapshot; combined with -Ref, also pins
   # hugo.toml to the resolved version instead of restoring it
   [Parameter(Mandatory = $false)][switch]$Update,
   # emit a GitHub Actions ::notice:: when something changed
   [Parameter(Mandatory = $false)][switch]$Notice,
   # skip appending the Markdown table to $env:GITHUB_STEP_SUMMARY - the caller is
   # composing its own concise annotation and pointing at the step log instead
   [Parameter(Mandatory = $false)][switch]$NoSummary
)

$ErrorActionPreference = 'Stop'

# build.ps1 already imports this, but CI calls this script directly (not via build.ps1),
# so it has to be self-sufficient to get the `exec` helper
Import-Module (Join-Path $PSScriptRoot 'lib/utilities.ps1')

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $SourceDir) { $SourceDir = Join-Path $repoRoot 'hugen/hugodocs' }
if (-not $SnapshotDir) { $SnapshotDir = Join-Path $repoRoot 'hugen/_hugodocs' }
if (-not $TargetDir) {
   $TargetDir = Join-Path $repoRoot ($Ref ? 'work/hugodocs-latest' : 'work/hugodocs')
}
if (-not (Test-Path -PathType Container $SourceDir)) { throw "No such directory: $SourceDir" }
if (Test-Path -PathType Container $TargetDir) { Remove-Item -Recurse -Force $TargetDir }
[void](New-Item -ItemType Directory -Force -Path $TargetDir)
[void](New-Item -ItemType Directory -Force -Path $SnapshotDir)

$hugoArgs = @('--source', $SourceDir, '--destination', $TargetDir)
$moduleState = @{}

if ($Ref) {
   # patch the real config rather than keep a second copy of the [module] block
   $configFile = Join-Path $SourceDir 'hugo.toml'
   $config = Get-Content -Raw -Path $configFile
   $patched = [regex]::Replace($config, "(?m)^(\s*version\s*=\s*)'[^']*'", "`${1}'$Ref'")
   if ($patched -eq $config) {
      throw "No module import version found in $configFile - cannot build against '$Ref'"
   }
   $overlay = Join-Path $TargetDir 'hugo.overlay.toml'
   Set-Content -Encoding utf8 -Path $overlay -Value $patched
   # right-most config file wins, so the overlay replaces the pinned module import
   $hugoArgs += @('--config', "'hugo.toml,$overlay'")

   # Hugo rewrites these for the version it resolves -- restore them afterwards
   foreach ($name in @('go.mod', 'go.sum', 'hugo.direct.sum')) {
      $file = Join-Path $SourceDir $name
      if (Test-Path -PathType Leaf $file) { $moduleState[$file] = [System.IO.File]::ReadAllBytes($file) }
   }
}

$resolvedVersion = $null
try {
   # voided so hugo's own console lines don't leak into this script's captured return
   # value when a caller does `$result = & keywords-check.ps1 ...`
   [void](exec hugo @hugoArgs)
   if ($Ref) {
      # a plain build only rewrites hugo.direct.sum with the concrete pseudo-version it
      # resolved $Ref to -- go.mod/go.sum are left alone unless you run `hugo mod get`
      $directSumFile = Join-Path $SourceDir 'hugo.direct.sum'
      $directSumMatch = Select-String -Path $directSumFile -Pattern 'github\.com/gohugoio/hugoDocs\s+(\S+)' -ErrorAction SilentlyContinue
      if ($directSumMatch) { $resolvedVersion = $directSumMatch.Matches[0].Groups[1].Value }
   }
} finally {
   $adopting = $Ref -and $Update -and $resolvedVersion
   if ($adopting) {
      # pin hugo.toml to the resolved version...
      $liveConfig = Get-Content -Raw -Path $configFile
      $newConfig = [regex]::Replace($liveConfig, "(?m)^(\s*version\s*=\s*)'[^']*'", "`${1}'$resolvedVersion'")
      Set-Content -Encoding utf8 -NoNewline -Path $configFile -Value $newConfig
      # ...and let Hugo properly sync go.mod/go.sum/hugo.direct.sum to it. A plain build
      # (above) only ever touches hugo.direct.sum -- `hugo mod get` is the command that
      # keeps all three consistent with an explicit pinned version.
      Push-Location $SourceDir
      try {
         # soft-fail on purpose: this is a best-effort sync running inside a finally
         # block, not worth throwing over
         [void](exec hugo mod get "github.com/gohugoio/hugoDocs@$resolvedVersion")
      } catch {
         Write-Warning "hugo mod get failed for '$resolvedVersion' - go.mod/go.sum may be out of sync with hugo.toml"
      } finally {
         Pop-Location
      }
   } else {
      foreach ($file in $moduleState.Keys) {
         $current = if (Test-Path -PathType Leaf $file) { [System.IO.File]::ReadAllBytes($file) } else { @() }
         if ([System.Convert]::ToBase64String($current) -ne [System.Convert]::ToBase64String($moduleState[$file])) {
            Write-Verbose "Restore module state: $file"
            [System.IO.File]::WriteAllBytes($file, $moduleState[$file])
         }
      }
      if ($Ref -and $Update -and -not $resolvedVersion) {
         Write-Warning "Could not resolve '$Ref' to a concrete version - hugo.toml pin left unchanged."
      }
   }
}

# content/extract/functions.md renders to extract/functions.json
$freshDir = Join-Path $TargetDir 'extract'
$freshFile = Join-Path $freshDir 'functions.json'
if (-not (Test-Path -PathType Leaf $freshFile)) { throw "Expected extraction was not generated: $freshFile" }

$label = if ($Ref) { "hugoDocs '$Ref'" } else { 'the pinned hugoDocs version' }
$diffArgs = @{
   OldDir      = $SnapshotDir
   NewDir      = $freshDir
   Format      = 'Console'
   Heading     = "## Keyword changes: committed snapshot vs $label"
   NoticeTitle = if ($Ref) { "hugoDocs '$Ref' has keyword changes" } else { 'Keyword snapshot is out of date' }
}
if ($Notice) { $diffArgs.Notice = $true }
if ($env:GITHUB_STEP_SUMMARY -and -not $NoSummary) {
   $diffArgs.OutFile = $env:GITHUB_STEP_SUMMARY
   $diffArgs.Append = $true
}
$diff = & (Join-Path $PSScriptRoot 'keywords-diff.ps1') @diffArgs
if ($resolvedVersion) {
   Add-Member -InputObject $diff -NotePropertyName ResolvedVersion -NotePropertyValue $resolvedVersion -Force
   $diff.Text = "_Resolved ``$Ref`` to ``$resolvedVersion``._`n`n" + $diff.Text
}

if ($Update) {
   if ($diff.Changed) {
      Copy-Item -Force $freshFile $SnapshotDir
      Write-Host -ForegroundColor Green "Updated hugoDocs extraction in $SnapshotDir - review and commit it."
   } else {
      Write-Verbose "Keyword snapshot already up to date."
   }
   if ($Ref) {
      if ($resolvedVersion) {
         Write-Host -ForegroundColor Green "Pinned hugen/hugodocs/hugo.toml to '$resolvedVersion' (was tracking '$Ref') - review and commit it."
      } else {
         Write-Warning "Could not resolve '$Ref' - hugo.toml pin left unchanged."
      }
   }
} elseif ($diff.Changed) {
   if ($Ref) {
      $versionNote = if ($resolvedVersion) { " (resolves to '$resolvedVersion')" } else { '' }
      Write-Host -ForegroundColor Yellow ("hugoDocs '$Ref'$versionNote differs from the pin in hugen/hugodocs/hugo.toml.`n" +
         "To adopt it: ./build.ps1 -Steps ExtractKeywordsLatest -UpdateKeywords -KeywordsLatestRef $Ref")
   } else {
      Write-Warning ("hugoDocs extraction in $SnapshotDir is out of date with the pinned hugoDocs version.`n" +
         "Grammars are built from the snapshot. Refresh it with:`n" +
         "   ./build.ps1 -Steps ExtractKeywordsFromDocs -UpdateKeywords")
   }
} elseif ($Ref) {
   $versionNote = if ($resolvedVersion) { " (resolves to '$resolvedVersion')" } else { '' }
   Write-Host -ForegroundColor Green "hugoDocs '$Ref'$versionNote matches the pinned keyword snapshot."
}

return $diff
