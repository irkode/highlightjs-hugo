[CmdLetBinding()]
param(
  [string]$HugoDocs = (Join-Path -Resolve $PSScriptRoot "../hugoDocs/"),
  [string]$KeywordFile = "hugo-keywords.yaml",
  [string]$DefaultKeywordConfigFile = (Join-Path $PSScriptRoot "_hugo-defaults.yaml"),
  [string]$WorkDir = (Join-Path -Resolve $PSScriptRoot "../work"),
  # overwrite existing target file
  [switch]$Force
)

filter Add-FunctionWord() {
  param(
    [Parameter(Mandatory = $true)]
    [AllowEmptyCollection()]
    [string[]]$KnownWords,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [AllowEmptyString()]
    [string]$Word
  )
  process {
    if ($Word) {
      # don't add predefined keywords
      if (-not $KnownWords.contains($Word)) {
        # word.word is a namespaced function name, a simple word only is an alias (we treat as built_in)
        if ($word.Contains('.')) {
          $Script:KeywordConfig.keywords.function.words += $Word
        } else {
          $Script:KeywordConfig.keywords.built_in.words += $Word
        }
      }
    }
  }
}

# make sure $WorkDir exists and is a Folder
if (-not (Test-Path $WorkDir -PathType Container)) {
  Write-Error "`$WorkDir is not a folder [ $WorkDir ]"
}
$KeywordPath = Join-Path $WorkDir $KeywordFile

if ((Test-Path $KeywordPath) -and (-not $Force)) {
  Write-Error "KeywordFile exists at $KeywordPath. Use -Force to overwrite"
  exit 1
}

# load default keywords from given file or create empty dummy
if (Test-Path -PathType Leaf $DefaultKeywordConfigFile) {
  Write-Verbose "load initial keywords from $DefaultKeywordConfigFile"
  $Script:KeywordConfig = Get-Content $DefaultKeywordConfigFile | ConvertFrom-Yaml
} else {
  Write-Warning "No Keyword file found at [$DefaultKeywordConfigFile]"
  Write-Verbose "generate default Hugo keywords"
  $Script:KeywordConfig = @{
    config   = @{ relevance = 8 }
    keywords = {
      literal = @{
        words    = @("false", "nil", "true")
        relevant = @()
      }
      keyword = @{
        words    = @("block", "break", "continue", "define", "else", "end", "if", "range", "return", "template", "try", "with")
        relevant = @()
      }
    }
  }
}
# make sure all needed keyword classes exist
@('built_in', 'function', 'keyword', 'literal') | ForEach-Object {
  if (-not ($Script:KeywordConfig.keywords.ContainsKey($_))) {
    if ("function" -eq $_) {
      $Script:KeywordConfig.keywords.Add($_, @{ words = @('HjsHugoDummy.HjsHugoDummy|0'); relevant = @() })
    } else {
      $Script:KeywordConfig.keywords.Add($_, @{ words = @(); relevant = @() })
    }
  }
}

# collect predefined keywords from config ignoring appended relevance
$PredefinedKeywords = $KeywordConfig.keywords.built_in.words +
$KeywordConfig.keywords.function.words +
$KeywordConfig.keywords.keyword.words +
$KeywordConfig.keywords.literal.words | ForEach-Object { ($_ -split '\|')[0] }

# load functions and aliases from HugoDocs repo
if ($HugoDocs) {
  try {
    $HugoDocsFunctions = Join-Path -Resolve -Path $HugoDocs -ChildPath "content/en/functions" -ErrorAction Stop
  } catch {
    Write-Error "Hugo documentation not found at [ $HugoDocs ]" -ErrorAction Continue
    exit 1
  }
  Write-Verbose "Collecting files from $HugoDocsFunctions"
  Get-ChildItem $HugoDocsFunctions -Recurse -File -Exclude _index*, _common* *.md | Where-Object {
    $_.FullName -notlike "*_common*"
  } | ForEach-Object {
    $docsMdFile = $_
    Write-Verbose "> $docsMdFile"
    $content = Get-Content -Raw -Encoding UTF8 -Path $docsMdFile.FullName
    if ($Content -match '(?s)^---(.*?)---') {
      $json = $Matches[1] | ConvertFrom-Yaml -Ordered
      # collect alias and function from docs Page
      $json.title, $json.params.functions_and_methods.aliases | ForEach-Object { $_ }
    } else {
      Write-Warning "No yaml header in $($docsMdFile.FullName)"; exit
    }
    # add to specific section
  }  | Add-FunctionWord -KnownWords $PredefinedKeywords
} else {
  Write-Verbose "Hugo documentation not included"
}

try {
  Write-Verbose "create keyword file at $KeywordPath"
  foreach ($Scope in @('literal', 'keyword', 'built_in', 'function')) {
    Write-Verbose ("> {0,03} ${scope}s" -f $KeywordConfig.keywords."$Scope".words.Count)
  }

  $Script:KeywordConfig.keywords | ConvertTo-Yaml | Set-Content -Encoding utf8 $KeywordPath
} catch {
  throw $_
}
exit 0
