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
        catch { if (-not $IgnoreMarkupErrors) { throw $_ } }
      }
      exec node tools/build.js hugo-embed hugo-html hugo-text -t cdn
    }
    [void](Test-File $HighlightJsExtraDir "hugo-embed\dist\hugo-embed.min.js")
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

function buildDiscoursePlugin {
  [CmdLetBinding()]
  param()
  # Write-Warning "DISABLED: buildDiscoursePlugin"; return
  try {
    Set-Location $startCWD
    $PluginTargetFolder = Test-Folder -Create "$DistributionDir"
    Set-Location $HugoGenDir
    exec hugo -d $PluginTargetFolder --renderSegments discourse
    [void](Test-File $PluginTargetFolder "discourse/hugo-html/about.json")
    [void](Test-File $PluginTargetFolder "discourse/hugo-text/about.json")
  } catch {
    Write-Error "Generation of Discourse Plugin failed" -ErrorAction Continue
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
      if (-not (Test-Path $HighlightJsDir -PathType Container)) {
        exec git clone --single-branch --depth 1 "-b" ${ENV:HIGHLIGHTJS_VERSION} https://github.com/highlightjs/highlight.js.git
      } else {
        Write-Warning "HighlightJS: keep current clone. To fresh up remove $HighLightJsDir"
      }
    }
    [void](Test-Folder $HighlightJsDir)
    $needsInstall = -not (Test-Path (Join-Path -Path $HighlightJsDir -ChildPath "node_modules"))
    if ($NeedsInstall -or ($Force -contains 'SetupHighlightJS')) {
      Set-Location $HighlightJsDir
      exec npm install --save-dev
      if ($LASTEXITCODE) { throw $_ }
      exec npm audit fix
      if ($LASTEXITCODE) { throw $_ }
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


# create a patched version of developer.html
# - copy custom styles
# - create custom option reader to display them
# TODO: check if just css copy is enough
#       at least they have to be patched before build
#
# reasoning: Highlight.js build does not collect custom styles from extra modules
function developerBuild {
  [CmdLetBinding()]
  param()
  try {
    if ($Skip -contains 'DeveloperBuild') {
      Write-Verbose "Skip Developer/Test Build"
    } else {
      $StyleTargetFolder = Test-Folder -Path $HighlightJsDir "src/styles"
      $StyleSourceFile = Test-File -Path $HighlightJsExtraDir "hugo-html/src/styles/debug-hugo.css"
      $DeveloperHtmlFile = Test-File -Path $HighlightJsDir "tools/developer.html"
      Write-Verbose "Add custom CSS style and patch developer.html - use it from work/developer.html"
      # add custom debugging style
      Copy-Item -Force $StyleSourceFile $StyleTargetFolder
      $styleSheets = (Get-ChildItem $StyleTargetFolder *.css | ForEach-Object { "'$($_.Name)'" }) -join ','
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
    Set-Location $HighlightJsDir
    exec node tools/build.js -t browser hugo-embed hugo-html hugo-text xml

  } catch {
    throw $_
  } finally {
    Set-Location $startCWD
  }
}
function generateHugoGrammars {
  [CmdLetBinding()]
  param()
  try {
    if ($Skip -contains 'GenerateModules') {
      Write-Verbose "HugoModules: Generate Highlight.js grammars to $HighlightJsExtraDir"
    } else {
      Set-Location $HugoGenDir
      exec hugo -d $HighlightJsExtraDir --cleanDestinationDir --renderSegments grammars
    }
    [void](Test-File $HighlightJsExtraDir "hugo-embed\src\languages\hugo-embed.js")
    [void](Test-File $HighlightJsExtraDir "hugo-lib\hugo-grammar.js")
    [void](Test-File $HighlightJsExtraDir "hugo-lib\hugo-keywords.js")
    [void](Test-File $HighlightJsExtraDir "hugo-html\src\languages\hugo-html.js")
    [void](Test-File $HighlightJsExtraDir "hugo-text\src\languages\hugo-text.js")
  } catch {
    Write-Error "HugoModules: generate Highlight.js grammars failed" -ErrorAction Continue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}

function distributeHighLightJSBuildResults {
  [CmdLetBinding()]
  param()
  try {
    Set-Location $HugoGenDir
    exec hugo -d $DistributionDir --renderSegments dist
  } catch {
    Write-Error "$_`Distribution of HighlightJS Build Results to $DistributionDir failed" -ErrorAction Continue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}
function distribute {
  [CmdLetBinding()]
  param()
  try {
    Write-Verbose "Distribute build results"
    [void](Test-Folder $DistributionDir)
    Set-Location $DistributionDir -ErrorAction Stop # Safety
    Remove-Item -Recurse -Force *

    Get-ChildItem -Directory $HighlightJsExtraDir | Copy-Item -Recurse -Destination .
  } catch {
    Write-Error "$_`Distribution to $DistributionDir failed" -ErrorAction Continue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}

function showStatus {
  [CmdLetBinding()]
  param()
  try {
    tree $HighlightJsExtraDir
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
      $current = exec git submodule status --cached hugoDocs
      $updated = exec git submodule status hugoDocs
      if ($current -ne $updated) {
        Write-Warning "HugoDocs submodule changed: [ $current ] => [ $updated ]"
      }
      if ($updated -match '^\+') {
        Write-Warning "HugoDocs submodule updated verify keywords after generation!"
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
