#!/bin/sh
# ======================================================================
#  Installation Universelle de la Suite Crunchy (Dark & Light)
# ======================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "======================================================================"
echo "  Installation Complète de la Suite Crunchy"
echo "======================================================================"

TARGET_THEMES="$HOME/.themes"
TARGET_SCHEMES="$HOME/.local/share/color-schemes"
TARGET_AURORAE="$HOME/.local/share/aurorae/themes"
TARGET_PLASMA_THEME="$HOME/.local/share/plasma/desktoptheme"
TARGET_LOOKANDFEEL="$HOME/.local/share/plasma/look-and-feel"
TARGET_KSTYLE="$HOME/.local/share/kstyle/themes"
TARGET_LXQT="$HOME/.local/share/lxqt/themes"

mkdir -p "$TARGET_THEMES" "$TARGET_SCHEMES" "$TARGET_AURORAE" "$TARGET_PLASMA_THEME" "$TARGET_LOOKANDFEEL" "$TARGET_KSTYLE" "$TARGET_LXQT"

# [1/9] GTK2, GTK3, GTK4 & Window Managers
echo "[1/9] Installation des thèmes GTK2, GTK3, GTK4 & WM..."
cp -rf "$SCRIPT_DIR/Crunchy-Dark" "$TARGET_THEMES/"
cp -rf "$SCRIPT_DIR/Crunchy-Light" "$TARGET_THEMES/"

# [2/9] Schémas de couleurs KDE Plasma (.colors)
echo "[2/9] Installation des schémas de couleurs KDE Plasma..."
if [ -d "$SCRIPT_DIR/kde-color-schemes" ]; then
    cp -f "$SCRIPT_DIR/kde-color-schemes/"* "$TARGET_SCHEMES/"
fi

# [3/9] Décorations de fenêtres KWin Aurorae
echo "[3/9] Installation des décorations de fenêtres KWin Aurorae..."
if [ -d "$SCRIPT_DIR/kwin-decorations" ]; then
    cp -rf "$SCRIPT_DIR/kwin-decorations/"* "$TARGET_AURORAE/"
fi

# [4/9] Thèmes de bureau Plasma (Kickoff & Panneaux)
echo "[4/9] Installation des thèmes de bureau Plasma (Kickoff & Panneaux)..."
if [ -d "$SCRIPT_DIR/plasma-desktopthemes" ]; then
    cp -rf "$SCRIPT_DIR/plasma-desktopthemes/"* "$TARGET_PLASMA_THEME/"
fi

# [5/9] Thèmes Globaux Look-and-Feel Plasma
echo "[5/9] Installation des thèmes globaux Look-and-Feel..."
if [ -d "$SCRIPT_DIR/plasma-lookandfeel" ]; then
    cp -rf "$SCRIPT_DIR/plasma-lookandfeel/"* "$TARGET_LOOKANDFEEL/"
fi

# [6/9] Descripteurs Style d'Applications KStyle
echo "[6/9] Installation des descripteurs Style d'applications..."
if [ -d "$SCRIPT_DIR/kstyle-themes" ]; then
    cp -rf "$SCRIPT_DIR/kstyle-themes/"* "$TARGET_KSTYLE/"
fi

# [7/9] Thèmes natifs LXQt
echo "[7/9] Installation des thèmes natifs LXQt..."
if [ -d "$SCRIPT_DIR/lxqt-themes" ]; then
    cp -rf "$SCRIPT_DIR/lxqt-themes/"* "$TARGET_LXQT/"
fi

# [8/9] Intégration Firefox
echo "[8/9] Configuration et intégration Firefox..."
for FF_DIR in "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox" "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"; do
    if [ -d "$FF_DIR" ]; then
        for profile in "$FF_DIR"/*.*; do
            if [ -d "$profile" ] && ([ -f "$profile/prefs.js" ] || [ -f "$profile/compatibility.ini" ]); then
                echo "  -> Profil détecté : $(basename "$profile")"
                mkdir -p "$profile/chrome"
                cp -f "$SCRIPT_DIR/firefox-integration/chrome/"* "$profile/chrome/"
                cp -f "$SCRIPT_DIR/firefox-integration/user.js" "$profile/user.js"
            fi
        done
    fi
done

# [9/9] Patch de lisibilité KWin Aurorae (si privilèges disponibles)
echo "[9/9] Vérification du moteur de titre KWin..."
if [ -f "/usr/share/kwin/aurorae/aurorae.qml" ]; then
    if [ "$(id -u)" -eq 0 ]; then
        sed -i 's/color: decoration.client.active ? auroraeTheme.activeTextColor : auroraeTheme.inactiveTextColor/color: decoration.client.active ? "#ffffff" : "#aaaaaa"/' /usr/share/kwin/aurorae/aurorae.qml 2>/dev/null || true
    elif sudo -n true 2>/dev/null; then
        sudo -n sed -i 's/color: decoration.client.active ? auroraeTheme.activeTextColor : auroraeTheme.inactiveTextColor/color: decoration.client.active ? "#ffffff" : "#aaaaaa"/' /usr/share/kwin/aurorae/aurorae.qml 2>/dev/null || true
    fi
fi

# === Activation automatique pour KDE Plasma ===
if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
    plasma-apply-colorscheme Crunchy-Dark 2>/dev/null || true
fi
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kdeglobals --group General --key AccentColor "53,168,84" 2>/dev/null || true
    kwriteconfig6 --file kdeglobals --group General --key accentColor "53,168,84" 2>/dev/null || true
    kwriteconfig6 --file kdeglobals --group General --key LastUsedCustomAccentColor "53,168,84" 2>/dev/null || true
    kwriteconfig6 --file plasmarc --group Theme --key name "Crunchy-Dark" 2>/dev/null || true
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__Crunchy-Rounded" 2>/dev/null || true
fi
if [ -f "/usr/lib/x86_64-linux-gnu/libexec/kwin-applywindowdecoration" ]; then
    /usr/lib/x86_64-linux-gnu/libexec/kwin-applywindowdecoration __aurorae__svg__Crunchy-Rounded 2>/dev/null || true
fi
if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.refreshCurrentShell 2>/dev/null || true
fi

echo ""
echo "======================================================================"
echo "  Installation terminée avec succès !"
echo "======================================================================"
