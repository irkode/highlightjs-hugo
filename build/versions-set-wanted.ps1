<#
.SYNOPSIS
  Resolves the tool versions a project wants and publishes them as <TOOL>_VERSION.

.DESCRIPTION
  Reads .versions.json and exports one environment variable per entry - on GitHub Actions into
  $GITHUB_ENV, locally into the current process. This is the single implementation used by CI,
  by build.ps1 and by local shells, so all three agree on what "the wanted version" means.

  Entry format, keyed by tool name. A leading '!' marks a tool that must be installed and is
  therefore verified by versions-check-installed.ps1; entries without it are just versions the
  build needs to know (highlightjs, for example).

    "version"  literal version string
    "source"   file to read the version out of, relative to .versions.json
    "pattern"  regex with one capture group applied to "source". Defaults: a go.mod style
               "^go <version>" for go, the leading version for hugo, otherwise the first
               semver found in the file
    "command"  executable name when it differs from the key (e.g. "dart-sass" -> "sass").
               Only consumed by versions-check-installed.ps1; reported here for completeness

.PARAMETER VersionConfigFile
  Path to .versions.json.

.PARAMETER Tools
  Limit resolution to these tool names (the key without '!').

.PARAMETER PassThru
  Also emit one object per tool: Tool, EnvVar, Wanted, Raw, Source, Command, Verify.
  Without it the script writes nothing to the pipeline, which is what CI expects.

.EXAMPLE
  ./build/versions-set-wanted.ps1 -Verbose .versions.json

.EXAMPLE
  ./build/versions-set-wanted.ps1 .versions.json -PassThru | Format-Table
#>
[CmdLetBinding()]
param(
  [Parameter(Mandatory = $true)][String]$VersionConfigFile = ".versions.json",
  [Parameter(Mandatory = $false)][string[]]$Tools,
  [Parameter(Mandatory = $false)][switch]$PassThru
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
    $pattern = $Versions[$_]['pattern']
    $command = $Versions[$_]['command']
    $envVarName = $key.ToUpper() + '_VERSION'
    $raw = $null
    if ($Versions[$_]['source']) {
      $raw = (Get-Content -Raw $source).Trim()
      if (-not $pattern) {
        # keep the historic per-tool defaults so an existing .versions.json needs no 'pattern'
        # note for hugo: the edition suffix ('v0.164.0/standard') is dropped on purpose - CI
        # always installs the standard edition
        $pattern = switch ($key) {
          "go" { '(?m)^go\s+(\d+\.\d+\.\d+)'; break }
          default { '(\d+\.\d+\.\d+)' }
        }
      }
      if ($raw -match $pattern) {
        $version = $Matches[1]
      } else {
        throw "no version matching /$pattern/ in $source"
      }
    }
    Write-Verbose ("Set $envVarName to $version$(if ($source) { " [$source]"})")
    if ($env:GITHUB_ACTIONS) {
      "$envVarName=$version" | Add-Content -Encoding utf8 $env:GITHUB_ENV
      switch ($key) {
        # actions/setup-node caches against this file, see .github/workflows/_build-core.yaml
        "node" { '{"engines": { "node": "' + $version + '"}}' | Set-Content -Encoding utf8 .node.package.json }
      }
    } else {
      [System.Environment]::SetEnvironmentVariable($envVarName, $version)
    }
    if ($PassThru) {
      [pscustomobject]@{
        Tool    = $key
        EnvVar  = $envVarName
        Wanted  = $version
        Raw     = $raw
        Source  = if ($Versions[$_]['source']) { $source } else { $null }
        Command = if ($command) { $command } else { $key }
        Verify  = $_.StartsWith('!')
      }
    }
  }
}
