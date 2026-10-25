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
TARGET_ICEWM="$HOME/.icewm/themes"
TARGET_ICEWM_SHARE="$HOME/.local/share/icewm/themes"
TARGET_FLUXBOX="$HOME/.fluxbox/styles"
TARGET_FLUXBOX_SHARE="$HOME/.local/share/fluxbox/styles"

mkdir -p "$TARGET_THEMES" "$TARGET_SCHEMES" "$TARGET_AURORAE" "$TARGET_PLASMA_THEME" "$TARGET_LOOKANDFEEL" "$TARGET_KSTYLE" "$TARGET_LXQT" "$TARGET_ICEWM" "$TARGET_ICEWM_SHARE" "$TARGET_FLUXBOX" "$TARGET_FLUXBOX_SHARE"

# [1/12] GTK2, GTK3, GTK4 & Window Managers (Openbox, Labwc, Metacity, XFWM4)
echo "[1/12] Installation des thèmes GTK2, GTK3, GTK4 & WM..."
cp -rf "$ROOT_DIR/Crunchy-Dark" "$TARGET_THEMES/"
cp -rf "$ROOT_DIR/Crunchy-Light" "$TARGET_THEMES/"
# Compatibilité directe Labwc (copie physique évitant tout problème de lien symbolique FAT32/exFAT)
mkdir -p "$TARGET_THEMES/Crunchy-Dark/labwc" "$TARGET_THEMES/Crunchy-Light/labwc"
cp -rf "$ROOT_DIR/Crunchy-Dark/openbox-3/"* "$TARGET_THEMES/Crunchy-Dark/labwc/"
cp -rf "$ROOT_DIR/Crunchy-Light/openbox-3/"* "$TARGET_THEMES/Crunchy-Light/labwc/"

# [2/12] Schémas de couleurs KDE Plasma (.colors)
echo "[2/12] Installation des schémas de couleurs KDE Plasma..."
if [ -d "$ROOT_DIR/kde-color-schemes" ]; then
    cp -f "$ROOT_DIR/kde-color-schemes/"* "$TARGET_SCHEMES/"
fi

# [3/12] Décorations de fenêtres KWin Aurorae
echo "[3/12] Installation des décorations de fenêtres KWin Aurorae..."
if [ -d "$ROOT_DIR/kwin-decorations" ]; then
    cp -rf "$ROOT_DIR/kwin-decorations/"* "$TARGET_AURORAE/"
fi

# [4/12] Thèmes de bureau Plasma (Kickoff & Panneaux)
echo "[4/12] Installation des thèmes de bureau Plasma (Kickoff & Panneaux)..."
if [ -d "$ROOT_DIR/plasma-desktopthemes" ]; then
    cp -rf "$ROOT_DIR/plasma-desktopthemes/"* "$TARGET_PLASMA_THEME/"
fi

# [5/12] Thèmes Globaux Look-and-Feel Plasma
echo "[5/12] Installation des thèmes globaux Look-and-Feel..."
if [ -d "$ROOT_DIR/plasma-lookandfeel" ]; then
    cp -rf "$ROOT_DIR/plasma-lookandfeel/"* "$TARGET_LOOKANDFEEL/"
fi

# [6/12] Descripteurs Style d'Applications KStyle
echo "[6/12] Installation des descripteurs Style d'applications..."
if [ -d "$ROOT_DIR/kstyle-themes" ]; then
    cp -rf "$ROOT_DIR/kstyle-themes/"* "$TARGET_KSTYLE/"
fi

# [7/12] Thèmes natifs LXQt
echo "[7/12] Installation des thèmes natifs LXQt..."
if [ -d "$ROOT_DIR/lxqt-themes" ]; then
    cp -rf "$ROOT_DIR/lxqt-themes/"* "$TARGET_LXQT/"
fi

# [8/12] Thèmes IceWM (Crunchy-Square & Crunchy-Round)
echo "[8/12] Installation des thèmes IceWM..."
if [ -d "$ROOT_DIR/icewm-themes" ]; then
    cp -rf "$ROOT_DIR/icewm-themes/"* "$TARGET_ICEWM/"
    cp -rf "$ROOT_DIR/icewm-themes/"* "$TARGET_ICEWM_SHARE/"
fi

# [9/12] Styles Fluxbox (Crunchy-Square & Crunchy-Round)
echo "[9/12] Installation des styles Fluxbox..."
if [ -d "$ROOT_DIR/fluxbox-styles" ]; then
    cp -rf "$ROOT_DIR/fluxbox-styles/"* "$TARGET_FLUXBOX/"
    cp -rf "$ROOT_DIR/fluxbox-styles/"* "$TARGET_FLUXBOX_SHARE/"
fi

# [10/12] Intégration Firefox
echo "[10/12] Configuration et intégration Firefox..."
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

# [11/12] Patch de lisibilité KWin Aurorae (si privilèges disponibles)
echo "[11/12] Vérification du moteur de titre KWin..."
if [ -f "/usr/share/kwin/aurorae/aurorae.qml" ]; then
    if [ "$(id -u)" -eq 0 ]; then
        sed -i 's/color: decoration.client.active ? auroraeTheme.activeTextColor : auroraeTheme.inactiveTextColor/color: decoration.client.active ? "#ffffff" : "#aaaaaa"/' /usr/share/kwin/aurorae/aurorae.qml 2>/dev/null || true
    elif sudo -n true 2>/dev/null; then
        sudo -n sed -i 's/color: decoration.client.active ? auroraeTheme.activeTextColor : auroraeTheme.inactiveTextColor/color: decoration.client.active ? "#ffffff" : "#aaaaaa"/' /usr/share/kwin/aurorae/aurorae.qml 2>/dev/null || true
    fi
fi

# [12/12] Intégration GIMP 2.10 (Délégation au thème système GTK)
echo "[12/12] Intégration du thème pour GIMP 2.10..."
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
