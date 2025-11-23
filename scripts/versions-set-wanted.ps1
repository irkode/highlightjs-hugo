[CmdLetBinding()]
param()
$Script:VersionFailedTest = $false
[void](Test-Path ./.versions.json -ErrorAction Stop)
$Versions = Get-Content -Raw -Path ./.versions.json | ConvertFrom-Json -AsHashtable
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
