[CmdLetBinding()]
param(
  [string]$KeywordFile = "hugo-keywords.yaml",
  [string]$TargetFile = "keywords.js",
  [string]$WorkDir = (Join-Path -Resolve $PSScriptRoot "..\work"),
  [string]$TargetFolder = (Join-Path -Resolve $PSScriptRoot "..\work"),
  # overwrite existing target file
  [switch]$Force,
  # default relevance
  [int]$Relevance = 8,
  # group regex by first word for multi word keywords
  [switch]$DontGroup
)

filter Add-Relevance() {
  param(
    [Parameter(Mandatory = $true)]
    [AllowEmptyCollection()]
    [string[]]$RelevantNames,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$Name
  )
  process {
    $relevant = $RelevantNames | Where-Object { $_ -like "${name}|*" }
    if ($relevant) {
      if ($Script:H4HDebug) { Write-Verbose "$relevant has fixed relevance" }
      return "`"$relevant`""
    } else {
      if ($RelevantNames.Contains($Name)) {
        if ($Script:H4HDebug) { Write-Verbose "$name is relevant with default ($Relevance)" }
        return "`"$Name|$Script:Relevance`""
      }
    }
    return "`"$name`""
  }
}

$ErrorActionPreference = 'Stop'

# make sure $WorkDir exists and is a Folder
if (-not (Test-Path $WorkDir -PathType Container)) {
  Write-Error "`$WorkDir is not a folder [ $WorkDir ]"
}
$WorkDir = Resolve-Path $WorkDir
$KeywordPath = Join-Path -Resolve $WorkDir $KeywordFile
$YamlKeywords = Get-Content $KeywordPath | ConvertFrom-Yaml

$TargetPath = if ($TargetFolder -ne $WorkDir) {
  if (-not (Test-Path $TargetFolder -PathType Container)) {
    Write-Error "`$TargetFolder is not a folder [ $TargetFolder ]"
  }
  Join-Path $TargetFolder $TargetFile
} else {
  Join-Path $WorkDir $TargetFile
}

if ((Test-Path $TargetPath) -and (-not $Force)) {
  Write-Error "TargetFile exists at $TargetPath. Use -Force to overwrite"
  exit 1
}

Write-Verbose "Keyword file : $KeywordPath"
Write-Verbose "Target file  : $TargetPath"
$jsCode = ""

# generate the array or words incl. relevance
foreach ($Scope in @('built_in', 'function', 'keyword', 'literal')) {
  if ($YamlKeywords."$Scope") {
    $ScopeDefinition = $YamlKeywords."$Scope"
    if ($ScopeDefinition.words) {
      $jsCode += "export const $($Scope.ToUpper() + 'S') = [`n  "
      $jsCode += ($ScopeDefinition.words | Group-Object -Property Length | Sort-Object { [int]$_.Name } -Desc | ForEach-Object { $_.Group | Sort-Object -Descending } | Add-Relevance $ScopeDefinition.relevant) -join ",`n  "
      $jsCode += "`n];`n`n"
    } else {
      Write-Warning "$Scope has no words! Check keyword file at: $KeywordFile"
    }
  } else {
    Write-Warning "$Scope is not defined! Check keyword file at: $KeywordFile"
  }
}

# generate regex
foreach ($Scope in @('function')) {
  if ($YamlKeywords."$Scope") {
    $ScopeDefinition = $YamlKeywords."$Scope"
    if ($ScopeDefinition.words) {
      if ($DontGroup) {
        $jsCode += "export const re_$($Scope.ToUpper() + 'S') = /\b(" + ($ScopeDefinition.words -join '|') + ')\b/; ' + "`n"
      } else {
        $FunctionsGrouped = $ScopeDefinition.words | Group-Object { $_.Split('.')[0] } | Sort-Object -Descending { $_.Name.Length } | ForEach-Object {
          $name = $_.Name
          $functions = $_.Group | ForEach-Object { $_.Replace("${name}.", "") } | Sort-Object -Descending -Property Length
          if ($_.Count -eq 1) {
            "${name}\.${functions}"
          } else {
            "${name}\.($($functions -join '|'))"
          }
        }
        $jsCode += "export const re_$($Scope.ToUpper() + 'S') = /\b(" + ($FunctionsGrouped -join '|') + ')\b/; ' + "`n"
      }
    }
  } else {
    Write-Error "No keywords in scope '$Scope' defined"
  }
}

$jsCode.Trim() + "`n" | Set-Content -NoNewline -Force -Encoding utf8 $TargetPath
Write-Output "generated keyword script to $TargetPath"
exit 0
