<#
.SYNOPSIS
  Verifies that the installed tools match the versions the project wants.

.DESCRIPTION
  Checks every '!'-prefixed entry of .versions.json against what is actually on PATH, comparing
  with the <TOOL>_VERSION variables that versions-set-wanted.ps1 exported. Exits 1 if anything is
  missing or mismatched, so CI and build.ps1 stop before producing output with the wrong toolchain.

  This script only reports - it never installs and never changes PATH. Where the tools come from is
  the machine's business (hvm, fnm, a package manager, or an actions/setup-* step on CI).

  Version detection is exact for go, hugo and node; any other tool is probed generically with
  '<command> --version' and the first semver in the output. Use the "command" key in
  .versions.json when the executable name differs from the tool name (e.g. "dart-sass" -> "sass").

.PARAMETER VersionConfigFile
  Path to .versions.json.

.PARAMETER Tools
  Limit the check to these tool names (the key without '!').

.PARAMETER PassThru
  Emit one object per tool: Tool, Command, Wanted, Installed, Status (OK / MISMATCH / MISSING).
  The exit code is unchanged.

.EXAMPLE
  ./build/versions-check-installed.ps1 -Verbose -VersionConfigFile .versions.json

.EXAMPLE
  ./build/versions-check-installed.ps1 .versions.json -PassThru | Where-Object Status -ne OK
#>
[CmdLetBinding()]
param(
  [Parameter(Mandatory = $true)][String]$VersionConfigFile = ".versions.json",
  [Parameter(Mandatory = $false)][string[]]$Tools,
  [Parameter(Mandatory = $false)][switch]$PassThru
)
$VersionTestFailed = $false
[void](Test-Path $VersionConfigFile -ErrorAction Stop)
$Versions = Get-Content -Raw -Path $VersionConfigFile | ConvertFrom-Json -AsHashtable
$Versions.Keys | ForEach-Object {
  if ($_.StartsWith('!')) {
    $key = $_.Replace('!', '')
    if ((-not $Tools) -or ($Tools -and ($Tools -contains $key))) {
      $wantedVersion = [System.Environment]::GetEnvironmentVariable($($key.ToUpper() + "_VERSION"))
      $command = $Versions[$_]['command']
      if (-not $command) { $command = $key }
      $status = 'MISSING'
      $installedVersion = $null
      if (Get-Command $command -ErrorAction SilentlyContinue) {
        $installedVersion = switch ($key) {
          "go" { (go version) -replace '^.*go(\d+\.\d+\.\d+).*$', '$1'; break }
          "hugo" { ((hugo version) -join '') -replace '(?s).*hugo v(\d+\.\d+\.\d+).*', '$1'; break }
          "node" { $(node --version) -replace '^v(.*)$', '$1'; break }
          # anything else: ask the tool and take the first semver it prints
          default {
            $reported = (& $command --version 2>&1) -join ' '
            if ($reported -match '(\d+\.\d+\.\d+)') { $Matches[1] } else { $null }
          }
        }
        if ($installedVersion -ne $wantedVersion) {
          Write-Verbose ("FAIL: {0,-8} version is {1,10} but we want {2,10}" -f $key, $installedVersion, $wantedVersion)
          $Script:VersionTestFailed = $true
          $status = 'MISMATCH'
        } else {
          Write-Verbose ("OK:   {0,-8} version is {1,10}" -f $key, $installedVersion)
          $status = 'OK'
        }
      } else {
        Write-Verbose ("FAIL: {0,-8} is not installed. We need version {1,10}" -f $key, $wantedVersion)
        $Script:VersionTestFailed = $true
      }
      if ($PassThru) {
        [pscustomobject]@{
          Tool      = $key
          Command   = $command
          Wanted    = $wantedVersion
          Installed = $installedVersion
          Status    = $status
        }
      }
    }
  }
}

if ($VersionTestFailed) {
  Write-Host -ForegroundColor red "ERROR: Some Versions are not as expected!"
  exit 1
}
