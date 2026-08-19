# hooks/pre-compact.ps1
# PreCompact hook: sikistirma oncesi hatirlatma + guncel git durumu.

$ErrorActionPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { exit 0 }

Write-Output "## Sikistirma oncesi hatirlatma"
Write-Output "Bu oturumda onemli bir karar veya surpriz varsa, sikistirmadan once /handoff calistirmayi dusun."
Write-Output ""
Write-Output "## git status"
git -C $root status --short 2>$null
Write-Output ""
Write-Output "## git diff --stat"
git -C $root diff --stat 2>$null
