function exec {
  Write-Verbose "exec > $($args -join ' ')"
  $rc = 0; $throwed = $false
  try {
    Invoke-Expression ($args -join " ")
    $rc = $LASTEXITCODE
  } catch {
    $throwed = $_
  } finally {
    if ($throwed) {
      $line = $MyInvocation.ScriptLineNumber
      $file = Split-Path -Leaf $MyInvocation.ScriptName
      Write-Error "[${file}:${line}] EXEC throwed: $throwed" -ErrorAction Stop
    } elseif ($rc) {
      $line = $MyInvocation.ScriptLineNumber
      $file = Split-Path -Leaf $MyInvocation.ScriptName
      if ($rc -ge 128) { $rc -= 128 }
      Write-Error "[${file}:${line}] EXEC failed with [RC:$rc] : [ $args ]" -ErrorAction Stop
    }
  }
}

function Test-File {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, Position=0)][string]$Path,
    [Parameter(Mandatory=$false, Position=1)][string]$ChildPath = ""
  )
  try {
    $testPath = if ($ChildPath) {Join-Path $Path $ChildPath} else { $Path }
    Write-Verbose "Test-File: $testPath"
    $testPath = Resolve-Path -Path $testPath -ErrorAction Stop
    if (Test-Path -PathType Leaf -Path $testPath) {
      return $testPath
    }
    Write-Error "Path [ $Path ] is not a file"
  } catch {
    Write-Error "Path [ $Path ] does not exist or is not a file"
    throw "$_"
  }
}

function Test-Folder {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, Position=0)][string]$Path,
    [Parameter(Mandatory=$false, Position=1)][string]$ChildPath = "",
    [Parameter(Mandatory=$false)][switch]$CreateIfMissing

  )
  try {
    $testPath = if ($ChildPath) {Join-Path $Path $ChildPath} else { $Path }
    Write-Verbose "Test-Folder: $testPath"
    If ($TestPath) {
      If (-Not (Test-Path $testPath)) {
        if ($CreateIfMissing) {
          Write-Verbose "Create Folder: $testPath"
          [void](New-Item -Type Directory $testPath -ErrorAction Stop)
        } else {
          Write-Error "Path [ $Path ] does not exist, is not a folder or creation failed"
          throw "$_"
        }
      }
      $testPath = Resolve-Path -Path $testPath -ErrorAction Stop
      If (Test-Path -PathType Container -Path $testPath) {
        return $testPath
      }
      Write-Error "Path [ $testPath ] is not a folder"
    } else {
      Write-Error "Path [ $testPath ] may not be empty"
      throw "$_"
    }
  } catch {
    Write-Error "Path [ $testPath ] does not exist, is not a folder or creation failed"
    throw "$_"
  }
}
