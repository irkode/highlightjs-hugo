[CmdLetBinding()]
param(
  [Parameter(Mandatory = $false)][ValiDateSet('SkipUpdate')][string[]]$HugoDocs,
  [Parameter(Mandatory = $false)][ValiDateSet('SkipClone')][string[]]$HighlightJSHugo,
  [Parameter(Mandatory = $false)][ValiDateSet('SkipClone', 'Setup', 'SkipBuild', 'SkipTests')][string[]]$HighlightJs,
  [Parameter(Mandatory = $false)][ValiDateSet('Install')][string[]]$HugoModules,
  [Parameter(Mandatory = $false)][switch]$IgnoreMarkupErrors,
  [Parameter(Mandatory = $false)][string]$HighlightJsVersion = "11.11.1"
)

function Exec {
  [Alias('Invoke-Git', 'Invoke-Npm', 'Invoke-Node', "Invoke-Hugo")]
  param(
    [Parameter(Mandatory=$false)][switch]$Void,
    [Parameter(Mandatory=$false)][switch]$Passthru,
    [Parameter(ValueFromRemainingArguments)][string[]]$Arguments
  )
  $cmd = switch ($MyInvocation.InvocationName) {
    'Invoke-Git' { "git"; break }
    'Invoke-Hugo' { "hugo"; break }
    'Invoke-Npm' { "npm"; break }
    'Invoke-Node' { "node"; break }
    'Exec' { throw "Exec cannot be called directly. Use the defined aliases to execute a command" }
    default {
      throw "Unknown aliased command: $($MyInvocation.InvocationName)"
    }
  }
  if ($Silent) { $Arguments += "--noprogress" }
  $message = "exec> $cmd $Arguments"
  Write-Verbose $message
  if ($Passthru) {
    & $cmd @Arguments
    if ($LastExitCode) { throw "OOPS" }
  } else {
    $result = & $cmd @Arguments
    if ($LastExitCode) { throw $result }
    if (-not $Void) { return $result }
  }
  if ($LastExitCode) { throw $result }
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
    Write-Verbose "Test-Folder: $Path - $ChildPath"
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

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$VerboseGenerate = $PSBoundParameters.ContainsKey($VerboseGenerate)
$startCWD = Get-Location
try {
  $ProjectRoot = Test-Folder $PSScriptRoot ".." -Verbose
  $WorkDir = Test-Folder -Create $ProjectRoot "work"
  # will be checked when first time needed
  $HugoDocsDir = Join-Path $ProjectRoot "hugoDocs"
  $HighlightJsDir = Join-Path $ProjectRoot "highlight.js"
  $HugoHtmlDir = Join-Path $ProjectRoot "hugo-html"
  $HugoTextDir = Join-Path $ProjectRoot "hugo-text"
  $PluginDir = Join-Path $ProjectRoot "plugins"
} catch {
  Write-Error "Failed to determine project folders" -ErrorAction Continue
  throw $_
}
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
    Write-Verbose "hugoDocs: update submodule"
    Set-Location $HugoDocsDir
    Invoke-Git -Passthru submodule update --remote
    Invoke-Git -Passthru submodule status
  } catch {
    Write-Error "hugoDocs: update submodules failed" -ErrorAction SilentlyContinue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}
[void](Test-Folder $HugoDocsDir "content/en/functions")
Write-Verbose "HugoDocsDir: $HugoDocsDir"

if ($HighlightJS -contains 'SkipClone') {
  Write-Verbose "HighlightJS: clone ...SKIPPED"
} else {
  try {
    if (-Not (Test-Path $HighlightJsDir -PathType Container)) {
      Invoke-Git -void clone --single-branch --depth 1 "-b" $HighlightJsVersion https://github.com/highlightjs/highlight.js.git
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
  Invoke-Hugo -Passthru "-d" $HighlightJsExtraDir
} catch {
  Write-Error "highlightjs-hugo: generate HIGHLIGHT.JS plugins failed" -ErrorAction SilentlyContinue
  throw "$_"
} finally {
  Set-Location $startCWD
}

$needsInstall = $false
try {
  Test-Folder $HighlightJsDir -ChildPath "node_modules"
} catch {
  $needsInstall = $true
}
if ($NeedsInstall -or ($HighlightJS -contains 'Setup')) {
  try {
    Write-Verbose "Starting from $HighlightJsDir"
    Set-Location $HighlightJsDir
    Invoke-Npm install --save-dev
    Invoke-Npm audit fix
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
    Invoke-Npm -Verbose run build
    if (-not ($HighlightJs -contains 'SkipTests')) {
      try {
        Invoke-Npm -Passthru -Verbose run test-markup
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
    Invoke-Node tools/build.js hugo-html hugo-text -t cdn
    Invoke-Node tools/build.js hugo-html hugo-text -t cdn
  } catch {
    Write-Error "build Highlight.JS modules failed" -ErrorAction Continue
    throw $_
  } finally {
    Set-Location $startCWD
  }
}
try {
  $StyleTargetFolder = Test-Folder -Path $HighlightJsDir "build/styles"
  $StyleSourceFile = Test-File -Path $ProjectRoot "scripts/hugen/assets/templates/src/styles/debug-h4h.css"
  $DeveloperHtmlFile = Test-File -Path $HighlightJsDir "tools/developer.html"
  Write-Verbose "Add custom CSS style and patch developer.html - use it from work/developer.html"
  # add custom debugging style
  Copy-Item -Force $StyleSourceFile $StyleTargetFolder
  & node $ProjectRoot/scripts/gen_style-options.js
    $devhtml = Get-Content -Raw -Encoding utf8 $DeveloperHtmlFile
    $devhtml = $devhtml -replace '(?s)(<select class="theme">.*?</select>)', '$1<script src="../work/style-options.js"></script>'
    $devhtml = $devhtml.Replace(
      "../src/styles/", "../highlight.js/build/styles/").Replace(
      "../build/", "../highlight.js/build/").Replace(
      "vendor/", "../highlight.js/tools/vendor/"
    )
    ($devhtml -join "`n") | Set-Content -Encoding utf8 -NoNewline (Join-Path $WorkDir developer.html)
} catch {
  Write-Error "install extra CSS failed" -ErrorAction Continue
  throw $_
} finally {
  Set-Location $startCWD
}

try {
  Set-Location $startCWD
  $PluginSourceFolder = Test-Folder $HighlightJsExtraDir "hugo-text\dist"
  $PluginTargetFolder = Test-Folder $HighlightJsExtraDir "plugins\discourse"
  & "$ProjectRoot\scripts\build-discourse-plugin.ps1" $PluginSourceFolder $PluginTargetFolder -ProjectRoot $ProjectRoot
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
  & "$ProjectRoot\scripts\build-highlightjs-plugin.ps1" $PluginSourceFolder $PluginTargetFolder -ProjectRoot $ProjectRoot
  [void](Test-File $PluginTargetFolder "hugo-highlightjs-plugin.js")
} catch {
  Write-Error "Generation of HighlighJS Plugin failed" -ErrorAction Continue
  throw $_
} finally {
  Set-Location $startCWD
}

if ($HugoModules -contains 'Install') {
  try {
    Write-Verbose "Publish generated Files to Release Folders"
    Set-Location $WorkDir # Safety
    Copy-Item -Recurse -Force "$HighlightJsExtraDir/plugins/*" $PluginDir
    Copy-Item -Recurse -Force "$HighlightJsExtraDir/hugo-html/*" $HugoHtmlDir
    Copy-Item -Recurse -Force "$HighlightJsExtraDir/hugo-text/*" $HugoTextDir
  #  Invoke-Git status
  } catch {
    Write-Error "HighlightJsHugo: failed to get list of changes" -ErrorAction SilentlyContinue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}

Set-Location $startCWD
Write-Host -ForegroundColor Green "Check the Diffs for HugoDocs and highlightjs-hugo"
Write-Host -ForegroundColor Green "DONE."
exit 0