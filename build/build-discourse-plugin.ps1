[CmdLetBinding()]
param(
  [Parameter(Mandatory = $true)][String]$SourceFolder,
  [Parameter(Mandatory = $true)][String]$TargetFolder,
  [Parameter(Mandatory = $false)][String]$SourceFile = "hugo-text.min.js",
  [Parameter(Mandatory = $false)][String]$TargetFile = "hugo-discourse-plugin.js",
  [Parameter(Mandatory = $false)][String]$ProjectRoot
)

try {

  $SourcePath = Join-Path -Resolve -ErrorAction Stop $SourceFolder -ChildPath $SourceFile
  $TargetFolder = Resolve-Path -ErrorAction Stop $TargetFolder
  $TargetPath = Join-Path $TargetFolder $TargetFile

  $plugin = Get-Content -Raw -Encoding utf8 "$SourcePath"
  #$discourseHeaderPattern = ("(?s)" + [regex]::Escape('(()=>{var e=(()=>{"use strict";return e=>{') + '\s*const')
  $discourseHeaderPattern = "(?s)^.*?\(\(\)=>\{var e=\(\(\)=>(.*)return (\w+)=>\{const"

  $discourseReturnLangPattern = "(?s);(return h\.contains=f,)(.*?)(\s*contains:)(\[n\.COMMENT.*,contains:f)(.*)"
  $PluginSourceCheckSuccess = $false
  if ( $plugin -match $discourseHeaderPattern) {
    # replace header
    #$plugin = $plugin -replace $discourseHeaderPattern, "const hugoLang = function(xml) { return function(e){`nvar"
    $plugin = $plugin -replace $discourseHeaderPattern, 'const hugoLang = function(xml) { return function($2)$1var'
    $plugin = $plugin.Replace('`hugo-text` grammar compiled', '`hugo-discourse` plugin compiled')
    if ( $plugin -match $discourseReturnLangPattern) {
      if ($Matches.Length -eq 1) {
        $vc = $Matches
        $plugin = $plugin -replace $discourseReturnLangPattern, ",vc=$($vc[4])}],vl={case_insensitive:!1,contains:vc};`n"
        $PluginSourceCheckSuccess = $true
      } else {
        Write-Error "To many matches for 'Return language' section in plugin source found - Adapt build script and retry" -ErrorAction Continue
      }
    } else {
      Write-Error "Unmatched 'Return language' section in plugin source found - Adapt build script and retry" -ErrorAction Continue
    }
  } else {
    Write-Error "Unmatched 'Header' section in plugin source found - Adapt build script and retry" -ErrorAction Continue
  }
  if ($PluginSourceCheckSuccess) {
    $plugin = 'import { apiInitializer } from "discourse/lib/api";export default apiInitializer((api) => {' +
    $plugin + 'if (xml) { vl.subLanguage = ["xml"];vl.aliases=["hugo"] }; return l.contains=c,vl; }};' +
    'api.registerHighlightJSLanguage("hugo-html", hugoLang(1));' +
    'api.registerHighlightJSLanguage("hugo-text", hugoLang(0));});' +
    "`n"
    $plugin | Set-Content -Encoding utf8 $TargetPath -Force -NoNewline
    [void](Test-Path -PathType Leaf $TargetPath -ErrorAction Stop)
  } else {
    Write-Error "generate Discourse Plugin failed" -ErrorAction Stop
  }
} catch {
  throw $_
}
