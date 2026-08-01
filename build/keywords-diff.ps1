<#
.SYNOPSIS
   Compare two sets of extracted hugoDocs keyword files and report what changed.

.DESCRIPTION
   `hugen/hugodocs` scrapes the hugoDocs module and emits one JSON file per language
   (`go.json`, `hugo.json`) holding `scopes` (scope -> word list) and `builtinAliases`
   (function name -> alias list).

   The scopes in that file are shaped for the highlight.js grammar, not for humans:
   `FUNCTIONS` holds the namespaced names (`cast.ToFloat`), `BUILTINS` holds everything
   without a namespace, which mixes the alias words (`float`) in with the fixed seed
   keywords (`and`, `len`, ...). Reporting that split would list every function twice,
   once under its own name and once under its alias.

   So this script normalizes both sides into one entry per real thing before diffing:

     type      source
     ------    -----------------------------------------------------------------
     function  a key of builtinAliases; its aliases become the Alias column
     keyword   a word in the KEYWORDS scope
     literal   a word in the LITERALS scope
     builtin   a BUILTINS word that is neither an alias nor a function name, i.e.
               the fixed seed list from hugen/hugodocs/data/scopes/*.yaml

   The FUNCTIONS scope needs no rule of its own - it is fully covered by the
   builtinAliases keys.

   This is the single diff implementation used by:
     - the local build      (build/lib/build-functions.ps1, via keywords-check.ps1)
     - CI                   (.github/workflows/_build-core.yaml, upstream notice)
     - the release job      (.github/workflows/build-n-release.yaml, "## Keyword changes")

   The script never fails a build: a missing old directory is treated as "no baseline",
   and the exit code is always 0. Callers inspect the returned object.

.OUTPUTS
   PSCustomObject with Changed (bool), AddedCount, RemovedCount, ChangedCount, HasBaseline
   and Text (the rendered Markdown, also written to -OutFile when given).

.EXAMPLE
   .\build\keywords-diff.ps1 -OldDir hugen\_keywords -NewDir work\hugodocs\keywords

.EXAMPLE
   .\build\keywords-diff.ps1 -OldDir work\prev-keywords -NewDir hugen\_keywords `
      -Format Markdown -OutFile keywords-section.md
#>
[CmdLetBinding()]
param(
   # directory holding the baseline <lang>.json files (may be missing or empty)
   [Parameter(Mandatory = $true)][string]$OldDir,
   # directory holding the current <lang>.json files
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
   # cap the rows per language so a huge diff cannot blow up the 65k character limit
   # of a GitHub release body
   [Parameter(Mandatory = $false)][int]$MaxRows = 60,
   [Parameter(Mandatory = $false)][string[]]$Languages = @('go', 'hugo')
)

$ErrorActionPreference = 'Stop'

# set when at least one file was read from -OldDir; distinguishes "nothing changed"
# from "there is no baseline to compare against" (first release with a snapshot)
$script:foundBaseline = $false

# render order of the Type column - rarest and most fundamental first
$typeOrder = @{ keyword = 0; literal = 1; builtin = 2; function = 3 }
$statusOrder = @{ added = 0; removed = 1; changed = 2 }

function Get-KeywordEntries {
   <# Normalize one <lang>.json into an ordered map of "type|name" -> entry. #>
   param([string]$Dir, [string]$Lang, [switch]$IsBaseline)

   $entries = [ordered]@{}
   $path = Join-Path $Dir "$Lang.json"
   if (-not (Test-Path -PathType Leaf -Path $path)) {
      Write-Verbose "keywords-diff: no such file, treating as empty: $path"
      return $entries
   }
   try {
      $json = Get-Content -Raw -Path $path | ConvertFrom-Json -AsHashtable
   } catch {
      # a corrupt file must not break a release build -- report it and carry on
      Write-Warning "keywords-diff: cannot parse [$path]: $_"
      return $entries
   }
   if ($IsBaseline) { $script:foundBaseline = $true }

   $scopes = if ($json.scopes) { $json.scopes } else { @{} }
   $aliasMap = if ($json.builtinAliases) { $json.builtinAliases } else { @{} }

   # every function, with its alias list (usually empty, sometimes one or two)
   $aliasWords = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
   foreach ($name in $aliasMap.Keys) {
      foreach ($a in @($aliasMap[$name])) { if ($a) { [void]$aliasWords.Add($a) } }
      $entries["function|$name"] = [PSCustomObject]@{
         Type  = 'function'
         Name  = $name
         Alias = @($aliasMap[$name] | Where-Object { $_ } | Sort-Object)
      }
   }

   foreach ($pair in @(@('KEYWORDS', 'keyword'), @('LITERALS', 'literal'))) {
      foreach ($word in @($scopes[$pair[0]])) {
         if (-not $word) { continue }
         $entries["$($pair[1])|$word"] = [PSCustomObject]@{ Type = $pair[1]; Name = $word; Alias = @() }
      }
   }

   # what is left in BUILTINS once aliases and function names are accounted for:
   # the fixed seed list from hugen/hugodocs/data/scopes/<lang>.yaml
   foreach ($word in @($scopes['BUILTINS'])) {
      if (-not $word) { continue }
      if ($aliasWords.Contains($word) -or $aliasMap.ContainsKey($word)) { continue }
      $entries["builtin|$word"] = [PSCustomObject]@{ Type = 'builtin'; Name = $word; Alias = @() }
   }

   return $entries
}

function Format-Alias {
   param([string[]]$Alias)
   if (-not $Alias -or $Alias.Count -eq 0) { return '' }
   return (@($Alias | ForEach-Object { "``$_``" }) -join ', ')
}

# ---------------------------------------------------------------------------
# collect the differences
# ---------------------------------------------------------------------------
$addedTotal = 0
$removedTotal = 0
$changedTotal = 0
$report = @()   # one entry per language that changed

foreach ($lang in $Languages) {
   $old = Get-KeywordEntries -Dir $OldDir -Lang $lang -IsBaseline
   $new = Get-KeywordEntries -Dir $NewDir -Lang $lang
   $rows = @()

   foreach ($key in $new.Keys) {
      if (-not $old.Contains($key)) {
         $rows += [PSCustomObject]@{
            Type = $new[$key].Type; Name = $new[$key].Name
            Alias = Format-Alias $new[$key].Alias; Status = 'added'
         }
         continue
      }
      # same thing on both sides - the only thing that can still differ is its aliases
      $before = @($old[$key].Alias) -join ', '
      $after = @($new[$key].Alias) -join ', '
      if ($before -ne $after) {
         $shown = if ($before -and $after) { "$(Format-Alias $old[$key].Alias) -> $(Format-Alias $new[$key].Alias)" }
         elseif ($after) { Format-Alias $new[$key].Alias }
         else { "(was $(Format-Alias $old[$key].Alias))" }
         $rows += [PSCustomObject]@{
            Type = $new[$key].Type; Name = $new[$key].Name; Alias = $shown; Status = 'changed'
         }
      }
   }
   foreach ($key in $old.Keys) {
      if ($new.Contains($key)) { continue }
      $rows += [PSCustomObject]@{
         Type = $old[$key].Type; Name = $old[$key].Name
         Alias = Format-Alias $old[$key].Alias; Status = 'removed'
      }
   }

   if ($rows.Count -eq 0) { continue }
   $rows = @($rows | Sort-Object `
      @{ Expression = { $statusOrder[$_.Status] } }, `
      @{ Expression = { $typeOrder[$_.Type] } }, `
      @{ Expression = { $_.Name } })

   $addedTotal += @($rows | Where-Object Status -EQ 'added').Count
   $removedTotal += @($rows | Where-Object Status -EQ 'removed').Count
   $changedTotal += @($rows | Where-Object Status -EQ 'changed').Count
   $report += @{ lang = $lang; rows = $rows }
}

# with no baseline every entry looks "added" -- that is noise, not a change report
if (-not $script:foundBaseline) {
   $report = @()
   $addedTotal = 0
   $removedTotal = 0
   $changedTotal = 0
}
$changed = $report.Count -gt 0

$summary = "$addedTotal added, $removedTotal removed"
if ($changedTotal) { $summary += ", $changedTotal alias change(s)" }

# ---------------------------------------------------------------------------
# render Markdown (always built -- Console output is derived from the same data)
# ---------------------------------------------------------------------------
$md = @($Heading, '')
if (-not $script:foundBaseline) {
   $md += '_No keyword baseline available to compare against._'
} elseif (-not $changed) {
   $md += '_No keyword changes._'
} else {
   foreach ($entry in $report) {
      if ($report.Count -gt 1) { $md += @("### $($entry.lang)", '') }
      $md += '| Type | Name | Alias | Status |'
      $md += '| --- | --- | --- | --- |'
      foreach ($row in @($entry.rows | Select-Object -First $MaxRows)) {
         $md += "| $($row.Type) | ``$($row.Name)`` | $($row.Alias) | $($row.Status) |"
      }
      $rest = $entry.rows.Count - [Math]::Min($entry.rows.Count, $MaxRows)
      if ($rest -gt 0) { $md += @('', "_... and $rest more._") }
      $md += ''
   }
}
$text = ($md -join "`n").TrimEnd() + "`n"

# ---------------------------------------------------------------------------
# emit
# ---------------------------------------------------------------------------
switch ($Format) {
   'Markdown' { Write-Host $text }
   'Console' {
      if (-not $script:foundBaseline) {
         Write-Host -ForegroundColor Yellow "keywords: no baseline found in $OldDir - nothing to compare"
      } elseif (-not $changed) {
         Write-Host -ForegroundColor Green "keywords: no changes ($NewDir vs $OldDir)"
      } else {
         Write-Host -ForegroundColor Yellow "keywords: $summary ($NewDir vs $OldDir)"
         foreach ($entry in $report) {
            Write-Host -ForegroundColor Cyan "  [$($entry.lang)]"
            foreach ($row in $entry.rows) {
               $mark, $color = switch ($row.Status) {
                  'added' { '+', 'Green' }
                  'removed' { '-', 'Red' }
                  default { '~', 'Yellow' }
               }
               $alias = if ($row.Alias) { " (alias: $($row.Alias -replace '`', ''))" } else { '' }
               Write-Host -ForegroundColor $color "    $mark $($row.Type) $($row.Name)$alias"
            }
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
   HasBaseline  = $script:foundBaseline
   AddedCount   = $addedTotal
   RemovedCount = $removedTotal
   ChangedCount = $changedTotal
   Text         = $text
}
