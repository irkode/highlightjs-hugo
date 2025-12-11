[CmdLetBinding()]
param(
  # Skip some of the default steps
  [Parameter(Mandatory = $false)][ValidateSet(
    'BuildHighlightJS',
    'CloneHighlightJS',
    'GenerateHugoModules',
    'GenerateModules',
    'UpdateHugoDocs',
    'TestHighlightJS',
    'DeveloperBuild'
  )][string[]]$Skip,
  # Force some actions that else might be skipped based on project state
  [Parameter(Mandatory = $false)][ValiDateSet('SetupHighlightJS')][string[]]$Force,
  # Build only extra languages
  [Parameter(Mandatory = $false)][ValiDateSet('true','false')][string]$OnlyExtra = 'true',
  # Proceed regardless of test failures
  [Parameter(Mandatory = $false)][switch]$IgnoreMarkupErrors,
  # only build developer.html for visual testing
  [Parameter(Mandatory = $false)][switch]$DevBuildOnly,
  # just check for changes
  [Parameter(Mandatory = $false)][switch]$StatusOnly,
  # publish to Distribution folder
  [Parameter(Mandatory = $false)][Alias('Dist')][switch]$Distribute,
  # only distribute last results
  [Parameter(Mandatory = $false)][Alias('DistOnly')][switch]$DistributeOnly
)

$startCWD = Get-Location
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

try {
  $ScriptsDir = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath "scripts")
  . (Join-Path -Path $ScriptsDir "lib\utilities.ps1")
  . (Join-Path -Path $ScriptsDir "lib\build-functions.ps1")

  $ProjectRoot = Test-Folder $PSScriptRoot
  $WorkDir = Test-Folder -Create $ProjectRoot "work"
  $HugoDocsDir = Test-Folder $ProjectRoot "hugoDocs"
  $HugoGenDir = Test-Folder $ScriptsDir "hugen"
  $DistributionDir = Test-Folder -Create $ProjectRoot "dist"

  $HighlightJsDir = Join-Path $WorkDir "highlight.js"
  $HighlightJsExtraDir = Join-Path $HighlightJsDir "extra"
  Write-Verbose "Starting from: $ProjectRoot"
  Write-Verbose "Working Directory: $WorkDir"
} catch {
  Write-Error "$_`nInitialization failed!" -ErrorAction Continue
  throw $_
} finally {
  Set-Location $StartCWD
}

try {
  & $ScriptsDir/versions-set-wanted.ps1 -VersionConfigFile $ProjectRoot\.versions.json
  # we expect all external tools be installed before starting a local build
  & $ScriptsDir/versions-check-installed.ps1 -VersionConfigFile $ProjectRoot\.versions.json

  if ($StatusOnly) { try { showStatus; exit 0 } catch { throw } }
  if ($DistributeOnly) { try { distribute; exit 0 } catch { throw } }
    if (-Not $DevBuildOnly) {
    updateHugoDocs
    cloneHighlightJS
    generateHugoModules
    buildHighlightJS
    buildDiscoursePlugin
    buildHighlightJSPlugin
  }
  developerBuild
  if ($Distribute) { distribute }
  showStatus
} catch {
  Write-Error "$_`nBuild failed!" -ErrorAction Continue
  throw $_
} finally {
  Set-Location $StartCWD
}

Set-Location $startCWD
Write-Host -ForegroundColor Green "Check the Diffs for HugoDocs and highlightjs-hugo"
Write-Host -ForegroundColor Green "DONE."
exit 0
