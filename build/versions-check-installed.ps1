[CmdLetBinding()]
param(
    [Parameter(Mandatory=$true)][String]$VersionConfigFile = ".versions.json"
)
$VersionTestFailed = $false
[void](Test-Path $VersionConfigFile -ErrorAction Stop)
$Versions = Get-Content -Raw -Path $VersionConfigFile | ConvertFrom-Json -AsHashtable
$Versions.Keys | ForEach-Object {
  if ($_.StartsWith('!')) {
    $key = $_.Replace('!', '')
    $wantedVersion = [System.Environment]::GetEnvironmentVariable($($key.ToUpper() + "_VERSION"))
    if (Get-Command $key -ErrorAction SilentlyContinue) {
      $installedVersion = switch ($key) {
        "go" { (go version) -replace '^.*go(\d+\.\d+\.\d+).*$', '$1'; break }
        "hugo" { ((hugo version) -join '') -replace '(?s).*hugo v(\d+\.\d+\.\d+).*', '$1'; break }
        "node" { $(node --version) -replace '^v(.*)$', '$1'; break }
        default { throw "unsupported executable: $key" }
      }
      if ($installedVersion -ne $wantedVersion) {
        Write-Verbose ("FAIL: {0,-8} version is {1,10} but we want {2,10}" -f $key, $installedVersion, $wantedVersion)
        $Script:VersionTestFailed = $true
      } else {
        Write-Verbose ("OK:   {0,-8} version is {1,10}" -f $key, $installedVersion)
      }
    } else {
      Write-Verbose ("FAIL: {0,-8} is not installed. We need version {1,10}" -f $key, $wantedVersion)
      $Script:VersionTestFailed = $true
    }
  }
}

if ($VersionTestFailed) {
  Write-Host -ForegroundColor red "ERROR: Some Versions are not as expected!"
  exit 1
}
