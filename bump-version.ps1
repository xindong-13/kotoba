# Bump the service worker cache version for this app.
# Auto-detects lines like:   const CACHE = 'kotoba-v6';   or   const VERSION = 'dq-v10';
$ErrorActionPreference = 'Stop'
$p = Join-Path $PSScriptRoot 'sw.js'
if (-not (Test-Path $p)) { Write-Host '  [skip] sw.js not found'; exit 0 }
$c = Get-Content -Raw -Encoding UTF8 $p
$rx = "(?m)^(\s*const\s+(?:CACHE|VERSION)\s*=\s*')([A-Za-z]+)-v(\d+)(';)"
$m = [regex]::Match($c, $rx)
if ($m.Success) {
  $n = [int]$m.Groups[3].Value + 1
  $name = $m.Groups[2].Value
  $c = [regex]::Replace($c, $rx, ('${1}${2}-v' + $n + '${4}'))
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($p, $c, $utf8)
  Write-Host "  sw.js cache version -> $name-v$n"
} else {
  Write-Host '  [skip] could not find the cache version line in sw.js'
}
