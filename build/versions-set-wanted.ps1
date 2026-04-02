[CmdLetBinding()]
param(
  [Parameter(Mandatory = $true)][String]$VersionConfigFile = ".versions.json",
  [Parameter(Mandatory = $false)][string[]]$Tools
)
[void](Test-Path $VersionConfigFile -ErrorAction Stop)
$VersionConfigFile = Resolve-Path $VersionConfigFile -ErrorAction Stop
$rootDir = Split-Path -Parent $VersionConfigFile
$Versions = Get-Content -Raw -Path $VersionConfigFile | ConvertFrom-Json -AsHashtable
$Versions.Keys | ForEach-Object {
  $key = $_.Replace('!', '')
  if ((-not $Tools) -or ($Tools -and ($Tools -contains $key))) {
    $source = Join-Path -Resolve -Path $rootDir -ChildPath $Versions[$_]['source']
    $version = $Versions[$_]['version']
    $envVarName = $key.ToUpper() + '_VERSION'
    switch ($key) {
      "go" { $version = (Get-Content $source | Select-String "^go (\d+\.\d+\.\d+)").Matches.Groups[1].Value }
      # remove the edition to support latest .hvm file format (we ignore that and always use extended in CI for now)
      "hugo" { $version = ((Get-Content $source).Replace('v', '') -split '/')[0] }
    }
    Write-Verbose ("Set $envVarName to $version$(if ($source) { " [$source]"})")
    if ($env:GITHUB_ACTIONS) {
      "$envVarName=$version" | Add-Content -Encoding utf8 $env:GITHUB_ENV
      switch ($key) {
        "node" { '{"engines": { "node": "' + $version + '"}}' | Set-Content -Encoding utf8 .node.package.json }
      }
    } else {
      [System.Environment]::SetEnvironmentVariable($envVarName, $version)
    }
  }
}
