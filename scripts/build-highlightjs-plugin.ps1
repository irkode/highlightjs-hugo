[CmdLetBinding()]
param(
  [Parameter(Mandatory = $true)][String]$SourceFolder,
  [Parameter(Mandatory = $true)][String]$TargetFolder,
  [Parameter(Mandatory = $false)][String]$SourceFile = "hugo-html.min.js",
  [Parameter(Mandatory = $false)][String]$TargetFile = "hugo-highlightjs-plugin.js",
  [Parameter(Mandatory = $false)][String]$ProjectRoot
)

try {

  $SourcePath = Join-Path -Resolve -ErrorAction Stop $SourceFolder -ChildPath $SourceFile
  $TargetFolder = Resolve-Path -ErrorAction Stop $TargetFolder
  $TargetPath = Join-Path $TargetFolder $TargetFile

  $plugin = Get-Content -Raw -Encoding utf8 "$SourcePath"
  $HighlightJSEndPattern = [regex]::Escape('})();') + '\s*$'
  $HighlightJSReplacement = ';var e1 = function(hljs){  var def = e(hljs) || {};' +
    'if (def && typeof def === "object") { var clone = Object.assign({}, def);' +
    'if (clone.subLanguage) delete clone.subLanguage;' +
    'if (clone.aliases) delete clone.aliases;' +
    'clone.name = "highlightjs-hugo-text";' +
    'return clone;}return def;};hljs.registerLanguage("hugo-text", e1);})();' +
    "`n"

  $plugin = $plugin -replace $HighlightJSEndPattern, $HighlightJSReplacement

  $plugin | Set-Content -Encoding utf8 $TargetPath -Force -NoNewline
  [void](Test-Path -PathType Leaf $TargetPath -ErrorAction Stop)
} catch {
  Write-Error "generate HighlightJS Plugin failed" -ErrorAction Continue
  throw $_
}
