[CmdLetBinding()]
param(
  [Parameter(Mandatory = $false)][switch]$SkipHugoDocs,
  [Parameter(Mandatory = $false)][switch]$SkipHighlight,
  [Parameter(Mandatory = $false)][switch]$BuildAlways,
  [Parameter(Mandatory = $false)][switch]$IgnoreMarkupErrors,
  [Parameter(Mandatory = $false)][switch]$VerboseGenerate
)
$VerboseGenerate = $PSBoundParameters.ContainsKey($VerboseGenerate)
$startCWD = Get-Location
try {
  $ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
  $WorkDir = Resolve-Path (Join-Path $ProjectRoot "work")
  $HighlightJS_Dir = Resolve-Path (Join-Path $ProjectRoot "highlight.js")
  $HighlightJs_4_Hugo_SourceDir = Resolve-Path (Join-Path $ProjectRoot "highlightjs-hugo")
  $HighlightJs_4_Hugo_TargetDir = Join-Path $HighlightJs_Dir "extra/highlightjs-hugo"
  $KeywordFile_Current = Resolve-Path (Join-Path $HighlightJs_4_Hugo_SourceDir "src/languages/keywords.js")
} catch {
  Write-Error "Failed to determine project root"
}

if ($SkipHugoDocs) {
  Write-Verbose "Skip hugoDocs updates"
  $Updated = $false
} else {
  Write-Verbose "Check for hugoDocs updates"
  try {
    Set-Location hugoDocs
    $Fetched = git fetch
    if ($LastExitCode) { throw "hugoDocs: git fetch" }
    if ($Fetched) { Write-Verbose $Fetched }
    $Origin = git remote
    if ($LastExitCode) { throw "hugoDocs: git remote" }
    $Branch = git branch --show-current
    if ($LastExitCode) { throw "hugoDocs: git branch --showCurrent" }
    $NeedsUpdate = git log HEAD..$Origin/$Branch --oneline
    if ($LastExitCode) { throw "hugoDocs: git log HEAD..$Origin/$Branch --oneline" }
    if ($NeedsUpdate) {
      $Updated = git pull
      if ($LastExitCode) { throw "hugoDocs: git pull" }
      if ($Updated) { Write-Verbose $Updated }
    }
  } catch {
    Write-Error -ErrorAction 'Continue' "$_"
    Write-Error "OOPS failed to check and update Hugo Documentation"
  } finally {
    Set-Location $startCWD
  }
}

Write-Output "Generate Keywords"
try {
  & $PSScriptRoot\generate-keywords.ps1 -Force -Verbose:$VerboseGenerate
  & $PSScriptRoot\generate-javascript.ps1 -Force -Verbose:$VerboseGenerate
  $KeywordFile_Generated = Resolve-Path (Join-Path $WorkDir "keywords.js")
  $KeywordsHaveChanged = Compare-Object (Get-Content  -Encoding utf8 $KeywordFile_Current) (Get-Content -Encoding utf8 $KeywordFile_Generated)
} catch {
  Write-Output "$_" -ErrorAction Continue
  Write-Error -ErrorAction Stop "Generation of javascript module failed"
}

if (-not $SkipHugoDocs -and $Updated) {
  Write-Verbose "Update hugoDocs submodule"
  try {
    Set-Location .\hugoDocs
    & git add .
    if ($LastExitCode) { throw "hugoDocs: git add .\hugoDocs" }
    & git cm "bump hugoDocs to latest commit"
    if ($LastExitCode) { throw "hugoDocs: git cm `"bump hugoDocs to latest commit`"" }
    & git push
    if ($LastExitCode) { throw "hugoDocs: git push" }
    & git submodule update hugoDocs
    if ($LastExitCode) { throw "hugoDocs: submodule update hugoDocs" }
  } catch {
    Write-Error "$_" -ErrorAction Continue
    throw "update hugoDocs submodule failed"
  } finally {
    Set-Location $startCWD
  }
}

if (-not $KeywordsHaveChanged -and (-not $BuildAlways)) {
  Write-Verbose "No changed Keywords, nothing to do"
  Set-Location $startCWD
  exit 0
}

Write-Output "Changed Keywords found:"
$KeywordsHaveChanged | Out-Host

if ($SkipHighlight) {
  Write-Verbose "Skip Highlight.js build"
  Set-Location $startCWD
  exit 0
}

Write-Verbose "Build HighlightJS-Hugo"
try {
  Write-Verbose "HighlightJS: copy sources to $HighlightJs_4_Hugo_TargetDir"
  if (Test-Path $HighlightJs_4_Hugo_TargetDir) {
    Remove-Item -Recurse -Force $HighlightJs_4_Hugo_TargetDir
  }
  Copy-Item -Recurse $HighlightJs_4_Hugo_SourceDir (Join-Path $HighlightJS_Dir "extra")
  Copy-Item $KeywordFile_Generated (Join-Path $HighlightJS_Dir "extra\highlightjs-hugo\src\languages")
  Set-Location $HighlightJS_Dir
  & npm install --save-dev
  if ($LastExitCode) { throw "HighlightJS: npm install --save-dev" }
  $ENV:ONLY_EXTRA = 'true'
  if ($LastExitCode) { throw "HighlightJS: node ./tools/build.js -n hugo" }
  & npm run build
  if ($LastExitCode) { throw "HighlightJS: npm run build" }
  & npm run test-markup
  if ($LastExitCode) {
    if (-not $IgnoreMarkupErrors) {
      throw "HighlightJS: npm run test-markup"
    } else {
      Write-Warning "HighlightJS: npm run test-markup FAILED! fix code or tests!!!"

    }
  }
  & node tools/build.js hugo -t cdn
  if ($LastExitCode) { throw "HighlightJS: node tools/build.js hugo -t cdn" }
} catch {
  Write-Error "$_" -ErrorAction Continue
  throw "build Highlight.JS module failed"
} finally {
  Set-Location $startCWD
}

Set-Location $startCWD
