<#
.SYNOPSIS
   Build hugen/keywords and report how far the 'master' hugoDocs has moved beyond the pin.

.DESCRIPTION
   hugen/keywords/hugo.toml imports github.com/gohugoio/hugoDocs twice - once at the pinned
   version, once at 'master' - mounted side by side. A single `hugo` build therefore
   produces both hugen/keywords/public/pinned.json (grammars are built from this) and
   .../latest.json (how far upstream has moved). This script builds once and diffs the two.

   -Update adopts 'master' as the new pin: the version it resolved to (read back from
   hugo.direct.sum) is written into hugo.toml's pinned import, and `hugo mod get` re-syncs
   go.mod/go.sum/hugo.direct.sum to it.

   Reporting only unless -Update is given; never fails a build. Called by build.ps1 and
   directly by CI, so keep it POSIX-path clean.

.OUTPUTS
   The PSCustomObject returned by build/keywords-diff.ps1.

.EXAMPLE
   ./build/keywords-check.ps1 -Notice

.EXAMPLE
   ./build/keywords-check.ps1 -Update
#>
[CmdLetBinding()]
param(
   # the Hugo module doing the scraping (default: <repo>/hugen/keywords)
   [Parameter(Mandatory = $false)][string]$SourceDir,
   # where the extraction is written (default: <repo>/work/keywords)
   [Parameter(Mandatory = $false)][string]$TargetDir,
   # adopt 'master' as the new pin in hugo.toml
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
if (-not $SourceDir) { $SourceDir = Join-Path $repoRoot 'hugen/keywords' }
if (-not $TargetDir) { $TargetDir = Join-Path $repoRoot 'work/keywords' }
if (-not (Test-Path -PathType Container $SourceDir)) { throw "No such directory: $SourceDir" }
if (Test-Path -PathType Container $TargetDir) { Remove-Item -Recurse -Force $TargetDir }
[void](New-Item -ItemType Directory -Force -Path $TargetDir)

# voided so hugo's own console lines don't leak into this script's captured return value
# when a caller does `$result = & keywords-check.ps1 ...`
[void](exec hugo --source $SourceDir --destination $TargetDir)

$pinnedFile = Join-Path $TargetDir 'pinned.json'
$latestFile = Join-Path $TargetDir 'latest.json'
foreach ($file in @($pinnedFile, $latestFile)) {
   if (-not (Test-Path -PathType Leaf $file)) { throw "Expected extraction was not generated: $file" }
}

if ($Update) {
   $configFile = Join-Path $SourceDir 'hugo.toml'
   $config = Get-Content -Raw -Path $configFile
   # the pinned import's version line -- the other one is the literal 'master'
   $pinnedMatch = [regex]::Match($config, "(?m)^(\s*version\s*=\s*)'(?!master')([^']+)'")
   if (-not $pinnedMatch.Success) { throw "No pinned module import version found in $configFile" }
   $pinnedVersion = $pinnedMatch.Groups[2].Value

   # hugo.direct.sum carries one line per resolved version -- whichever isn't the pin is
   # what 'master' resolved to. No config overlay needed: both versions are already
   # standing imports, so a plain build resolves both.
   $sumFile = Join-Path $SourceDir 'hugo.direct.sum'
   $resolvedVersion = Select-String -Path $sumFile -Pattern 'github\.com/gohugoio/hugoDocs\s+(\S+)' |
      ForEach-Object { $_.Matches[0].Groups[1].Value } |
      Where-Object { $_ -ne $pinnedVersion } |
      Select-Object -First 1

   if (-not $resolvedVersion) {
      Write-Warning "Could not resolve 'master' to a concrete version in $sumFile - hugo.toml pin left unchanged."
   } else {
      $newConfig = $config.Remove($pinnedMatch.Index, $pinnedMatch.Length).Insert(
         $pinnedMatch.Index, "$($pinnedMatch.Groups[1].Value)'$resolvedVersion'")
      # keep the informational '#latest ...' comment (if present) in sync too
      $newConfig = $newConfig -replace '(?m)^(\s*#\s*latest\s+)\S+\s*$', "`${1}$resolvedVersion"
      Set-Content -Encoding utf8 -NoNewline -Path $configFile -Value $newConfig

      Push-Location $SourceDir
      try {
         [void](exec hugo mod get "github.com/gohugoio/hugoDocs@$resolvedVersion")
      } catch {
         Write-Warning "hugo mod get failed for '$resolvedVersion' - go.mod/go.sum may be out of sync with hugo.toml"
      } finally {
         Pop-Location
      }
      Write-Host -ForegroundColor Green "Pinned hugen/keywords/hugo.toml to '$resolvedVersion' (was '$pinnedVersion') - review and commit it."
   }
}

$diffArgs = @{
   OldDir      = $TargetDir
   FileName    = 'pinned.json'
   NewDir      = $TargetDir
   NewFileName = 'latest.json'
   Format      = 'Console'
   Heading     = "## Keyword changes: pinned hugoDocs vs ``master``"
   NoticeTitle = "hugoDocs 'master' has keyword changes"
}
if ($Notice) { $diffArgs.Notice = $true }
if ($env:GITHUB_STEP_SUMMARY -and -not $NoSummary) {
   $diffArgs.OutFile = $env:GITHUB_STEP_SUMMARY
   $diffArgs.Append = $true
}
$diff = & (Join-Path $PSScriptRoot 'keywords-diff.ps1') @diffArgs

if (-not $Update) {
   if ($diff.Changed) {
      Write-Host -ForegroundColor Yellow ("hugoDocs 'master' differs from the pin in hugen/keywords/hugo.toml.`n" +
         "To adopt it: ./build.ps1 -Steps ExtractKeywords -UpdateKeywords")
   } else {
      Write-Host -ForegroundColor Green "hugoDocs 'master' matches the pinned keyword set."
   }
}

return $diff
