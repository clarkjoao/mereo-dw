#!/usr/bin/env bash
# Copia inventário + schemas de mereo/ para mereo-poc/output/ (dados locais, gitignored).
set -euo pipefail

SRC="${1:-/Users/jvclark/www/mereo/output/groups/mereogr}"
DEST="${2:-$(cd "$(dirname "$0")/.." && pwd)/output/groups/mereogr}"

if [[ ! -d "$SRC" ]]; then
  echo "Origem ausente: $SRC" >&2
  exit 1
fi

mkdir -p "$DEST"
rsync -a --delete \
  --exclude='run.log' \
  "$SRC/" "$DEST/"

echo "Sincronizado: $SRC -> $DEST"
du -sh "$DEST"/* 2>/dev/null || true
echo "Regenerar contratos: python3 analytics/catalog/generate_entity_contracts.py"
