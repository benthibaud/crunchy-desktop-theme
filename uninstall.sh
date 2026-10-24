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
TARGET_PLASMA_THEME="$HOME/.local/share/plasma/desktoptheme"
TARGET_LOOKANDFEEL="$HOME/.local/share/plasma/look-and-feel"
TARGET_KSTYLE="$HOME/.local/share/kstyle/themes"
TARGET_LXQT="$HOME/.local/share/lxqt/themes"

# [1/8] Suppression des thèmes GTK2, GTK3, GTK4 & WM
echo "[1/8] Suppression des dossiers thèmes GTK / WM..."
rm -rf "$TARGET_THEMES/Crunchy-Dark" "$TARGET_THEMES/Crunchy-Light"

# [2/8] Suppression des schémas de couleurs KDE Plasma
echo "[2/8] Suppression des schémas de couleurs KDE Plasma..."
rm -f "$TARGET_SCHEMES"/Crunchy*.colors

# [3/8] Suppression des décorations de fenêtres KWin Aurorae
echo "[3/8] Suppression des décorations KWin Aurorae..."
rm -rf "$TARGET_AURORAE"/__aurorae__svg__Crunchy* "$TARGET_AURORAE"/Crunchy*

# [4/8] Suppression des thèmes Plasma Desktop & Look-and-Feel
echo "[4/8] Suppression des composants Plasma (desktoptheme, look-and-feel, kstyle)..."
rm -rf "$TARGET_PLASMA_THEME"/Crunchy*
rm -rf "$TARGET_LOOKANDFEEL"/Crunchy*
rm -rf "$TARGET_KSTYLE"/Crunchy*

# [5/8] Suppression des thèmes natifs LXQt
echo "[5/8] Suppression des thèmes LXQt..."
rm -rf "$TARGET_LXQT"/Crunchy*

# [6/8] Nettoyage intégration Firefox
echo "[6/8] Nettoyage de l'intégration Firefox..."
for FF_DIR in "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox" "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"; do
    if [ -d "$FF_DIR" ]; then
        for profile in "$FF_DIR"/*.*; do
            if [ -d "$profile" ]; then
                # Suppression des fichiers custom injectés si présents
                rm -f "$profile/chrome/userChrome.css" "$profile/chrome/userContent.css" 2>/dev/null || true
                # Si le dossier chrome est vide, le supprimer
                rmdir "$profile/chrome" 2>/dev/null || true
            fi
        done
    fi
done

# [7/8] Restauration configuration GIMP 2.10
echo "[7/8] Restauration de la configuration GIMP 2.10..."
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

# [8/8] Réinitialisation d'environnement & rafraîchissement
echo "[8/8] Rafraîchissement des services d'affichage..."
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
