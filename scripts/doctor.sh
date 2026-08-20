#!/usr/bin/env bash
# scripts/doctor.sh
# Proje durumunu kontrol eder: AGENTS.md boyutu, STATE.md tazeligi, PLANS.md
# tutarliligi, skill frontmatter'lari, doldurulmamis DOLDUR kalintilari,
# version.json/hub surum farki, settings.json hook yollari, kaynak/hedef sapmasi.
# Cikis kodu: 0 temiz, 1 uyari, 2 hata.

set -uo pipefail

TARGET="${1:-.}"
HUB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_PATH="$(cd "$TARGET" 2>/dev/null && pwd)"

if [ -z "$TARGET_PATH" ]; then
  echo "HATA: Hedef klasor bulunamadi: $TARGET" >&2
  exit 2
fi

WARNINGS=()
ERRORS=()

# 1. AGENTS.md satir sayisi
if [ -f "$TARGET_PATH/AGENTS.md" ]; then
  LINES=$(wc -l < "$TARGET_PATH/AGENTS.md")
  if [ "$LINES" -gt 200 ]; then
    WARNINGS+=("AGENTS.md $LINES satir (limit 200).")
  fi
else
  WARNINGS+=("AGENTS.md bulunamadi.")
fi

# 2. STATE.md tazeligi (7 gunden eskiyse uyar)
if [ -f "$TARGET_PATH/docs/STATE.md" ]; then
  LAST_UPDATE=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$TARGET_PATH/docs/STATE.md" | tail -1)
  if [ -n "$LAST_UPDATE" ]; then
    NOW_SEC=$(date -u +%s)
    THEN_SEC=$(date -u -d "$LAST_UPDATE" +%s 2>/dev/null || date -u -j -f "%Y-%m-%d" "$LAST_UPDATE" +%s 2>/dev/null || echo "")
    if [ -n "$THEN_SEC" ]; then
      DAYS_SINCE=$(( (NOW_SEC - THEN_SEC) / 86400 ))
      if [ "$DAYS_SINCE" -gt 7 ]; then
        WARNINGS+=("STATE.md $DAYS_SINCE gundur guncellenmemis (son: $LAST_UPDATE).")
      fi
    fi
  else
    WARNINGS+=("STATE.md'de 'Son Guncelleme' tarihi bulunamadi.")
  fi
else
  WARNINGS+=("docs/STATE.md bulunamadi.")
fi

# 3. PLANS.md - [x] isaretli maddelerdeki dosya referanslari gercekten var mi
if [ -f "$TARGET_PATH/PLANS.md" ]; then
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\[x\] ]]; then
      remaining="$line"
      while [[ "$remaining" =~ \`([^\`]+\.(md|ps1|sh|json|tmpl))\` ]]; do
        ref="${BASH_REMATCH[1]}"
        remaining="${remaining/${BASH_REMATCH[0]}/}"
        ref_path="$TARGET_PATH/$ref"
        if [ ! -e "$ref_path" ]; then
          ERRORS+=("PLANS.md '[x]' isaretli ama dosya yok: $ref")
        elif [ ! -s "$ref_path" ]; then
          ERRORS+=("PLANS.md '[x]' isaretli ama dosya BOS: $ref")
        fi
      done
    fi
  done < "$TARGET_PATH/PLANS.md"
else
  WARNINGS+=("PLANS.md bulunamadi.")
fi

# 4. Skill frontmatter gecerliligi
if [ -d "$TARGET_PATH/.claude/skills" ]; then
  for skill_dir in "$TARGET_PATH"/.claude/skills/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    skill_file="${skill_dir}SKILL.md"
    if [ ! -f "$skill_file" ]; then
      ERRORS+=("skills/$skill_name/SKILL.md yok.")
      continue
    fi
    if ! head -1 "$skill_file" | grep -q "^---$"; then
      ERRORS+=("skills/$skill_name/SKILL.md frontmatter'siz (skill olarak yuklenmez).")
      continue
    fi
    name_val=$(grep -m1 "^name:" "$skill_file" | sed 's/^name:[[:space:]]*//')
    if [ -z "$name_val" ]; then
      ERRORS+=("skills/$skill_name/SKILL.md'de gecerli 'name:' yok.")
    elif [ "$name_val" != "$skill_name" ]; then
      WARNINGS+=("skills/$skill_name/SKILL.md name alani ('$name_val') klasor adiyla uyusmuyor.")
    fi
    if ! grep -qE "^description:[[:space:]]*[^[:space:]]" "$skill_file"; then
      ERRORS+=("skills/$skill_name/SKILL.md'de 'description:' bos veya yok.")
    fi
  done
fi

# 5. Doldurulmamis <!-- DOLDUR: --> kalintisi
# Sadece sablondan uretilen "instance" dosyalara bakilir - diger .md dosyalari
# (README, IMPLEMENTATION-PLAN, docs/architecture vb.) DOLDUR kuralini ANLATAN
# metin icerebilir, bu gercek bir doldurulmamis alan degildir.
for rel in "AGENTS.md" "CLAUDE.md" "PLANS.md" "docs/STATE.md" "docs/DECISIONS.md"; do
  f="$TARGET_PATH/$rel"
  # Backtick icinde gecen `<!-- DOLDUR: ... -->` ornekleri (dokumantasyon) gercek
  # doldurulmamis alan degildir, sadece backtick'siz olanlar sayilir.
  if [ -f "$f" ] && grep "<!-- *DOLDUR" "$f" 2>/dev/null | grep -qv '`<!--.*DOLDUR.*-->`'; then
    WARNINGS+=("$rel icinde doldurulmamis <!-- DOLDUR: --> var.")
  fi
done

# 6. version.json vs hub VERSION (python3 gerekli)
if [ -f "$TARGET_PATH/.ai-workspace/version.json" ] && [ -f "$HUB_ROOT/VERSION" ] && command -v python3 >/dev/null 2>&1; then
  INSTALLED_VER=$(python3 -c "import json; print(json.load(open('$TARGET_PATH/.ai-workspace/version.json', encoding='utf-8-sig'))['hubVersion'])" 2>/dev/null)
  HUB_VER=$(tr -d '[:space:]' < "$HUB_ROOT/VERSION")
  if [ -n "$INSTALLED_VER" ] && [ "$INSTALLED_VER" != "$HUB_VER" ]; then
    WARNINGS+=("Kurulu surum ($INSTALLED_VER) hub'in guncel suruminden ($HUB_VER) farkli.")
  fi
elif [ ! -f "$TARGET_PATH/.ai-workspace/version.json" ]; then
  WARNINGS+=(".ai-workspace/version.json bulunamadi (hic install edilmemis mi?).")
fi

# 7. settings.json'daki hook yollari (python3 gerekli)
if [ -f "$TARGET_PATH/.claude/settings.json" ] && command -v python3 >/dev/null 2>&1; then
  MISSING=$(python3 - "$TARGET_PATH/.claude/settings.json" "$TARGET_PATH" <<'PYEOF'
import json, sys, re, os
settings_path, target = sys.argv[1], sys.argv[2]
with open(settings_path, encoding="utf-8-sig") as f:
    settings = json.load(f)
for event, entries in settings.get("hooks", {}).items():
    for entry in entries:
        for h in entry.get("hooks", []):
            m = re.search(r'-File\s+"([^"]+)"', h.get("command", ""))
            if m:
                p = m.group(1).replace("${CLAUDE_PROJECT_DIR}", target)
                if not os.path.exists(p):
                    print(f"{event}:{p}")
PYEOF
)
  if [ -n "$MISSING" ]; then
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      ERRORS+=("settings.json: ${line%%:*} hook'u ${line#*:}'e isaret ediyor ama dosya yok.")
    done <<< "$MISSING"
  fi
fi

# 8. Kaynak/hedef sapmasi (sadece kaynak ve kurulu kopya bir aradaysa anlamli)
for pair in "skills" "hooks"; do
  SRC_DIR="$TARGET_PATH/$pair"
  INST_DIR="$TARGET_PATH/.claude/$pair"
  if [ -d "$SRC_DIR" ] && [ -d "$INST_DIR" ]; then
    while IFS= read -r -d '' f; do
      rel="${f#"$SRC_DIR"/}"
      inst_file="$INST_DIR/$rel"
      if [ -f "$inst_file" ]; then
        if ! cmp -s "$f" "$inst_file"; then
          ERRORS+=("$pair/$rel ile .claude/$pair/$rel farkli - senkron degil.")
        fi
      else
        WARNINGS+=("$pair/$rel kurulu kopyada yok: .claude/$pair/$rel")
      fi
    done < <(find "$SRC_DIR" -type f -print0)
  fi
done

# Rapor
echo ""
echo "=== doctor raporu: $TARGET_PATH ==="
echo ""

if [ "${#ERRORS[@]}" -eq 0 ] && [ "${#WARNINGS[@]}" -eq 0 ]; then
  echo "Temiz. Sorun bulunamadi."
  exit 0
fi

if [ "${#ERRORS[@]}" -gt 0 ]; then
  echo "HATALAR:"
  for e in "${ERRORS[@]}"; do echo "  ! $e"; done
  echo ""
fi

if [ "${#WARNINGS[@]}" -gt 0 ]; then
  echo "UYARILAR:"
  for w in "${WARNINGS[@]}"; do echo "  - $w"; done
  echo ""
fi

if [ "${#ERRORS[@]}" -gt 0 ]; then
  exit 2
else
  exit 1
fi
