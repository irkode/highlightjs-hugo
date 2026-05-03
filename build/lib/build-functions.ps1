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
   } else {
      Write-Verbose "EXEC: $Step"
      try {
         $ExtraDir = Test-Folder -Create $HighlightJsDir "extra"
         exec node tools/build.js -t cdn @OnlyLanguages
         [void](Test-File $ExtraDir "hugo-embed\dist\hugo-embed.min.js")
         [void](Test-File $ExtraDir "hugo-html\dist\hugo-html.min.js")
         [void](Test-File $ExtraDir "hugo-text\dist\hugo-text.min.js")

         $TargetDir = Test-Folder -Clean -Create $ReleaseDir "highlightjs"
         Get-ChildItem -Directory $ExtraDir | ForEach-Object { Copy-Item -Recurse $_ "$TargetDir/$($_.Name)" }

         exec node tools/build.js -t browser hugo-html hugo-text xml
         Copy-Item "build/highlight.min.js" (Join-Path $ReleaseDir "highlight-hugo.min.js")
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
      $TargetDir = Test-Folder -Create -Clean $ReleaseDir "discourse"
      $SourceDir = Test-Folder $HugenDir "discourse"
      exec hugo --source $SourceDir --destination $TargetDir
      [void](Test-File $TargetDir "hugo-html/discourse/about.json")
      [void](Test-File $TargetDir "hugo-text/discourse/about.json")
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
      exec hugo --source $DocsDir build
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
         if ($LastExitCode) { throw $_ }
         # exec npm audit fix
         # if ($LastExitCode) { throw $_ }
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
         $StyleSourceFile = Test-File -Path $HighlightJsDir "extra/hugo-html/src/styles/debug-hugo.css"
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

         $DevHtmlPage = Get-Content -Raw -Encoding utf8 $DeveloperHtmlFile
         $DevHtmlPage = $DevHtmlPage -replace '(?s)(<select class="theme">.*?</select>)', '$1<script src="style-options.js"></script>'
         $DevHtmlPage = $DevHtmlPage.Replace(
            "../src/styles/", "highlight.js/src/styles/").Replace(
            "../build/", "highlight.js/build/").Replace(
            "vendor/", "highlight.js/tools/vendor/").Replace(
            'default.css"', 'debug-hugo.css"').Replace(
            "'default.css'", "'debug-hugo.css'"
         )
         ($DevHtmlPage -join "`n") | Set-Content -Encoding utf8 -NoNewline (Join-Path $WorkDir developer.html)
      }
      [void](Test-File $WorkDir developer.html)
   } catch {
      throw $_
   } finally {
      Set-Location $startCWD
   }
}
# TODO: don't delete foreign folders in extra
function generateHugoGrammars {
   [CmdLetBinding()]
   param()
   $TargetDir = Test-Folder -Create -Clean $HighlightJsDir "extra"
   $SourceDir = Test-Folder $HugenDir "grammars"
   $Step = "Generate Highlight.js grammars to $TargetDir"
   try {
      if ($Skip -contains 'generateHugoGrammars') {
         Write-Verbose "SKIP: $Step"
      } else {
         Write-Verbose "CALL: $Step"
         exec hugo --source $SourceDir --destination $TargetDir
      }
      [void](Test-File $TargetDir "h4h-lib\go\grammar.js")
      [void](Test-File $TargetDir "h4h-lib\go\keywords.js")
      [void](Test-File $TargetDir "h4h-lib\hugo\grammar.js")
      [void](Test-File $TargetDir "h4h-lib\hugo\keywords.js")
      [void](Test-File $TargetDir "hugo-embed\src\languages\hugo-embed.js")
      [void](Test-File $TargetDir "hugo-html\src\languages\hugo-html.js")
      [void](Test-File $TargetDir "hugo-text\src\languages\hugo-text.js")
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
      tree (Join-Path $HighlightJsExtraDir "extra")
   } catch {
      Write-Error "Display Changes failed" -ErrorAction Continue
      throw "$_"
   } finally {
      Set-Location $startCWD
   }
}
