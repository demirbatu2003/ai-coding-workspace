# hooks/session-start.ps1
# SessionStart hook: oturum basinda proje durumunu baglama enjekte eder.
# STATE.md, en yeni handoff ve git durumu yoksa sessizce cikar.

$ErrorActionPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { exit 0 }

$statePath = Join-Path $root "docs\STATE.md"
$handoffsDir = Join-Path $root "docs\handoffs"

if (Test-Path $statePath) {
    Write-Output "## docs/STATE.md"
    Write-Output ""
    Get-Content $statePath -Encoding UTF8
    Write-Output ""
}

if (Test-Path $handoffsDir) {
    $latest = Get-ChildItem $handoffsDir -Filter "*.md" | Sort-Object Name -Descending | Select-Object -First 1
    if ($latest) {
        Write-Output "## En yeni handoff: $($latest.Name)"
        Write-Output ""
        Get-Content $latest.FullName -Encoding UTF8
        Write-Output ""
    }
}

Write-Output "## git log (son 10)"
git -C $root log --oneline -10 2>$null
Write-Output ""

Write-Output "## git status"
git -C $root status --short 2>$null
