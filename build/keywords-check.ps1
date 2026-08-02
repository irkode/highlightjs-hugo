<#
.SYNOPSIS
   Re-scrape the hugoDocs function reference and report how it differs from the committed
   extraction in hugen/_hugodocs.

.DESCRIPTION
   Two modes:

   - without -Ref: builds `hugen/hugodocs` as configured, i.e. at the hugoDocs version
     pinned in its `hugo.toml`. A difference means the pin was bumped without refreshing
     the snapshot. `-Update` adopts the fresh extraction as the new snapshot.

   - with -Ref <branch|tag|version>: builds against that hugoDocs ref instead, to see how
     far upstream has moved beyond the pin. The pinned config is left untouched (the ref
     is injected through a generated config overlay), and go.mod / go.sum /
     hugo.direct.sum are restored afterwards so the working tree stays clean.

   Reporting only: this script never fails the build. It is called both by
   `build.ps1` (steps ExtractKeywordsFromDocs / ExtractKeywordsLatest) and directly by CI,
   so it must stay cross-platform - no Windows-only path separators.

.OUTPUTS
   The PSCustomObject returned by build/keywords-diff.ps1.

   Output is hugen/_hugodocs/functions.json - see build/keywords-diff.ps1 for its shape.

.EXAMPLE
   ./build/keywords-check.ps1 -Update

.EXAMPLE
   ./build/keywords-check.ps1 -Ref master -Notice
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
   # adopt the fresh extraction as the committed snapshot (only valid without -Ref)
   [Parameter(Mandatory = $false)][switch]$Update,
   # emit a GitHub Actions ::notice:: and a job summary entry when something changed
   [Parameter(Mandatory = $false)][switch]$Notice
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $SourceDir) { $SourceDir = Join-Path $repoRoot 'hugen/hugodocs' }
if (-not $SnapshotDir) { $SnapshotDir = Join-Path $repoRoot 'hugen/_hugodocs' }
if (-not $TargetDir) {
   $TargetDir = Join-Path $repoRoot ($Ref ? 'work/hugodocs-latest' : 'work/hugodocs')
}
if ($Ref -and $Update) {
   throw "-Update cannot be combined with -Ref: adopting an unpinned scrape would decouple the snapshot from hugen/hugodocs/hugo.toml"
}

if (-not (Test-Path -PathType Container $SourceDir)) { throw "No such directory: $SourceDir" }
if (Test-Path -PathType Container $TargetDir) { Remove-Item -Recurse -Force $TargetDir }
[void](New-Item -ItemType Directory -Force -Path $TargetDir)
[void](New-Item -ItemType Directory -Force -Path $SnapshotDir)

$hugoArgs = @('--source', $SourceDir, '--destination', $TargetDir)
$moduleState = @{}

if ($Ref) {
   # Derive the overlay from the real config instead of keeping a second copy of the
   # [module] block: only the import version differs, and the hugoDocs mounts have to
   # stay in sync automatically.
   $configFile = Join-Path $SourceDir 'hugo.toml'
   $config = Get-Content -Raw -Path $configFile
   $patched = [regex]::Replace($config, "(?m)^(\s*version\s*=\s*)'[^']*'", "`${1}'$Ref'")
   if ($patched -eq $config) {
      throw "No module import version found in $configFile - cannot build against '$Ref'"
   }
   $overlay = Join-Path $TargetDir 'hugo.overlay.toml'
   Set-Content -Encoding utf8 -Path $overlay -Value $patched
   # right-most config file wins, so the overlay replaces the pinned module import
   $hugoArgs += @('--config', "hugo.toml,$overlay")

   # Hugo rewrites the module state for whatever version it resolves; this step is
   # informational and must not leave the working tree dirty.
   foreach ($name in @('go.mod', 'go.sum', 'hugo.direct.sum')) {
      $file = Join-Path $SourceDir $name
      if (Test-Path -PathType Leaf $file) { $moduleState[$file] = [System.IO.File]::ReadAllBytes($file) }
   }
}

try {
   Write-Verbose "hugo $($hugoArgs -join ' ')"
   & hugo @hugoArgs
   if ($LASTEXITCODE -ne 0) { throw "hugo failed with exit code $LASTEXITCODE" }
} finally {
   foreach ($file in $moduleState.Keys) {
      $current = if (Test-Path -PathType Leaf $file) { [System.IO.File]::ReadAllBytes($file) } else { @() }
      if ([System.Convert]::ToBase64String($current) -ne [System.Convert]::ToBase64String($moduleState[$file])) {
         Write-Verbose "Restore module state: $file"
         [System.IO.File]::WriteAllBytes($file, $moduleState[$file])
      }
   }
}

# hugen/hugodocs renders content/extract/functions.md, so the artifact lands under
# extract/ in the destination
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
if ($env:GITHUB_STEP_SUMMARY) {
   $diffArgs.OutFile = $env:GITHUB_STEP_SUMMARY
   $diffArgs.Append = $true
}
$diff = & (Join-Path $PSScriptRoot 'keywords-diff.ps1') @diffArgs

if ($Update) {
   if ($diff.Changed) {
      Copy-Item -Force $freshFile $SnapshotDir
      Write-Host -ForegroundColor Green "Updated hugoDocs extraction in $SnapshotDir - review and commit it."
   } else {
      Write-Verbose "Keyword snapshot already up to date."
   }
} elseif ($diff.Changed) {
   if ($Ref) {
      Write-Host -ForegroundColor Yellow ("hugoDocs '$Ref' differs from the pin in hugen/hugodocs/hugo.toml.`n" +
         "To adopt it: bump that version, then run`n" +
         "   ./build.ps1 -Steps ExtractKeywordsFromDocs -UpdateKeywords")
   } else {
      Write-Warning ("hugoDocs extraction in $SnapshotDir is out of date with the pinned hugoDocs version.`n" +
         "Grammars are built from the snapshot. Refresh it with:`n" +
         "   ./build.ps1 -Steps ExtractKeywordsFromDocs -UpdateKeywords")
   }
} elseif ($Ref) {
   Write-Host -ForegroundColor Green "hugoDocs '$Ref' matches the pinned keyword snapshot."
}

return $diff
