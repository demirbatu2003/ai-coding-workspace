#!/usr/bin/env bash
# hooks/session-start.sh
# SessionStart hook: oturum basinda proje durumunu baglama enjekte eder.
# STATE.md, en yeni handoff ve git durumu yoksa sessizce cikar.

set -uo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

state="$root/docs/STATE.md"
handoffs="$root/docs/handoffs"

if [ -f "$state" ]; then
  echo "## docs/STATE.md"
  echo ""
  cat "$state"
  echo ""
fi

if [ -d "$handoffs" ]; then
  latest=$(ls -1 "$handoffs"/*.md 2>/dev/null | sort -r | head -n 1)
  if [ -n "$latest" ]; then
    echo "## En yeni handoff: $(basename "$latest")"
    echo ""
    cat "$latest"
    echo ""
  fi
fi

echo "## git log (son 10)"
git -C "$root" log --oneline -10 2>/dev/null
echo ""

echo "## git status"
git -C "$root" status --short 2>/dev/null
