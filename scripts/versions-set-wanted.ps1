[CmdLetBinding()]
param(
  [Parameter(Mandatory=$true)][String]$VersionConfigFile = ".versions.json"
)
[void](Test-Path $VersionConfigFile -ErrorAction Stop)
$Versions = Get-Content -Raw -Path $VersionConfigFile | ConvertFrom-Json -AsHashtable
$Versions.Keys | ForEach-Object {
  $key = $_.Replace('!', '')
  $envVarName = $key.ToUpper() + '_VERSION'
  Write-Verbose "Set $envVarName to $($Versions[$_])"
  if ($env:GITHUB_ACTIONS) {
    "$envVarName=$($Versions[$_])" | Add-Content -Encoding utf8 $env:GITHUB_ENV
  } else {
    [System.Environment]::SetEnvironmentVariable($envVarName, $Versions[$_])
  }
}
