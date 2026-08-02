<#
.SYNOPSIS
   Compare two hugoDocs function extractions and report what changed.

.DESCRIPTION
   `hugen/hugodocs` scrapes the hugoDocs function reference into a single
   `functions.json`, one line per documented function:

      { "cast.ToFloat": { "section": "cast", "aliases": ["float"] }, ... }

   That file holds facts only - no highlight.js scopes - so a diff of it is already
   one row per real thing and needs no normalization. Which scope a name ends up in
   is decided later by hugen/grammars.

   This is the single diff implementation used by:
     - the local build      (build/lib/build-functions.ps1, via keywords-check.ps1)
     - CI                   (.github/workflows/_build-core.yaml, upstream notice)
     - the release job      (.github/workflows/build-n-release.yaml, "## Keyword changes")

   The script never fails a build: a missing old file is treated as "no baseline",
   and the exit code is always 0. Callers inspect the returned object.

.OUTPUTS
   PSCustomObject with Changed (bool), AddedCount, RemovedCount, ChangedCount,
   HasBaseline and Text (the rendered Markdown, also written to -OutFile when given).

.EXAMPLE
   .\build\keywords-diff.ps1 -OldDir hugen\_hugodocs -NewDir work\hugodocs\extract

.EXAMPLE
   .\build\keywords-diff.ps1 -OldDir work\prev-keywords -NewDir hugen\_hugodocs `
      -Format Markdown -OutFile keywords-section.md
#>
[CmdLetBinding()]
param(
   # directory holding the baseline functions.json (may be missing)
   [Parameter(Mandatory = $true)][string]$OldDir,
   # directory holding the current functions.json
   [Parameter(Mandatory = $true)][string]$NewDir,
   [Parameter(Mandatory = $false)][ValidateSet('Console', 'Markdown', 'None')][string]$Format = 'Console',
   [Parameter(Mandatory = $false)][string]$Heading = '## Keyword changes',
   # write the Markdown rendering here (built regardless of -Format)
   [Parameter(Mandatory = $false)][string]$OutFile,
   # append to -OutFile instead of overwriting it
   [Parameter(Mandatory = $false)][switch]$Append,
   # emit a GitHub Actions ::notice:: when something changed
   [Parameter(Mandatory = $false)][switch]$Notice,
   [Parameter(Mandatory = $false)][string]$NoticeTitle = 'hugoDocs keyword changes',
   # cap the rows so a huge diff cannot blow up the 65k character limit of a
   # GitHub release body
   [Parameter(Mandatory = $false)][int]$MaxRows = 60,
   [Parameter(Mandatory = $false)][string]$FileName = 'functions.json'
)

$ErrorActionPreference = 'Stop'

function Read-Functions {
   param([string]$Dir)
   $path = Join-Path $Dir $FileName
   if (-not (Test-Path -PathType Leaf -Path $path)) {
      Write-Verbose "keywords-diff: no such file: $path"
      return $null
   }
   try {
      return Get-Content -Raw -Path $path | ConvertFrom-Json -AsHashtable
   } catch {
      # a corrupt file must not break a release build -- report it and carry on
      Write-Warning "keywords-diff: cannot parse [$path]: $_"
      return $null
   }
}

function Format-Alias {
   param($Alias)
   $list = @($Alias | Where-Object { $_ })
   if ($list.Count -eq 0) { return '' }
   return (@($list | ForEach-Object { "``$_``" }) -join ', ')
}

# ---------------------------------------------------------------------------
# collect the differences
# ---------------------------------------------------------------------------
$old = Read-Functions -Dir $OldDir
$new = Read-Functions -Dir $NewDir
$hasBaseline = $null -ne $old
if (-not $new) { $new = @{} }

$rows = @()
if ($hasBaseline) {
   foreach ($name in $new.Keys) {
      if (-not $old.ContainsKey($name)) {
         $rows += [PSCustomObject]@{
            Section = $new[$name].section; Name = $name
            Alias = Format-Alias $new[$name].aliases; Status = 'added'
         }
         continue
      }
      # same function on both sides - only its aliases (or its section) can differ
      $before = @($old[$name].aliases) -join ', '
      $after = @($new[$name].aliases) -join ', '
      if ($before -ne $after) {
         $shown = if ($before -and $after) { "$(Format-Alias $old[$name].aliases) -> $(Format-Alias $new[$name].aliases)" }
         elseif ($after) { Format-Alias $new[$name].aliases }
         else { "(was $(Format-Alias $old[$name].aliases))" }
         $rows += [PSCustomObject]@{
            Section = $new[$name].section; Name = $name; Alias = $shown; Status = 'changed'
         }
      }
   }
   foreach ($name in $old.Keys) {
      if ($new.ContainsKey($name)) { continue }
      $rows += [PSCustomObject]@{
         Section = $old[$name].section; Name = $name
         Alias = Format-Alias $old[$name].aliases; Status = 'removed'
      }
   }
}

$statusOrder = @{ added = 0; removed = 1; changed = 2 }
$rows = @($rows | Sort-Object `
   @{ Expression = { $statusOrder[$_.Status] } }, `
   @{ Expression = { $_.Section } }, `
   @{ Expression = { $_.Name } })

$addedTotal = @($rows | Where-Object Status -EQ 'added').Count
$removedTotal = @($rows | Where-Object Status -EQ 'removed').Count
$changedTotal = @($rows | Where-Object Status -EQ 'changed').Count
$changed = $rows.Count -gt 0

$summary = "$addedTotal added, $removedTotal removed"
if ($changedTotal) { $summary += ", $changedTotal alias change(s)" }

# ---------------------------------------------------------------------------
# render Markdown (always built -- Console output is derived from the same data)
# ---------------------------------------------------------------------------
$md = @($Heading, '')
if (-not $hasBaseline) {
   $md += '_No keyword baseline available to compare against._'
} elseif (-not $changed) {
   $md += '_No keyword changes._'
} else {
   $md += '| Section | Name | Alias | Status |'
   $md += '| --- | --- | --- | --- |'
   foreach ($row in @($rows | Select-Object -First $MaxRows)) {
      $md += "| $($row.Section) | ``$($row.Name)`` | $($row.Alias) | $($row.Status) |"
   }
   $rest = $rows.Count - [Math]::Min($rows.Count, $MaxRows)
   if ($rest -gt 0) { $md += @('', "_... and $rest more._") }
}
$text = ($md -join "`n").TrimEnd() + "`n"

# ---------------------------------------------------------------------------
# emit
# ---------------------------------------------------------------------------
switch ($Format) {
   'Markdown' { Write-Host $text }
   'Console' {
      if (-not $hasBaseline) {
         Write-Host -ForegroundColor Yellow "keywords: no baseline found in $OldDir - nothing to compare"
      } elseif (-not $changed) {
         Write-Host -ForegroundColor Green "keywords: no changes ($NewDir vs $OldDir)"
      } else {
         Write-Host -ForegroundColor Yellow "keywords: $summary ($NewDir vs $OldDir)"
         foreach ($row in $rows) {
            $mark, $color = switch ($row.Status) {
               'added' { '+', 'Green' }
               'removed' { '-', 'Red' }
               default { '~', 'Yellow' }
            }
            $alias = if ($row.Alias) { " (alias: $($row.Alias -replace '`', ''))" } else { '' }
            Write-Host -ForegroundColor $color "    $mark $($row.Section)/$($row.Name)$alias"
         }
      }
   }
}

if ($OutFile) {
   if ($Append) {
      # keep one blank line between the previous section and ours
      Add-Content -Encoding utf8 -Path $OutFile -Value ("`n" + $text)
   } else {
      Set-Content -Encoding utf8 -NoNewline -Path $OutFile -Value $text
   }
}

if ($env:GITHUB_ACTIONS) {
   if ($env:GITHUB_OUTPUT) {
      "keywords-changed=$($changed.ToString().ToLower())" | Add-Content -Encoding utf8 $env:GITHUB_OUTPUT
      "keywords-added=$addedTotal" | Add-Content -Encoding utf8 $env:GITHUB_OUTPUT
      "keywords-removed=$removedTotal" | Add-Content -Encoding utf8 $env:GITHUB_OUTPUT
   }
   if ($Notice -and $changed) {
      Write-Host "::notice title=$NoticeTitle::$summary - see the job summary for details"
   }
}

return [PSCustomObject]@{
   Changed      = $changed
   HasBaseline  = $hasBaseline
   AddedCount   = $addedTotal
   RemovedCount = $removedTotal
   ChangedCount = $changedTotal
   Text         = $text
}
