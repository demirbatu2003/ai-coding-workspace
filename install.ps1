# install.ps1
# ai-coding-workspace hub'ini hedef bir projeye kurar.

param(
    [Parameter(Mandatory=$true)]
    [string]$Target,

    [switch]$Force,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$hubRoot = $PSScriptRoot
$targetPath = Resolve-Path -Path $Target -ErrorAction SilentlyContinue

if (-not $targetPath) {
    Write-Host "HATA: Hedef klasor bulunamadi: $Target" -ForegroundColor Red
    exit 1
}

Write-Host "Hub: $hubRoot"
Write-Host "Hedef: $targetPath"
if ($DryRun) { Write-Host "(DRY RUN - hicbir dosya yazilmayacak)" -ForegroundColor Yellow }

# 1. Git reposu kontrolu
Push-Location $targetPath
$isGitRepo = (git rev-parse --is-inside-work-tree 2>$null) -eq "true"
Pop-Location

if (-not $isGitRepo) {
    Write-Host "UYARI: Hedef bir git reposu degil." -ForegroundColor Yellow
    $answer = Read-Host "Yine de devam edilsin mi? (e/H)"
    if ($answer -ne "e") {
        Write-Host "Iptal edildi."
        exit 0
    }
}

$written = @()
$skipped = @()

# 2. templates/*.tmpl -> hedef dosyalari
$templateMap = @{
    "templates\AGENTS.md.tmpl"     = "AGENTS.md"
    "templates\CLAUDE.md.tmpl"     = "CLAUDE.md"
    "templates\PLANS.md.tmpl"      = "PLANS.md"
    "templates\STATE.md.tmpl"      = "docs\STATE.md"
    "templates\DECISIONS.md.tmpl"  = "docs\DECISIONS.md"
}

foreach ($src in $templateMap.Keys) {
    $srcPath = Join-Path $hubRoot $src
    $destRel = $templateMap[$src]
    $destPath = Join-Path $targetPath $destRel

    if ((Test-Path $destPath) -and (-not $Force)) {
        $skipped += $destRel
        continue
    }

    $written += $destRel

    if (-not $DryRun) {
        $destDir = Split-Path $destPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item -Path $srcPath -Destination $destPath -Force
    }
}

# 3. skills/ -> .claude/skills/, hooks/ -> .claude/hooks/
$dirMap = @{
    "skills" = ".claude\skills"
    "hooks"  = ".claude\hooks"
}

foreach ($srcDir in $dirMap.Keys) {
    $srcDirPath = Join-Path $hubRoot $srcDir
    $destDirRel = $dirMap[$srcDir]

    if (-not (Test-Path $srcDirPath)) { continue }

    $files = Get-ChildItem -Path $srcDirPath -Recurse -File
    foreach ($file in $files) {
        $relPath = $file.FullName.Substring($srcDirPath.Length + 1)
        $destRel = Join-Path $destDirRel $relPath
        $destPath = Join-Path $targetPath $destRel

        if ((Test-Path $destPath) -and (-not $Force)) {
            $skipped += $destRel
            continue
        }

        $written += $destRel

        if (-not $DryRun) {
            $destDir = Split-Path $destPath -Parent
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Copy-Item -Path $file.FullName -Destination $destPath -Force
        }
    }
}

# 4. .claude/settings.json - hook kayitlarini birlestir (ezmeden)
$fragmentPath = Join-Path $hubRoot "settings\settings.json.fragment"
$settingsPath = Join-Path $targetPath ".claude\settings.json"

$sessionStartCmd = 'powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PROJECT_DIR}\.claude\hooks\session-start.ps1"'
$preCompactCmd   = 'powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PROJECT_DIR}\.claude\hooks\pre-compact.ps1"'

$fragmentObj = Get-Content $fragmentPath -Raw -Encoding UTF8 | ConvertFrom-Json
$fragmentObj.hooks.SessionStart[0].hooks[0].command = $sessionStartCmd
$fragmentObj.hooks.PreCompact[0].hooks[0].command = $preCompactCmd

if (Test-Path $settingsPath) {
    $existingSettings = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
} else {
    $existingSettings = [PSCustomObject]@{}
}

if (-not $existingSettings.PSObject.Properties["hooks"]) {
    $existingSettings | Add-Member -NotePropertyName "hooks" -NotePropertyValue ([PSCustomObject]@{})
}

$settingsChanged = $false
foreach ($eventName in @("SessionStart", "PreCompact")) {
    if ($existingSettings.hooks.PSObject.Properties[$eventName]) {
        $skipped += ".claude\settings.json ($eventName zaten var - elle kontrol et)"
    } else {
        $existingSettings.hooks | Add-Member -NotePropertyName $eventName -NotePropertyValue $fragmentObj.hooks.$eventName
        $written += ".claude\settings.json ($eventName eklendi)"
        $settingsChanged = $true
    }
}

if ($settingsChanged -and (-not $DryRun)) {
    $settingsDir = Split-Path $settingsPath -Parent
    if (-not (Test-Path $settingsDir)) {
        New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
    }
    $existingSettings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8
}

# 5. .ai-workspace/version.json
$hubVersion = (Get-Content (Join-Path $hubRoot "VERSION") -Raw -Encoding UTF8).Trim()
$versionInfo = [PSCustomObject]@{
    hubVersion     = $hubVersion
    installedAt    = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    installedFiles = $written
}

$versionPath = Join-Path $targetPath ".ai-workspace\version.json"

if (-not $DryRun) {
    $versionDir = Split-Path $versionPath -Parent
    if (-not (Test-Path $versionDir)) {
        New-Item -ItemType Directory -Path $versionDir -Force | Out-Null
    }
    $versionInfo | ConvertTo-Json -Depth 5 | Set-Content -Path $versionPath -Encoding UTF8
}

$written += ".ai-workspace\version.json"

Write-Host ""
Write-Host "=== Ozet ==="
Write-Host "Git reposu: $isGitRepo"
Write-Host ""
Write-Host "Yazilacak/yazilan dosyalar:"
foreach ($f in $written) { Write-Host "  + $f" -ForegroundColor Green }
if ($written.Count -eq 0) { Write-Host "  (yok)" }
Write-Host ""
Write-Host "Atlanan (hedefte zaten var, -Force verilmedi):"
foreach ($f in $skipped) { Write-Host "  - $f" -ForegroundColor Yellow }
if ($skipped.Count -eq 0) { Write-Host "  (yok)" }
