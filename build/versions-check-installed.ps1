# Exit codes let a caller pick its own policy without a switch:
#   0  everything as wanted
#   1  some tool has another version than wanted  (warning - the developer may want that)
#   2  some tool is not installed at all          (error - nothing can be built)
# CI treats any non-zero as a failure; build.ps1 only aborts on 2.
[CmdLetBinding()]
param(
  [Parameter(Mandatory = $true)][String]$VersionConfigFile = ".versions.json",
  [Parameter(Mandatory = $false)][string[]]$Tools
)
$VersionTestFailed = $false
$ToolMissing = $false
[void](Test-Path $VersionConfigFile -ErrorAction Stop)
$Versions = Get-Content -Raw -Path $VersionConfigFile | ConvertFrom-Json -AsHashtable
$Versions.Keys | ForEach-Object {
  if ($_.StartsWith('!')) {
    $key = $_.Replace('!', '')
    if ((-not $Tools) -or ($Tools -and ($Tools -contains $key))) {
      $wantedVersion = [System.Environment]::GetEnvironmentVariable($($key.ToUpper() + "_VERSION"))
      if (Get-Command $key -ErrorAction SilentlyContinue) {
        $installedVersion = switch ($key) {
          "go" { (go version) -replace '^.*go(\d+\.\d+\.\d+).*$', '$1'; break }
          "hugo" { ((hugo version) -join '') -replace '(?s).*hugo v(\d+\.\d+\.\d+).*', '$1'; break }
          "node" { $(node --version) -replace '^v(.*)$', '$1'; break }
          default { throw "unsupported executable: $key" }
        }
        if ($installedVersion -ne $wantedVersion) {
          # a warning, not verbose: which tool differs has to be visible on a plain run
          Write-Warning ("{0,-8} version is {1,10} but we want {2,10}" -f $key, $installedVersion, $wantedVersion)
          $Script:VersionTestFailed = $true
        } else {
          Write-Verbose ("OK:   {0,-8} version is {1,10}" -f $key, $installedVersion)
        }
      } else {
        # -ErrorAction Continue keeps the loop going so one run lists every missing tool:
        # callers set $ErrorActionPreference to Stop, which would abort on the first one
        Write-Error ("{0,-8} is not installed. We need version {1,10}" -f $key, $wantedVersion) -ErrorAction Continue
        $Script:VersionTestFailed = $true
        $Script:ToolMissing = $true
      }
    }
  }
}

if ($ToolMissing) {
  Write-Host -ForegroundColor red "ERROR: Some tools are not installed!"
  exit 2
} elseif ($VersionTestFailed) {
  # not an error here: the exit code says what happened, the caller decides if it is fatal
  Write-Warning "Some versions are not as expected!"
  exit 1
}
