# scripts/doctor.ps1
# Proje durumunu kontrol eder: AGENTS.md boyutu, STATE.md tazeligi, PLANS.md
# tutarliligi, skill frontmatter'lari, doldurulmamis DOLDUR kalintilari,
# version.json/hub surum farki, settings.json hook yollari, kaynak/hedef sapmasi.
# Cikis kodu: 0 temiz, 1 uyari, 2 hata.

param(
    [string]$Target = "."
)

$hubRoot = Split-Path $PSScriptRoot -Parent
$targetPath = Resolve-Path -Path $Target -ErrorAction SilentlyContinue

if (-not $targetPath) {
    Write-Host "HATA: Hedef klasor bulunamadi: $Target" -ForegroundColor Red
    exit 2
}

$warnings = @()
$errors = @()

function Add-Warn($msg) { $script:warnings += $msg }
function Add-Err($msg) { $script:errors += $msg }

# 1. AGENTS.md satir sayisi
$agentsPath = Join-Path $targetPath "AGENTS.md"
if (Test-Path $agentsPath) {
    $lineCount = (Get-Content $agentsPath -Encoding UTF8).Count
    if ($lineCount -gt 200) {
        Add-Warn "AGENTS.md $lineCount satir (limit 200)."
    }
} else {
    Add-Warn "AGENTS.md bulunamadi."
}

# 2. STATE.md tazeligi (7 gunden eskiyse uyar)
$statePath = Join-Path $targetPath "docs\STATE.md"
if (Test-Path $statePath) {
    $stateContent = Get-Content $statePath -Encoding UTF8 -Raw
    if ($stateContent -match '(\d{4}-\d{2}-\d{2})\s*(\(.*\))?\s*$') {
        $lastUpdate = [datetime]::ParseExact($matches[1], "yyyy-MM-dd", $null)
        $daysSince = ((Get-Date) - $lastUpdate).Days
        if ($daysSince -gt 7) {
            Add-Warn "STATE.md $daysSince gundur guncellenmemis (son: $($matches[1]))."
        }
    } else {
        Add-Warn "STATE.md'de 'Son Guncelleme' tarihi bulunamadi/ayristirilamadi."
    }
} else {
    Add-Warn "docs/STATE.md bulunamadi."
}

# 3. PLANS.md - [x] isaretli maddelerdeki dosya referanslari gercekten var mi
$plansPath = Join-Path $targetPath "PLANS.md"
if (Test-Path $plansPath) {
    $plansLines = Get-Content $plansPath -Encoding UTF8
    foreach ($line in $plansLines) {
        if ($line -match '^\s*-\s*\[x\]') {
            $refs = [regex]::Matches($line, '`([^`]+\.(md|ps1|sh|json|tmpl))`')
            foreach ($ref in $refs) {
                $refPath = $ref.Groups[1].Value
                $fullRefPath = Join-Path $targetPath $refPath
                if (-not (Test-Path $fullRefPath)) {
                    Add-Err "PLANS.md '[x]' isaretli ama dosya yok: $refPath"
                } elseif ((Get-Item $fullRefPath).Length -eq 0) {
                    Add-Err "PLANS.md '[x]' isaretli ama dosya BOS: $refPath"
                }
            }
        }
    }
} else {
    Add-Warn "PLANS.md bulunamadi."
}

# 4. Skill frontmatter gecerliligi
$skillsDir = Join-Path $targetPath ".claude\skills"
if (Test-Path $skillsDir) {
    Get-ChildItem $skillsDir -Directory | ForEach-Object {
        $skillName = $_.Name
        $skillFile = Join-Path $_.FullName "SKILL.md"
        if (-not (Test-Path $skillFile)) {
            Add-Err "skills/$skillName/SKILL.md yok."
            return
        }
        $content = Get-Content $skillFile -Encoding UTF8 -Raw
        if ($content -notmatch '^---\r?\n') {
            Add-Err "skills/$skillName/SKILL.md frontmatter'siz (skill olarak yuklenmez)."
            return
        }
        if ($content -notmatch 'name:\s*([a-z0-9-]+)') {
            Add-Err "skills/$skillName/SKILL.md'de gecerli 'name:' yok."
        } elseif ($matches[1] -ne $skillName) {
            Add-Warn "skills/$skillName/SKILL.md name alani ('$($matches[1])') klasor adiyla uyusmuyor."
        }
        if ($content -notmatch 'description:\s*\S') {
            Add-Err "skills/$skillName/SKILL.md'de 'description:' bos veya yok."
        }
    }
}

# 5. Doldurulmamis <!-- DOLDUR: --> kalintisi
# Sadece sablondan uretilen "instance" dosyalara bakilir - diger .md dosyalari
# (README, IMPLEMENTATION-PLAN, docs/architecture vb.) DOLDUR kuralini ANLATAN
# metin icerebilir, bu gercek bir doldurulmamis alan degildir.
$instanceFiles = @("AGENTS.md", "CLAUDE.md", "PLANS.md", "docs\STATE.md", "docs\DECISIONS.md")
foreach ($rel in $instanceFiles) {
    $f = Join-Path $targetPath $rel
    if (Test-Path $f) {
        $lines = Get-Content $f -Encoding UTF8
        # Backtick icinde gecen `<!-- DOLDUR: ... -->` ornekleri (dokumantasyon)
        # gercek doldurulmamis alan degildir, sadece backtick'siz olanlar sayilir.
        $realPlaceholder = $lines | Where-Object { $_ -match '<!--\s*DOLDUR' -and $_ -notmatch '`<!--.*DOLDUR.*-->`' }
        if ($realPlaceholder) {
            Add-Warn "$rel icinde doldurulmamis <!-- DOLDUR: --> var."
        }
    }
}

# 6. version.json vs hub VERSION
$versionJsonPath = Join-Path $targetPath ".ai-workspace\version.json"
$hubVersionPath = Join-Path $hubRoot "VERSION"
if ((Test-Path $versionJsonPath) -and (Test-Path $hubVersionPath)) {
    $installed = Get-Content $versionJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $hubVersion = (Get-Content $hubVersionPath -Raw -Encoding UTF8).Trim()
    if ($installed.hubVersion -ne $hubVersion) {
        Add-Warn "Kurulu surum ($($installed.hubVersion)) hub'in guncel suruminden ($hubVersion) farkli."
    }
} elseif (-not (Test-Path $versionJsonPath)) {
    Add-Warn ".ai-workspace/version.json bulunamadi (hic install edilmemis mi?)."
}

# 7. settings.json'daki hook yollari gercekten var mi
$settingsPath = Join-Path $targetPath ".claude\settings.json"
if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($settings.PSObject.Properties["hooks"]) {
        foreach ($eventName in $settings.hooks.PSObject.Properties.Name) {
            foreach ($entry in $settings.hooks.$eventName) {
                foreach ($hookCmd in $entry.hooks) {
                    if ($hookCmd.command -match '-File\s+"([^"]+)"') {
                        $scriptPath = $matches[1] -replace '\$\{CLAUDE_PROJECT_DIR\}', $targetPath.Path
                        if (-not (Test-Path $scriptPath)) {
                            Add-Err "settings.json: $eventName hook'u $scriptPath'e isaret ediyor ama dosya yok."
                        }
                    }
                }
            }
        }
    }
}

# 8. Kaynak/hedef sapmasi (sadece kaynak ve kurulu kopya bir aradaysa anlamli)
foreach ($pairName in @("skills", "hooks")) {
    $srcDir = Join-Path $targetPath $pairName
    $instDir = Join-Path $targetPath ".claude\$pairName"
    if ((Test-Path $srcDir) -and (Test-Path $instDir)) {
        Get-ChildItem $srcDir -Recurse -File | ForEach-Object {
            $relPath = $_.FullName.Substring($srcDir.Length + 1)
            $instFile = Join-Path $instDir $relPath
            if (Test-Path $instFile) {
                $srcHash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
                $instHash = (Get-FileHash $instFile -Algorithm SHA256).Hash
                if ($srcHash -ne $instHash) {
                    $displayRel = $relPath.Replace('\', '/')
                    Add-Err "$pairName/$displayRel ile .claude/$pairName/$displayRel farkli - senkron degil."
                }
            } else {
                Add-Warn "$pairName/$relPath kurulu kopyada yok: .claude/$pairName/$relPath"
            }
        }
    }
}

# Rapor
Write-Host ""
Write-Host "=== doctor raporu: $targetPath ==="
Write-Host ""

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "Temiz. Sorun bulunamadi." -ForegroundColor Green
    exit 0
}

if ($errors.Count -gt 0) {
    Write-Host "HATALAR:" -ForegroundColor Red
    foreach ($e in $errors) { Write-Host "  ! $e" -ForegroundColor Red }
    Write-Host ""
}

if ($warnings.Count -gt 0) {
    Write-Host "UYARILAR:" -ForegroundColor Yellow
    foreach ($w in $warnings) { Write-Host "  - $w" -ForegroundColor Yellow }
    Write-Host ""
}

if ($errors.Count -gt 0) {
    exit 2
} else {
    exit 1
}
