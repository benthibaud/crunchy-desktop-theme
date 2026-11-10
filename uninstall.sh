#!/bin/sh
# ======================================================================
#  Désinstallation Universelle de la Suite Crunchy (Dark & Light)
# ======================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Détection de la racine du projet
if [ -d "$SCRIPT_DIR/Crunchy-Dark" ] && [ -d "$SCRIPT_DIR/Crunchy-Light" ]; then
    ROOT_DIR="$SCRIPT_DIR"
elif [ -d "$SCRIPT_DIR/../Crunchy-Dark" ] && [ -d "$SCRIPT_DIR/../Crunchy-Light" ]; then
    ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
    ROOT_DIR="$SCRIPT_DIR"
fi

echo "======================================================================"
echo "  Désinstallation Complète de la Suite Crunchy"
echo "======================================================================"

TARGET_THEMES="$HOME/.themes"
TARGET_SCHEMES="$HOME/.local/share/color-schemes"
TARGET_AURORAE="$HOME/.local/share/aurorae/themes"
TARGET_LOOKANDFEEL="$HOME/.local/share/plasma/look-and-feel"
TARGET_ICEWM="$HOME/.icewm/themes"
TARGET_ICEWM_SHARE="$HOME/.local/share/icewm/themes"
TARGET_FLUXBOX="$HOME/.fluxbox/styles"
TARGET_FLUXBOX_SHARE="$HOME/.local/share/fluxbox/styles"

# [1/6] Suppression des thèmes GTK2, GTK3, GTK4 & WM
echo "[1/6] Suppression des dossiers thèmes GTK / WM..."
rm -rf "$TARGET_THEMES/Crunchy-Dark" "$TARGET_THEMES/Crunchy-Light"

# [2/6] Suppression des schémas de couleurs KDE Plasma
echo "[2/6] Suppression des schémas de couleurs KDE Plasma..."
rm -f "$TARGET_SCHEMES"/Crunchy*.colors "$TARGET_SCHEMES"/Revision2*.colors

# [3/6] Suppression des décorations de fenêtres KWin Aurorae
echo "[3/6] Suppression des décorations KWin Aurorae..."
rm -rf "$TARGET_AURORAE"/__aurorae__svg__Crunchy* "$TARGET_AURORAE"/Crunchy* "$TARGET_AURORAE"/Revision2*

# [4/6] Suppression des thèmes Look-and-Feel Plasma
echo "[4/6] Suppression des thèmes Look-and-Feel Plasma..."
rm -rf "$TARGET_LOOKANDFEEL"/org.crunchy.revision2.* "$TARGET_LOOKANDFEEL"/Crunchy*

# [5/6] Suppression des thèmes IceWM & Fluxbox
echo "[5/6] Suppression des thèmes IceWM & Fluxbox..."
rm -rf "$TARGET_ICEWM"/Crunchy* "$TARGET_ICEWM_SHARE"/Crunchy*
rm -rf "$TARGET_FLUXBOX"/Crunchy* "$TARGET_FLUXBOX_SHARE"/Crunchy*

# [6/6] Restauration configuration GIMP 2.10
echo "[6/6] Restauration de la configuration GIMP 2.10..."
GIMP_DIR="$HOME/.config/GIMP/2.10"
if [ -d "$GIMP_DIR" ]; then
    GIMPRC="$GIMP_DIR/gimprc"
    BACKUP="$GIMPRC.crunchy-backup"

    if [ -f "$BACKUP" ]; then
        echo "  -> Restauration du fichier gimprc original sauvegardé..."
        cp -pf "$BACKUP" "$GIMPRC"
        rm -f "$BACKUP"
    elif [ -f "$GIMPRC" ] && grep -q '(theme "System")' "$GIMPRC"; then
        echo "  -> Rétablissement du thème GIMP par défaut (Dark)..."
        sed -i 's/(theme "System")/(theme "Dark")/' "$GIMPRC"
    fi

    THEMERC="$GIMP_DIR/themerc"
    if [ -f "$THEMERC" ]; then
        sed -i 's|/usr/share/gimp/2.0/themes/System/gtkrc|/usr/share/gimp/2.0/themes/Dark/gtkrc|' "$THEMERC"
    fi
fi

# [9/9] Réinitialisation d'environnement & rafraîchissement
echo "[9/9] Rafraîchissement des services d'affichage..."
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file plasmarc --group Theme --key name "default" 2>/dev/null || true
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "Breeze" 2>/dev/null || true
fi
if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.refreshCurrentShell 2>/dev/null || true
fi

killall -HUP xsettingsd 2>/dev/null || true

echo ""
echo "======================================================================"
echo "  Désinstallation terminée avec succès !"
echo "======================================================================"
