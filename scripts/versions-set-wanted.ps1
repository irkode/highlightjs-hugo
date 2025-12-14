[CmdLetBinding()]
param(
  [Parameter(Mandatory=$true)][String]$VersionConfigFile = ".versions.json"
)
[void](Test-Path $VersionConfigFile -ErrorAction Stop)
$Versions = Get-Content -Raw -Path $VersionConfigFile | ConvertFrom-Json -AsHashtable
$Versions.Keys | ForEach-Object {
  $key = $_.Replace('!', '')
  $source = $Versions[$_]['source']
  $version = $Versions[$_]['version']
  $envVarName = $key.ToUpper() + '_VERSION'
  switch ($key) {
    "go" { $version = (Get-Content $source | select-string "^go (\d+\.\d+\.\d+)").Matches.Groups[1].Value }
    "hugo" { $version = (Get-Content $source).Replace('v', '')}
  }
  Write-Verbose ("Set $envVarName to $version$(if ($source) { " [$source]"})")
  if ($env:GITHUB_ACTIONS) {
    "$envVarName=$version" | Add-Content -Encoding utf8 $env:GITHUB_ENV
    switch ($key) {
      "node" { '{"engines": { "node": "' + $version + '"}}' | Set-Content -encoding utf8 .node.package.json }
    }
  } else {
    [System.Environment]::SetEnvironmentVariable($envVarName, $version)
  }
}
