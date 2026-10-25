#!/bin/sh
# ==============================================================================
#  sync-theme.sh — Synchronisation du cœur commun GTK3 (common.css)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE_COMMON="$ROOT_DIR/src/gtk-3.0/common.css"

if [ ! -f "$SOURCE_COMMON" ]; then
    echo "❌ Erreur: Source commune introuvable dans $SOURCE_COMMON"
    exit 1
fi

echo "▶ Propagation de src/gtk-3.0/common.css vers Crunchy-Dark et Crunchy-Light..."

cp -f "$SOURCE_COMMON" "$ROOT_DIR/Crunchy-Dark/gtk-3.0/common.css"
cp -f "$SOURCE_COMMON" "$ROOT_DIR/Crunchy-Light/gtk-3.0/common.css"

chmod 644 "$ROOT_DIR/Crunchy-Dark/gtk-3.0/common.css" "$ROOT_DIR/Crunchy-Light/gtk-3.0/common.css"

echo "✅ Synchronisation terminée avec succès !"
