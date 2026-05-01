function testHighlightJS {
   [CmdLetBinding()]
   param()
   $Step = "Test Highlight.js"
   Set-Location $HighlightJsDir
   $EnvOnlyExtra = $ENV:ONLY_EXTRA
   if ($OnlyExtra -eq 'true') { $ENV:ONLY_EXTRA = 'true' } else { $ENV:ONLY_EXTRA = $Null }
   if ($Skip -contains 'TestHighlightJS') {
      Write-Verbose "SKIP: $Step"
   } else {
      Write-Verbose "EXEC: $Step"
      try {
         exec node ./tools/build.js -t node @OnlyLanguages
         exec npm run test-markup
      } catch {
         if (-not $IgnoreMarkupErrors) { throw $_ }
      } finally {
         $ENV:ONLY_EXTRA = $EnvOnlyExtra
         Set-Location $startCWD
      }
   }
}
function buildHighlightJS {
   [CmdLetBinding()]
   param()
   $Step = "Build Highlight.js"
   Set-Location $HighlightJsDir
   $EnvOnlyExtra = $ENV:ONLY_EXTRA
   if ($OnlyExtra -eq 'true') { $ENV:ONLY_EXTRA = 'true' } else { $ENV:ONLY_EXTRA = $Null }
   if ($Skip -contains 'BuildHighlightJS') {
      Write-Verbose "SKIP: $Step"
   } else  {
      Write-Verbose "EXEC: $Step"
      try {
         exec node tools/build.js -t cdn @OnlyLanguages
         [void](Test-File $HighlightJsExtraDir "hugo-embed\dist\hugo-embed.min.js")
         [void](Test-File $HighlightJsExtraDir "hugo-html\dist\hugo-html.min.js")
         [void](Test-File $HighlightJsExtraDir "hugo-text\dist\hugo-text.min.js")
         $HighlightJsTargetDir = (Join-Path $DistributionDir "highlightjs")
         Test-Folder -Create $highlightJsTargetDir
         Copy-Item -Recurse $HighlightJsExtraDir/* $HighlightJsTargetDir -Exclude .keep
         exec node tools/build.js -t browser hugo-html hugo-text xml
         Copy-Item "build/highlight.min.js" (Join-Path $DistributionDir "highlight-hugo.min.js")
      } catch {
         Write-Error "FAIL: $Step failed" -ErrorAction Continue
         throw $_
      } finally {
         $ENV:ONLY_EXTRA = $EnvOnlyExtra
         Set-Location $startCWD
      }
   }
}

function buildDiscoursePlugin {
  [CmdLetBinding()]
  param()
  $Step = "Generate Discourse Plugin"
  try {
    $DistributionDir = Test-Folder -Create $ProjectRoot "release"
    Set-Location $HugoGenDir
    exec hugo -d $DistributionDir --renderSegments discourse
    [void](Test-File $DistributionDir "discourse/hugo-html/discourse/about.json")
    [void](Test-File $DistributionDir "discourse/hugo-text/discourse/about.json")
  } catch {
    Write-Error "FAIL: $Step" -ErrorAction Continue
    throw $_
  } finally {
    Set-Location $startCWD
  }
}
function buildDocs {
  [CmdLetBinding()]
  param()
  $Step = "Generate Documentation"
  try {
    Set-Location $DocsDir
    exec hugo build
  } catch {
    Write-Error "FAIL: $Step" -ErrorAction Continue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}

function cloneHighlightJS {
  [CmdLetBinding()]
  param()
  $Step = "Clone HighlightJS to $HighLightJsDir"
  try {
    if ($Skip -contains 'CloneHighlightJS') {
      Write-Verbose "SKIP: $Step"
    } else {
      Write-Verbose "CALL: $Step"
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
      # exec npm audit fix
      # if ($LASTEXITCODE) { throw $_ }
    }
    [void](Test-Folder $HighLightJsDir\node_modules)
  } catch {
    Write-Error "FAIL: $Step" -ErrorAction Continue
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
    exec node tools/build.js -t browser hugo-html hugo-text xml
    [void](Test-File $HighlightJsDir "build\highlight.min.js")
    $DistributionDir = Test-Folder -Create $ProjectRoot "release\highlightjs-hugo"
    Copy-Item (Join-Path $HighlightJsDir "build\highlight.min.js") (Join-Path $ProjectRoot "release\highlightjs-hugo\highlight-hugo.min.js")
  } catch {
    throw $_
  } finally {
    Set-Location $startCWD
  }
}
function distributeHighLightJSBuildResults {
  [CmdLetBinding()]
  param()
  try {
    Set-Location $startCWD
    $DistributionDir = Test-Folder -Create $ProjectRoot "release"
    Set-Location $HugoGenDir
    exec hugo -d $DistributionDir --renderSegments distribute
  } catch {
    Write-Error "$_`Distribution of HighlightJS Build Results to $DistributionDir failed" -ErrorAction Continue
    throw "$_"
  } finally {
    Set-Location $startCWD
  }
}

function generateHugoGrammars {
  [CmdLetBinding()]
  param()
  $Step = "Generate Highlight.js grammars to $HighlightJsExtraDir"
  try {
    if ($Skip -contains 'generateHugoGrammars') {
      Write-Verbose "SKIP: $Step"
    } else {
      Write-Verbose "CALL: $Step"
      Set-Location (Join-Path $HugenDir "grammars")
      exec hugo -d $HighlightJsExtraDir --cleanDestinationDir
    }
    [void](Test-File $HighlightJsExtraDir "h4h-lib\go\grammar.js")
    [void](Test-File $HighlightJsExtraDir "h4h-lib\go\keywords.js")
    [void](Test-File $HighlightJsExtraDir "h4h-lib\hugo\grammar.js")
    [void](Test-File $HighlightJsExtraDir "h4h-lib\hugo\keywords.js")
    [void](Test-File $HighlightJsExtraDir "hugo-embed\src\languages\hugo-embed.js")
    [void](Test-File $HighlightJsExtraDir "hugo-html\src\languages\hugo-html.js")
    [void](Test-File $HighlightJsExtraDir "hugo-text\src\languages\hugo-text.js")
  } catch {
    Write-Error "FAIL: $Step" -ErrorAction Continue
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
