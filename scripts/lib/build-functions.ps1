function buildHighlightJS {
  [CmdLetBinding()]
  param()
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
}

function buildHighlightJSDiscourse {
  [CmdLetBinding()]
  param()
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
}

function buildHighlightJSPlugin {
  [CmdLetBinding()]
  param()
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
}

function cloneHighlightJS {
  [CmdLetBinding()]
  param()
  try {
    if ($Skip -contains 'CloneHighlightJS') {
      Write-Verbose "HighlightJS: clone ...SKIPPED"
    } else {
      Set-Location $WorkDir
      if (-Not (Test-Path $HighlightJsDir -PathType Container)) {
        exec git clone --single-branch --depth 1 "-b" $HighlightJsVersion https://github.com/highlightjs/highlight.js.git
      } else {
        Write-Warning "HighlightJS: keep current clone. To fresh up remove $HighLightJsDir"
      }
    }
    [void](Test-Folder $HighLightJsExtraDir)
    $needsInstall = -Not (Test-Path (Join-Path -Path $HighlightJsDir -ChildPath "node_modules"))
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
}

function cloneHugoModules {
  [CmdLetBinding()]
  param()
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
}

function developerBuild {
  [CmdLetBinding()]
  param()
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
}
function generateHugoModules {
  [CmdLetBinding()]
  param()
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
}

function publish {
  [CmdLetBinding()]
  param()
  try {
    if ($Publish -or $PublishOnly) {
      Write-Verbose "Publish generated Files"
      [void](Test-Folder $PublishDir)
      Set-Location $PublishDir -ErrorAction Stop # Safety
      Remove-Item -Recurse -Force *

      $target = Test-Folder -Create -Path $PublishDir -ChildPath plugins
      Copy-Item -Recurse -Force "$HighlightJsExtraDir/plugins/*" $target

      $target = Test-Folder -Create -Path $PublishDir -ChildPath hugo-html
      Copy-Item $HighlightJsExtraDir/hugo-html/* $target

      $target = Test-Folder -Create -Path $PublishDir -ChildPath hugo-text
      Copy-Item $HighlightJsExtraDir/hugo-text/* $target
    }
  } catch {
    Write-Error "$_`Installing to $PublishDir failed" -ErrorAction Continue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}

function showStatus {
  [CmdLetBinding()]
  param()
  try {
    "===== hugo html =====================================" | Out-Host
    Set-Location $HighlightJsExtraDir\hugo-html
    exec git status
    "===== hugo text =====================================" | Out-Host
    Set-Location $HighlightJsExtraDir\hugo-text
    exec git status
    "===== MAIN Repo ======================================" | Out-Host
    Set-Location $ProjectRoot
    exec git status
  } catch {
    Write-Error "Display Changes failed" -ErrorAction Continue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }

}

function updateHugoDocs {
  [CmdLetBinding()]
  param()
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
}
