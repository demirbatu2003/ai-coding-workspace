#!/usr/bin/env bash
# hooks/pre-compact.sh
set -uo pipefail
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

echo "## Sikistirma oncesi hatirlatma"
echo "Bu oturumda onemli bir karar veya surpriz varsa, sikistirmadan once /handoff calistirmayi dusun."
echo ""
echo "## git status"
git -C "$root" status --short 2>/dev/null
echo ""
echo "## git diff --stat"
git -C "$root" diff --stat 2>/dev/null
