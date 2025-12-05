[CmdLetBinding()]
param(
  # Skip some of the default steps
  [Parameter(Mandatory = $false)][ValiDateSet(
    'BuildHighlightJS',
    'CloneHighlightJS',
    'CloneModules',
    'GenerateModules',
    'UpdateHugoDocs',
    'TestHighlightJS',
    'DeveloperBuild'
  )][string[]]$Skip,
  # Force some actions that else might be skipped based on project state
  [Parameter(Mandatory = $false)][ValiDateSet('SetupHighlightJS')][string[]]$Force,
  # Build only extra languages
  [Parameter(Mandatory = $false)][ValiDateSet('true','false')][string]$OnlyExtra = 'true',
  # Proceed regardkess of test failures
  [Parameter(Mandatory = $false)][switch]$IgnoreMarkupErrors
)

$startCWD = Get-Location
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$VerboseGenerate = $PSBoundParameters.ContainsKey($VerboseGenerate)

### Setup Project
###
try {
  $ScriptsDir = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath "scripts")
  . (Join-Path -Path $ScriptsDir "lib\utilities.ps1")
  $ProjectRoot = Test-Folder $PSScriptRoot
  $WorkDir = Test-Folder -Create $ProjectRoot "work"
  $HugoDocsDir = Test-Folder $ProjectRoot "hugoDocs"
  $HugoGenDir = Test-Folder $ScriptsDir "hugen"

  $HighlightJsDir = Join-Path $WorkDir "highlight.js"
  $HighlightJsExtraDir = Join-Path $HighlightJsDir "extra"
  Write-Verbose "Starting from: $ProjectRoot"
  Write-Verbose "Working Directory: $WorkDir"

  # make sure we have the needed versions available
  & $ScriptsDir/versions-set-wanted.ps1 -VersionConfigFile $ProjectRoot\.versions.json
  & $ScriptsDir/versions-check-installed.ps1 -VersionConfigFile $ProjectRoot\.versions.json
} catch {
  Write-Error "$_`nProject initialization failed" -ErrorAction Continue
  throw $_
} finally {
  Set-Location $StartCWD
}

### Update HugoDocs
###
try {
  if ($Skip -contains "UpdateHugoDocs") {
    Write-Verbose "HugoDocs: update...SKIPPED"
  } else {
    Write-Verbose "HugoDocs: update submodule: $HugoDocsDir"
    Set-Location $ProjectRoot
    exec git submodule update --remote hugoDocs
    $updated = exec git submodule status hugoDocs
    if ($updated -match '^\+') {
      Write-Warning "HugoDocs submodule updated, verify keywords!"
      exec git add .\hugoDocs
    }
  }
  [void](Test-Folder $HugoDocsDir "content/en/functions")
} catch {
  Write-Error "$_`nHugoDocs: update submodules failed" -ErrorAction Continue
  throw $_
} finally {
  Set-Location $startCWD
}

### Initialize Highlight.js
###
try {
  if ($Skip -contains 'CloneHighlightJS') {
    Write-Verbose "HighlightJS: clone ...SKIPPED"
  } else {
    Set-Location $WorkDir
    if (-Not (Test-Path $HighlightJsDir -PathType Container)) {
      exec git clone --single-branch --depth 1 "-b" $HighlightJsVersion https://github.com/highlightjs/highlight.js.git
    } else {
      Write-Verbose "HighlightJS: keep current clone. To fresh up remove $HighLightJsDir"
    }
  }
  [void](Test-Folder $HighLightJsExtraDir)
  $needsInstall = $false
  try { [void](Test-Folder $HighlightJsDir -ChildPath "node_modules") }
  catch { $needsInstall = $true }
  if ($NeedsInstall -or ($Force -contains 'SetupHighlightJS')) {
    Set-Location $HighlightJsDir
    exec npm install --save-dev
    if ($LASTEXITCODE) { throw $_}
    exec npm audit fix
    if ($LASTEXITCODE) { throw $_}
  }
  [void](Test-Folder $HighLightJsDir\node_modules)
} catch {
  Write-Error "$_`nHighlightJS: clone and setup failed" -ErrorAction Continue
  throw $_
throw
} finally {
  Set-Location $startCWD
}

### Clone our Modules
###
try {
  if ($Skip -contains 'CloneModules') {
    Write-Verbose "HugoModules: clone ...SKIPPED"
  } else {
    Set-Location $HighlightJsExtraDir
    if (Test-Path hugo-html -PathType Container) { Remove-Item -Recurse -Force hugo-html }
    exec git clone https://github.com/irkode/highlightjs-hugo-html.git hugo-html
    if (Test-Path hugo-text -PathType Container) { Remove-Item -Recurse -Force hugo-text }
    exec git clone https://github.com/irkode/highlightjs-hugo-text.git hugo-text
  }
  [void](Test-Folder $HighLightJsExtraDir "hugo-html")
  [void](Test-Folder $HighLightJsExtraDir "hugo-text")
} catch {
  Write-Error "$_`nHugoModules: clone failed" -ErrorAction Continue
  throw $_
} finally {
  Set-Location $startCWD
}

### Generate Modules
###
try {
  if ($Skip -contains 'GenerateModules') {
    Write-Verbose "HugoModules: Generate Highlight.JS plugins to $HighlightJsExtraDir"
  } else {
    Set-Location $HugoGenDir
    exec hugo -d $HighlightJsExtraDir
  }
  [void](Test-File $HighlightJsExtraDir "hugo-html\src\languages\hugo-html.js")
  [void](Test-File $HighlightJsExtraDir "hugo-text\src\languages\hugo-text.js")
} catch {
  Write-Error "HugoModules: generate Highlight.JS modules failed" -ErrorAction Continue
  throw "$_"
} finally {
  Set-Location $startCWD
}

try {
  if ($Skip -contains 'BuildHighlightJS') {
    Write-Verbose "Skip Highlight.js build"
  } else {
    Set-Location $HighlightJsDir
    $EnvOnlyExtra = $ENV:ONLY_EXTRA
    if ($OnlyExtra -eq 'true') { $ENV:ONLY_EXTRA = 'true' } else { $ENV:ONLY_EXTRA = $Null }
    exec npm run build
    if ($Skip -contains 'TestHighlightJS') {
      Write-Verbose "Skip Highlight.js tests"
    } else {
      try { exec npm run test-markup }
      catch { if (-not $IgnoreMarkupErrors) { throw $_ }}
    }
    exec node tools/build.js hugo-html hugo-text -t cdn
  }
  [void](Test-File $HighlightJsExtraDir "hugo-html\dist\hugo-html.min.js")
  [void](Test-File $HighlightJsExtraDir "hugo-text\dist\hugo-text.min.js")
} catch {
  Write-Error "build Highlight.JS modules failed" -ErrorAction Continue
  throw $_
} finally {
  Set-Location $startCWD
  $ENV:ONLY_EXTRA = $EnvOnlyExtra
}

try {
  Set-Location $startCWD
  $PluginSourceFolder = Test-Folder $HighlightJsExtraDir "hugo-text\dist"
  $PluginTargetFolder = Test-Folder $HighlightJsExtraDir "plugins\discourse"
  & "$ScriptsDir\build-discourse-plugin.ps1" $PluginSourceFolder $PluginTargetFolder
  [void](Test-File $PluginTargetFolder "hugo-discourse-plugin.js")
} catch {
  Write-Error "Generation of Discourse Plugin failed" -ErrorAction Continue
  throw $_
} finally {
  Set-Location $startCWD
}

try {
  Set-Location $startCWD
  $PluginSourceFolder = Test-Folder $HighlightJsExtraDir "hugo-html\dist"
  $PluginTargetFolder = Test-Folder $HighlightJsExtraDir "plugins\highlightjs"
  & "$ScriptsDir\build-highlightjs-plugin.ps1" $PluginSourceFolder $PluginTargetFolder
  [void](Test-File $PluginTargetFolder "hugo-highlightjs-plugin.js")
} catch {
  Write-Error "Generation of HighlighJS Plugin failed" -ErrorAction Continue
  throw $_
} finally {
  Set-Location $startCWD
}


try {
  if ($Skip -contains 'DeveloperBuild') {
    Write-Verbose "Rebuild Highlight.js for testing"
  } else {
    Set-Location $HighlightJsDir
    exec node tools/build.js -n hugo-html hugo-text xml

    $StyleTargetFolder = Test-Folder -Path $HighlightJsDir "src/styles"
    $StyleSourceFile = Test-File -Path $HugoGenDir "/assets/templates/src/styles/debug-hugo.css"
    $DeveloperHtmlFile = Test-File -Path $HighlightJsDir "tools/developer.html"
    Write-Verbose "Add custom CSS style and patch developer.html - use it from work/developer.html"
    # add custom debugging style
    Copy-Item -Force $StyleSourceFile $StyleTargetFolder
    $styleSheets = (Get-ChildItem $StyleTargetFolder *.css | %{ "'$($_.Name)'" }) -join ','
    # $cssBase16Files = Get-ChildItem $StyleTargetFolder *.css
    $JsOptions = @"
const cssOptions = [${stylesheets}];
const selectElement = document.querySelector('.theme');
selectElement.innerHTML = '';
cssOptions.forEach(css => {
  const opt = document.createElement('option');
  opt.textContent = css;
  selectElement.appendChild(opt);
});

"@

    $JsOptions | Set-Content -Encoding utf8 -NoNewline (Join-Path $WorkDir style-options.js)

    $devhtml = Get-Content -Raw -Encoding utf8 $DeveloperHtmlFile
    $devhtml = $devhtml -replace '(?s)(<select class="theme">.*?</select>)', '$1<script src="style-options.js"></script>'
    $devhtml = $devhtml.Replace(
      "../src/styles/", "highlight.js/src/styles/").Replace(
      "../build/", "highlight.js/build/").Replace(
      "vendor/", "highlight.js/tools/vendor/").Replace(
      'default.css"', 'debug-hugo.css"').Replace(
      "'default.css'", "'debug-hugo.css'"
    )
    ($devhtml -join "`n") | Set-Content -Encoding utf8 -NoNewline (Join-Path $WorkDir developer.html)
  }
  [void](Test-File $WorkDir developer.html)
} catch {
  throw $_
} finally {
  Set-Location $startCWD
}

if ($HugoModules -contains 'Install') {
  try {
    Write-Verbose "Publish generated Files to Release Folders"
    Set-Location $PluginsDir -ErrorAction Stop # Safety
    Get-ChildItem -Force . -Exclude .git* | Remove-Item -Recurse -Force
    Copy-Item -Recurse -Force "$HighlightJsExtraDir/plugins/*" $PluginsDir

    Set-Location $HugoTextDir -ErrorAction Stop # Safety
    Get-ChildItem -Force . -Exclude .git* | Remove-Item -Recurse -Force
    Copy-Item -Recurse -Force "$HighlightJsExtraDir/hugo-text/*" $HugoTextDir

    Set-Location $HugoHtmlDir -ErrorAction Stop # Safety
    Get-ChildItem -Force . -Exclude .git* | Remove-Item -Recurse -Force
    Copy-Item -Recurse -Force "$HighlightJsExtraDir/hugo-html/*" $HugoHtmlDir
  } catch {
    Write-Error "Installing to $PublishDir failed" -ErrorAction SilentlyContinue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}

"==========================================" | Out-Host
Set-Location $HighlightJsExtraDir\hugo-html
exec git remote get-url origin
exec git status
"==========================================" | Out-Host
Set-Location $HighlightJsExtraDir\hugo-text
exec git remote get-url origin
exec git status
"==========================================" | Out-Host

Set-Location $startCWD
Write-Host -ForegroundColor Green "Check the Diffs for HugoDocs and highlightjs-hugo"
Write-Host -ForegroundColor Green "DONE."
exit 0