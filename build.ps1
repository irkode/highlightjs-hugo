[CmdLetBinding()]
param(
  [Parameter(Mandatory = $false)][ValiDateSet('SkipUpdate')][string[]]$HugoDocs,
  [Parameter(Mandatory = $false)][ValiDateSet('SkipClone')][string[]]$HighlightJSHugo,
  [Parameter(Mandatory = $false)][ValiDateSet('SkipClone', 'Setup', 'SkipBuild', 'SkipTests')][string[]]$HighlightJs,
  [Parameter(Mandatory = $false)][ValiDateSet('Install')][string[]]$HugoModules,
  [Parameter(Mandatory = $false)][switch]$IgnoreMarkupErrors,
  [Parameter(Mandatory = $false)][string]$HighlightJsVersion = "11.11.1"
)

function exec {
  Write-Verbose "exec > $($args -join ' ')"
  $rc = 0; $throwed = $false
  try {
    Invoke-Expression ($args -join " ")
    $rc = $LASTEXITCODE
  } catch {
    $throwed = $_
  } finally {
    if ($throwed) {
      $line = $MyInvocation.ScriptLineNumber
      $file = Split-Path -Leaf $MyInvocation.ScriptName
      Write-Error "[${file}:${line}] EXEC throwed: $throwed" -ErrorAction Stop
    } elseif ($rc) {
      $line = $MyInvocation.ScriptLineNumber
      $file = Split-Path -Leaf $MyInvocation.ScriptName
      if ($rc -ge 128) { $rc -= 128 }
      Write-Error "[${file}:${line}] EXEC failed with [RC:$rc] : [ $args ]" -ErrorAction Stop
    }
  }
}

function Test-File {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, Position=0)][string]$Path,
    [Parameter(Mandatory=$false, Position=1)][string]$ChildPath = ""
  )
  try {
    $testPath = Join-Path $Path $ChildPath
    $testPath = Resolve-Path -Path $testPath -ErrorAction Stop
    [void](Test-Path -PathType Leaf -Path $testPath -ErrorAction Stop)
    return $testPath
  } catch {
    Write-Error "Path [ $Path ] does not exist, is not a file"
    throw "$_"
  }
}

function Test-Folder {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, Position=0)][string]$Path,
    [Parameter(Mandatory=$false, Position=1)][string]$ChildPath = "",
    [Parameter(Mandatory=$false)][switch]$CreateIfMissing

  )
  try {
    $testPath = Join-Path $Path $ChildPath
    Write-Verbose "Test-Folder: $testPath"
    If ($TestPath) {
      If (-Not (Test-Path $testPath)) {
        if ($CreateIfMissing) {
          Write-Verbose "Create Folder: $testPath"
          [void](New-Item -Type Directory $testPath -ErrorAction Stop)
        } else {
          Write-Error "Path [ $Path ] does not exist, is not a folder or creation failed"
          throw "$_"
        }
      }
      $testPath = Resolve-Path -Path $testPath -ErrorAction Stop
      [void](Test-Path -PathType Container -Path $testPath -ErrorAction Stop)
      return $testPath
    } else {
      Write-Error "Path [ $testPath ] may not be empty"
      throw "$_"
    }
  } catch {
    Write-Error "Path [ $testPath ] does not exist, is not a folder or creation failed"
    throw "$_"
  }
}

#$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$VerboseGenerate = $PSBoundParameters.ContainsKey($VerboseGenerate)
$startCWD = Get-Location
try {
  $ProjectRoot = Test-Folder $PSScriptRoot
  $WorkDir = Test-Folder -Create $ProjectRoot "work"
  $HighlightJsDir = Join-Path $WorkDir "highlight.js"
  $PublishDir = Test-Folder -Create $ProjectRoot "publish"
  $PluginsDir = Test-Folder -Create $PublishDir "plugins"
  $HugoHtmlDir = Join-Path $PublishDir "hugo-html"
  $HugoTextDir = Join-Path $PublishDir "hugo-text"
  # hugo docs will only be updated on local machine
  $HugoDocsDir = Join-Path $ProjectRoot "hugoDocs"
} catch {
  Write-Error "Failed to determine project folders" -ErrorAction Continue
  throw $_
}
# TODO: CONTINUE RENAMES
Write-Verbose "ProjectRoot: $ProjectRoot"
Write-Verbose "WorkDir: $WorkDir"

# Checkout hugo4fun-highlightjs
./scripts/versions-set-wanted.ps1
# CI: SetUp Node.js
# CI: Setup Go
# CI: Cache Hugo binary
# CI: Install Hugo
# CI: Add Hugo to Path
./scripts/versions-check-installed.ps1

if ($HugoDocs -contains "SkipUpdate") {
  Write-Verbose "hugoDocs: update...SKIPPED"
} else {
  try {
    Write-Verbose "hugoDocs: update submodule: $HugoDocsDir"
    Set-Location $ProjectRoot
    exec git submodule update --remote hugoDocs
    $updated = exec git submodule status hugoDocs
    if ($updated -match '^\+') {
      Write-Warning "hugoDocs submodule updated, verify keywords!"
      exec git add .\hugoDocs
    }
  } catch {
    Write-Error "hugoDocs: update submodules failed" -ErrorAction SilentlyContinue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}
[void](Test-Folder $HugoDocsDir "content/en/functions")
Write-Verbose "HugoDocsDir: $HugoDocsDir"

$ReleaseSubmodulesChanged = $false
try {
  Write-Verbose "Verify Release Submodules for hugo-* have not changed"
  Set-Location $ProjectRoot
  exec git submodule update --remote publish/hugo-html
  $updated = exec git submodule status publish/hugo-html
  if ($updated -match '^\+') {
    Write-Warning "publish/hugo-html submodule updated from outside!"
    $ReleaseSubmodulesChanged = $true
  }
  Write-Verbose "Verify Release Submodules for hugo-* have not changed"
  Set-Location $ProjectRoot
  exec git submodule update --remote publish/hugo-html
  $updated = exec git submodule status publish/hugo-text
  if ($updated -match '^\+') {
    Write-Warning "publish/hugo-text submodule updated from outside!"
    $ReleaseSubmodulesChanged = $true
  }
} catch {
  Write-Error "Hugo ReleaseModules: verification failed" -ErrorAction SilentlyContinue
  throw "$_"
} finally {
  Set-Location $startCWD
}
if ($ReleaseSubmodulesChanged) {
  Write-Error "Our Release Submodules are not up to date. check and update in case"
}

if ($HighlightJS -contains 'SkipClone') {
  Write-Verbose "HighlightJS: clone ...SKIPPED"
} else {
  try {
    Set-Location $WorkDir
    if (-Not (Test-Path $HighlightJsDir -PathType Container)) {
      exec git clone --single-branch --depth 1 "-b" $HighlightJsVersion https://github.com/highlightjs/highlight.js.git
    } else {
      Write-Verbose "HighlightJS: keep current clone. To fresh up remove $HighLightJsDir"
    }
  } catch {
    Write-Error "HighlightJS: download failed" -ErrorAction SilentlyContinue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}

$HighlightJsExtraDir = Test-Folder $HighLightJsDir "extra"
Write-Verbose "HighlightJsDir: $HighlightJsDir"
Write-Verbose "HighlightJsExtraDir: $HighlightJsExtraDir"
try {
  Write-Verbose "highlightjs-hugo: Generate HLJS plugins to $HighlightJsExtraDir"
  Set-Location (Join-Path $ProjectRoot "scripts/hugen")
  exec hugo -d $HighlightJsExtraDir
} catch {
  Write-Error "highlightjs-hugo: generate HIGHLIGHT.JS plugins failed" -ErrorAction SilentlyContinue
  throw "$_"
} finally {
  Set-Location $startCWD
}

$needsInstall = $false
try {
  [void](Test-Folder $HighlightJsDir -ChildPath "node_modules")
} catch {
  $needsInstall = $true
}
if ($NeedsInstall -or ($HighlightJS -contains 'Setup')) {
  try {
    Write-Verbose "Starting from $HighlightJsDir"
    Set-Location $HighlightJsDir
    npm install --save-dev
    if ($LASTEXITCODE) { throw $_}
    npm audit fix
    if ($LASTEXITCODE) { throw $_}
  } finally {
    Set-Location $startCWD
  }
}

if ($HighlightJs -contains 'SkipBuild') {
  Write-Verbose "Skip Highlight.js build"
  Set-Location $startCWD
} else {
  Write-Verbose "Build HighlightJS-Hugo"
  try {
    Set-Location $HighlightJsDir
    $ENV:ONLY_EXTRA = 'true'
    exec npm run build
    if (-not ($HighlightJs -contains 'SkipTests')) {
      try {
        exec npm run test-markup
      } catch {
        if ($LastExitCode) {
          if (-not $IgnoreMarkupErrors) {
            throw "HighlightJS: npm run test-markup FAILED!"
          } else {
            Write-Warning "HighlightJS: npm run test-markup FAILED! fix code or tests!!!"
          }
        }
      }
    }
    exec node tools/build.js hugo-html hugo-text -t cdn
  } catch {
    Write-Error "build Highlight.JS modules failed" -ErrorAction Continue
    throw $_
  } finally {
    Set-Location $startCWD
  }
}

try {
  Set-Location $startCWD
  $PluginSourceFolder = Test-Folder $HighlightJsExtraDir "hugo-text\dist"
  $PluginTargetFolder = Test-Folder $HighlightJsExtraDir "plugins\discourse"
  & "$ProjectRoot\scripts\build-discourse-plugin.ps1" $PluginSourceFolder $PluginTargetFolder
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
  & "$ProjectRoot\scripts\build-highlightjs-plugin.ps1" $PluginSourceFolder $PluginTargetFolder
  [void](Test-File $PluginTargetFolder "hugo-highlightjs-plugin.js")
} catch {
  Write-Error "Generation of HighlighJS Plugin failed" -ErrorAction Continue
  throw $_
} finally {
  Set-Location $startCWD
}

try {
  Write-Verbose "Rebuild Highlight.js for testing"
  Set-Location $HighlightJsDir
  exec node tools/build.js -n hugo-html hugo-text xml

  $StyleTargetFolder = Test-Folder -Path $HighlightJsDir "src/styles"
  $StyleSourceFile = Test-File -Path $ProjectRoot "scripts/hugen/assets/templates/src/styles/debug-hugo.css"
  $DeveloperHtmlFile = Test-File -Path $HighlightJsDir "tools/developer.html"
  Write-Verbose "Add custom CSS style and patch developer.html - use it from work/developer.html"
  # add custom debugging style
  Copy-Item -Force $StyleSourceFile $StyleTargetFolder
  $styleSheets = (Get-ChildItem $StyleTargetFolder *.css | %{ "'$($_.Name)'" }) -join ','
  #$cssBase16Files = Get-ChildItem $StyleTargetFolder *.css
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
} catch {
  throw $_
} finally {
  Set-Location $startCWD
}

if ($HugoModules -contains 'Install') {
  try {
    Write-Verbose "Publish generated Files to Release Folders"
    Set-Location $PluginsDir -ErrorAction Stop # Safety
    gci -Force . -Exclude .git* | Remove-Item -Recurse -Force
    Copy-Item -Recurse -Force "$HighlightJsExtraDir/plugins/*" $PluginsDir

    Set-Location $HugoTextDir -ErrorAction Stop # Safety
    gci -Force . -Exclude .git* | Remove-Item -Recurse -Force
    Copy-Item -Recurse -Force "$HighlightJsExtraDir/hugo-text/*" $HugoTextDir

    Set-Location $HugoHtmlDir -ErrorAction Stop # Safety
    gci -Force . -Exclude .git* | Remove-Item -Recurse -Force
    Copy-Item -Recurse -Force "$HighlightJsExtraDir/hugo-html/*" $HugoHtmlDir
  } catch {
    Write-Error "Installing to $PublisDir failed" -ErrorAction SilentlyContinue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}

Set-Location $startCWD
Write-Host -ForegroundColor Green "Check the Diffs for HugoDocs and highlightjs-hugo"
Write-Host -ForegroundColor Green "DONE."
exit 0