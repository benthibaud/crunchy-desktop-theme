#!/bin/sh
# ======================================================================
#  Installation Universelle de la Suite Crunchy (Dark & Light)
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

# [1/10] GTK2, GTK3, GTK4 & Window Managers
echo "[1/10] Installation des thèmes GTK2, GTK3, GTK4 & WM..."
cp -rf "$ROOT_DIR/Crunchy-Dark" "$TARGET_THEMES/"
cp -rf "$ROOT_DIR/Crunchy-Light" "$TARGET_THEMES/"

# [2/10] Schémas de couleurs KDE Plasma (.colors)
echo "[2/10] Installation des schémas de couleurs KDE Plasma..."
if [ -d "$ROOT_DIR/kde-color-schemes" ]; then
    cp -f "$ROOT_DIR/kde-color-schemes/"* "$TARGET_SCHEMES/"
fi

# [3/10] Décorations de fenêtres KWin Aurorae
echo "[3/10] Installation des décorations de fenêtres KWin Aurorae..."
if [ -d "$ROOT_DIR/kwin-decorations" ]; then
    cp -rf "$ROOT_DIR/kwin-decorations/"* "$TARGET_AURORAE/"
fi

# [4/10] Thèmes de bureau Plasma (Kickoff & Panneaux)
echo "[4/10] Installation des thèmes de bureau Plasma (Kickoff & Panneaux)..."
if [ -d "$ROOT_DIR/plasma-desktopthemes" ]; then
    cp -rf "$ROOT_DIR/plasma-desktopthemes/"* "$TARGET_PLASMA_THEME/"
fi

# [5/10] Thèmes Globaux Look-and-Feel Plasma
echo "[5/10] Installation des thèmes globaux Look-and-Feel..."
if [ -d "$ROOT_DIR/plasma-lookandfeel" ]; then
    cp -rf "$ROOT_DIR/plasma-lookandfeel/"* "$TARGET_LOOKANDFEEL/"
fi

# [6/10] Descripteurs Style d'Applications KStyle
echo "[6/10] Installation des descripteurs Style d'applications..."
if [ -d "$ROOT_DIR/kstyle-themes" ]; then
    cp -rf "$ROOT_DIR/kstyle-themes/"* "$TARGET_KSTYLE/"
fi

# [7/10] Thèmes natifs LXQt
echo "[7/10] Installation des thèmes natifs LXQt..."
if [ -d "$ROOT_DIR/lxqt-themes" ]; then
    cp -rf "$ROOT_DIR/lxqt-themes/"* "$TARGET_LXQT/"
fi

# [8/10] Intégration Firefox
echo "[8/10] Configuration et intégration Firefox..."
for FF_DIR in "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox" "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"; do
    if [ -d "$FF_DIR" ]; then
        for profile in "$FF_DIR"/*.*; do
            if [ -d "$profile" ] && ([ -f "$profile/prefs.js" ] || [ -f "$profile/compatibility.ini" ]); then
                echo "  -> Profil détecté : $(basename "$profile")"
                mkdir -p "$profile/chrome"
                if [ -d "$ROOT_DIR/firefox-integration/chrome" ]; then
                    cp -f "$ROOT_DIR/firefox-integration/chrome/"* "$profile/chrome/"
                fi
                if [ -f "$ROOT_DIR/firefox-integration/user.js" ]; then
                    cp -f "$ROOT_DIR/firefox-integration/user.js" "$profile/user.js"
                fi
            fi
        done
    fi
done

# [9/10] Patch de lisibilité KWin Aurorae (si privilèges disponibles)
echo "[9/10] Vérification du moteur de titre KWin..."
if [ -f "/usr/share/kwin/aurorae/aurorae.qml" ]; then
    if [ "$(id -u)" -eq 0 ]; then
        sed -i 's/color: decoration.client.active ? auroraeTheme.activeTextColor : auroraeTheme.inactiveTextColor/color: decoration.client.active ? "#ffffff" : "#aaaaaa"/' /usr/share/kwin/aurorae/aurorae.qml 2>/dev/null || true
    elif sudo -n true 2>/dev/null; then
        sudo -n sed -i 's/color: decoration.client.active ? auroraeTheme.activeTextColor : auroraeTheme.inactiveTextColor/color: decoration.client.active ? "#ffffff" : "#aaaaaa"/' /usr/share/kwin/aurorae/aurorae.qml 2>/dev/null || true
    fi
fi

# [10/10] Intégration GIMP 2.10 (Délégation au thème système GTK)
echo "[10/10] Intégration du thème pour GIMP 2.10..."
GIMP_DIR="$HOME/.config/GIMP/2.10"
if [ -d "$GIMP_DIR" ]; then
    GIMPRC="$GIMP_DIR/gimprc"
    # Sauvegarde préventive si gimprc existe et n'a pas encore de backup Crunchy
    if [ -f "$GIMPRC" ] && [ ! -f "$GIMPRC.crunchy-backup" ]; then
        cp -p "$GIMPRC" "$GIMPRC.crunchy-backup"
    fi

    # Mise à jour ciblée : on modifie uniquement la ligne de thème sans rien écraser
    if [ -f "$GIMPRC" ] && grep -q '(theme ' "$GIMPRC"; then
        sed -i 's/(theme ".*")/(theme "System")/' "$GIMPRC"
    else
        echo '(theme "System")' >> "$GIMPRC"
    fi

    # Synchronisation immédiate de themerc
    THEMERC="$GIMP_DIR/themerc"
    if [ -f "$THEMERC" ]; then
        sed -i 's|/usr/share/gimp/2.0/themes/.*/gtkrc|/usr/share/gimp/2.0/themes/System/gtkrc|' "$THEMERC"
    fi
    echo "  -> GIMP configuré sur le thème Système (Sauvegarde créée si nécessaire)."
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

# Rafraîchissement X11 / GTK
killall -HUP xsettingsd 2>/dev/null || true

echo ""
echo "======================================================================"
echo "  Installation terminée avec succès !"
echo "======================================================================"
