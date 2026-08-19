#!/usr/bin/env bash
# install.sh
# ai-coding-workspace hub'ini hedef bir projeye kurar.
# Kullanim: ./install.sh --target ../benim-projem [--force] [--dry-run]

set -uo pipefail

TARGET=""
FORCE=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) echo "Bilinmeyen parametre: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "HATA: --target verilmedi." >&2
  exit 1
fi

HUB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_PATH="$(cd "$TARGET" 2>/dev/null && pwd)"

if [ -z "$TARGET_PATH" ]; then
  echo "HATA: Hedef klasor bulunamadi: $TARGET" >&2
  exit 1
fi

echo "Hub: $HUB_ROOT"
echo "Hedef: $TARGET_PATH"
[ "$DRY_RUN" -eq 1 ] && echo "(DRY RUN - hicbir dosya yazilmayacak)"

# 1. Git reposu kontrolu
IS_GIT_REPO=0
if (cd "$TARGET_PATH" && git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
  IS_GIT_REPO=1
fi

if [ "$IS_GIT_REPO" -eq 0 ]; then
  echo "UYARI: Hedef bir git reposu degil." >&2
  read -r -p "Yine de devam edilsin mi? (e/H) " ANSWER
  if [ "$ANSWER" != "e" ]; then
    echo "Iptal edildi."
    exit 0
  fi
fi

WRITTEN=()
SKIPPED=()

# 2. templates/*.tmpl -> hedef dosyalari
declare -A TEMPLATE_MAP=(
  ["templates/AGENTS.md.tmpl"]="AGENTS.md"
  ["templates/CLAUDE.md.tmpl"]="CLAUDE.md"
  ["templates/PLANS.md.tmpl"]="PLANS.md"
  ["templates/STATE.md.tmpl"]="docs/STATE.md"
  ["templates/DECISIONS.md.tmpl"]="docs/DECISIONS.md"
)

for SRC in "${!TEMPLATE_MAP[@]}"; do
  SRC_PATH="$HUB_ROOT/$SRC"
  DEST_REL="${TEMPLATE_MAP[$SRC]}"
  DEST_PATH="$TARGET_PATH/$DEST_REL"

  if [ -e "$DEST_PATH" ] && [ "$FORCE" -eq 0 ]; then
    SKIPPED+=("$DEST_REL")
    continue
  fi

  WRITTEN+=("$DEST_REL")

  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$(dirname "$DEST_PATH")"
    cp "$SRC_PATH" "$DEST_PATH"
  fi
done

# 3. skills/ -> .claude/skills/, hooks/ -> .claude/hooks/
declare -A DIR_MAP=(
  ["skills"]=".claude/skills"
  ["hooks"]=".claude/hooks"
)

for SRC_DIR in "${!DIR_MAP[@]}"; do
  SRC_DIR_PATH="$HUB_ROOT/$SRC_DIR"
  DEST_DIR_REL="${DIR_MAP[$SRC_DIR]}"

  [ -d "$SRC_DIR_PATH" ] || continue

  while IFS= read -r -d '' FILE; do
    REL_PATH="${FILE#"$SRC_DIR_PATH"/}"
    DEST_REL="$DEST_DIR_REL/$REL_PATH"
    DEST_PATH="$TARGET_PATH/$DEST_REL"

    if [ -e "$DEST_PATH" ] && [ "$FORCE" -eq 0 ]; then
      SKIPPED+=("$DEST_REL")
      continue
    fi

    WRITTEN+=("$DEST_REL")

    if [ "$DRY_RUN" -eq 0 ]; then
      mkdir -p "$(dirname "$DEST_PATH")"
      cp "$FILE" "$DEST_PATH"
    fi
  done < <(find "$SRC_DIR_PATH" -type f -print0)
done

# 4. .claude/settings.json - hook kayitlarini birlestir (ezmeden)
# JSON'u guvenle parse/merge etmek icin python3 kullanilir (Linux/Mac'te
# neredeyse her zaman kurulu). Yoksa elle birlestirmeye yonlendirir --
# mevcut settings.json'a hicbir sekilde ham metin ekleme/degistirme yapilmaz.
FRAGMENT_PATH="$HUB_ROOT/settings/settings.json.fragment"
SETTINGS_PATH="$TARGET_PATH/.claude/settings.json"

SESSION_START_CMD="bash \"\${CLAUDE_PROJECT_DIR}/.claude/hooks/session-start.sh\""
PRE_COMPACT_CMD="bash \"\${CLAUDE_PROJECT_DIR}/.claude/hooks/pre-compact.sh\""

if command -v python3 >/dev/null 2>&1; then
  MERGE_RESULT=$(python3 - "$FRAGMENT_PATH" "$SETTINGS_PATH" "$SESSION_START_CMD" "$PRE_COMPACT_CMD" "$DRY_RUN" <<'PYEOF'
import json, sys, os

fragment_path, settings_path, session_cmd, precompact_cmd, dry_run = sys.argv[1:6]
dry_run = dry_run == "1"

with open(fragment_path, "r", encoding="utf-8") as f:
    fragment = json.load(f)

fragment["hooks"]["SessionStart"][0]["hooks"][0]["command"] = session_cmd
fragment["hooks"]["PreCompact"][0]["hooks"][0]["command"] = precompact_cmd

if os.path.exists(settings_path):
    with open(settings_path, "r", encoding="utf-8") as f:
        existing = json.load(f)
else:
    existing = {}

existing.setdefault("hooks", {})

changed = False
report = []
for event in ("SessionStart", "PreCompact"):
    if event in existing["hooks"]:
        report.append(f"SKIP:.claude/settings.json ({event} zaten var - elle kontrol et)")
    else:
        existing["hooks"][event] = fragment["hooks"][event]
        report.append(f"WRITE:.claude/settings.json ({event} eklendi)")
        changed = True

if changed and not dry_run:
    os.makedirs(os.path.dirname(settings_path), exist_ok=True)
    with open(settings_path, "w", encoding="utf-8") as f:
        json.dump(existing, f, indent=4, ensure_ascii=False)

print("\n".join(report))
PYEOF
)
  while IFS= read -r LINE; do
    if [[ "$LINE" == WRITE:* ]]; then
      WRITTEN+=("${LINE#WRITE:}")
    elif [[ "$LINE" == SKIP:* ]]; then
      SKIPPED+=("${LINE#SKIP:}")
    fi
  done <<< "$MERGE_RESULT"
else
  echo "UYARI: python3 bulunamadi, .claude/settings.json otomatik birlestirilemedi." >&2
  echo "Elle birlestirmen gerekiyor: $FRAGMENT_PATH" >&2
  SKIPPED+=(".claude/settings.json (python3 yok - elle birlestir)")
fi

# 5. .ai-workspace/version.json
HUB_VERSION="$(cat "$HUB_ROOT/VERSION" | tr -d '[:space:]')"
VERSION_PATH="$TARGET_PATH/.ai-workspace/version.json"
INSTALLED_AT="$(date -u +"%Y-%m-%dT%H:%M:%S")"

if [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p "$(dirname "$VERSION_PATH")"
  {
    echo "{"
    echo "    \"hubVersion\": \"$HUB_VERSION\","
    echo "    \"installedAt\": \"$INSTALLED_AT\","
    echo "    \"installedFiles\": ["
    for i in "${!WRITTEN[@]}"; do
      COMMA=","
      [ "$i" -eq $((${#WRITTEN[@]} - 1)) ] && COMMA=""
      echo "        \"${WRITTEN[$i]}\"$COMMA"
    done
    echo "    ]"
    echo "}"
  } > "$VERSION_PATH"
fi

WRITTEN+=(".ai-workspace/version.json")

echo ""
echo "=== Ozet ==="
echo "Git reposu: $IS_GIT_REPO"
echo ""
echo "Yazilacak/yazilan dosyalar:"
if [ "${#WRITTEN[@]}" -eq 0 ]; then
  echo "  (yok)"
else
  for F in "${WRITTEN[@]}"; do echo "  + $F"; done
fi
echo ""
echo "Atlanan (hedefte zaten var, --force verilmedi):"
if [ "${#SKIPPED[@]}" -eq 0 ]; then
  echo "  (yok)"
else
  for F in "${SKIPPED[@]}"; do echo "  - $F"; done
fi
