[CmdLetBinding(DefaultParameterSetName)]
param(
  # Skip some of the default steps
  [Parameter(Mandatory = $false)][ValidateSet(
    'BuildHighlightJS',
    'BuildDiscoursePlugin',
    'BuildHighlightJSPlugin',
    'CloneHighlightJS',
    'DeveloperBuild',
    'GenerateHugoModules',
    'UpdateHugoDocs',
    'Distribute',
    'updateHugoDocs',
    'ShowStatus',
    'TestHighlightJS'
  )][string[]]$Skip,
  # Force actions that else might be skipped based on project state
  [Parameter(Mandatory = $false)][ValiDateSet('SetupHighlightJS')][string[]]$Force,
  # Build only extra languages
  [Parameter(Mandatory = $false)][ValiDateSet('true', 'false')][string]$OnlyExtra = 'true',
  # Proceed regardless of test failures
  [Parameter(Mandatory = $false)][switch]$IgnoreMarkupErrors,
  # publish to Distribution folder
  [Parameter(Mandatory = $false)][Alias('Dist')][switch]$Distribute,
  [Parameter(Mandatory = $false)][ValidateSet(
    'BuildHighlightJS',
    'BuildDiscoursePlugin',
    'BuildHighlightJSPlugin',
    'CloneHighlightJS',
    'DeveloperBuild',
    'GenerateHugoModules',
    'UpdateHugoDocs',
    'Distribute',
    'ShowStatus',
    'updateHugoDocs'
  )][string[]]$Steps
)

$startCWD = Get-Location
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
if ($PSBoundParameters.Keys -notcontains 'Steps') {
  $Steps = @(
    'updateHugoDocs', 'cloneHighlightJS',
    'generateHugoModules',
    'buildHighlightJS', 'buildDiscoursePlugin', 'buildHighlightJSPlugin',
    'developerBuild'
  )
}
if ($PSBoundParameters.Keys -contains 'Skip') {
  $Steps = $steps | Where-Object { $Skip -notcontains $_ }
}
if ($Distribute) { $Steps += 'distribute' }

try {
  try {
    $ScriptsDir = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath "build")
    Import-Module (Join-Path -Path $ScriptsDir -ChildPath "lib/utilities.ps1")
    Import-Module (Join-Path -Path $ScriptsDir -ChildPath "lib/build-functions.ps1")
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

    foreach ($step in $Steps) {
      Write-Verbose "> Executing: [ $step ]"
      & $step
    }
  } catch {
    Write-Error "$_`nBuild failed!" -ErrorAction Continue
    throw $_
  } finally {
    Set-Location $StartCWD
  }
} catch {
  Write-Error  "$_`nBUILD failed!" -ErrorAction Stop
} finally {
  Remove-Module -Force utilities
  Remove-Module -Force build-functions
  Set-Location $startCWD
}
Write-Host -ForegroundColor Green "Check the Diffs for HugoDocs and highlightjs-hugo"
Write-Host -ForegroundColor Green "BUILD successful."
exit 0
