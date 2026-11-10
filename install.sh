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
TARGET_LOOKANDFEEL="$HOME/.local/share/plasma/look-and-feel"
TARGET_ICEWM="$HOME/.icewm/themes"
TARGET_ICEWM_SHARE="$HOME/.local/share/icewm/themes"
TARGET_FLUXBOX="$HOME/.fluxbox/styles"
TARGET_FLUXBOX_SHARE="$HOME/.local/share/fluxbox/styles"

mkdir -p "$TARGET_THEMES"

# [1/8] GTK2, GTK3, GTK4 & Window Managers (Openbox, Labwc, Metacity, XFWM4)
echo "[1/8] Installation des thèmes GTK2, GTK3, GTK4 & WM..."
if [ -f "$ROOT_DIR/tools/sync-theme.sh" ]; then
    sh "$ROOT_DIR/tools/sync-theme.sh" >/dev/null 2>&1 || true
fi
cp -rf "$ROOT_DIR/Crunchy-Dark" "$TARGET_THEMES/"
cp -rf "$ROOT_DIR/Crunchy-Light" "$TARGET_THEMES/"
# Compatibilité directe Labwc (copie physique évitant tout problème de lien symbolique FAT32/exFAT)
mkdir -p "$TARGET_THEMES/Crunchy-Dark/labwc" "$TARGET_THEMES/Crunchy-Light/labwc"
cp -rf "$ROOT_DIR/Crunchy-Dark/openbox-3/"* "$TARGET_THEMES/Crunchy-Dark/labwc/"
cp -rf "$ROOT_DIR/Crunchy-Light/openbox-3/"* "$TARGET_THEMES/Crunchy-Light/labwc/"

# [2/8] Schémas de couleurs Qt / KDE / LXQt (.colors)
if command -v plasmashell >/dev/null 2>&1 || command -v lxqt-session >/dev/null 2>&1 || command -v kwin_x11 >/dev/null 2>&1 || command -v kwin_wayland >/dev/null 2>&1 || [ -d "$HOME/.config/lxqt" ] || [ -d "$HOME/.local/share/plasma" ] || [ -d "$HOME/.local/share/color-schemes" ]; then
    echo "[2/8] Installation des schémas de couleurs Qt/KDE/LXQt..."
    mkdir -p "$TARGET_SCHEMES"
    if [ -d "$ROOT_DIR/Crunchy-Dark/color-schemes" ]; then
        cp -f "$ROOT_DIR/Crunchy-Dark/color-schemes/"* "$TARGET_SCHEMES/" 2>/dev/null || true
    fi
    if [ -d "$ROOT_DIR/Crunchy-Light/color-schemes" ]; then
        cp -f "$ROOT_DIR/Crunchy-Light/color-schemes/"* "$TARGET_SCHEMES/" 2>/dev/null || true
    fi
else
    echo "[2/8] Schémas Qt/KDE/LXQt ignorés (aucun bureau Qt détecté)."
fi

# [3/8] Décorations de fenêtres KWin Aurorae (KDE Plasma & LXQt-KWin)
if command -v kwin_x11 >/dev/null 2>&1 || command -v kwin_wayland >/dev/null 2>&1 || [ -d "$HOME/.local/share/aurorae" ]; then
    echo "[3/8] Installation des décorations de fenêtres KWin Aurorae..."
    mkdir -p "$TARGET_AURORAE"
    if [ -d "$ROOT_DIR/Crunchy-Dark/kwin/decorations" ]; then
        cp -rf "$ROOT_DIR/Crunchy-Dark/kwin/decorations/"* "$TARGET_AURORAE/" 2>/dev/null || true
    fi
else
    echo "[3/8] Décorations Aurorae ignorées (KWin non détecté)."
fi

# [4/8] Thèmes Globaux Look-and-Feel Plasma
if command -v plasmashell >/dev/null 2>&1 || [ -d "$HOME/.local/share/plasma" ]; then
    echo "[4/8] Installation des thèmes globaux Look-and-Feel Plasma..."
    mkdir -p "$TARGET_LOOKANDFEEL"
    if [ -d "$ROOT_DIR/Crunchy-Dark/plasma/look-and-feel" ]; then
        cp -rf "$ROOT_DIR/Crunchy-Dark/plasma/look-and-feel/"* "$TARGET_LOOKANDFEEL/" 2>/dev/null || true
    fi
    if [ -d "$ROOT_DIR/Crunchy-Light/plasma/look-and-feel" ]; then
        cp -rf "$ROOT_DIR/Crunchy-Light/plasma/look-and-feel/"* "$TARGET_LOOKANDFEEL/" 2>/dev/null || true
    fi
else
    echo "[4/8] Look-and-Feel Plasma ignoré (Plasma non détecté)."
fi

# [5/8] Thèmes IceWM & Synchronisation GTK
if command -v icewm >/dev/null 2>&1 || [ -d "$HOME/.icewm" ]; then
    echo "[5/8] Installation des thèmes IceWM et du service de synchronisation GTK..."
    mkdir -p "$TARGET_ICEWM" "$TARGET_ICEWM_SHARE"
    if [ -d "$ROOT_DIR/icewm-themes" ]; then
        cp -rf "$ROOT_DIR/icewm-themes/"* "$TARGET_ICEWM/" 2>/dev/null || true
        cp -rf "$ROOT_DIR/icewm-themes/"* "$TARGET_ICEWM_SHARE/" 2>/dev/null || true
    fi

    # Déploiement du script de synchronisation IceWM -> GTK
    if [ -f "$ROOT_DIR/tools/sync-icewm-gtk.sh" ]; then
        mkdir -p "$HOME/.icewm"
        cp -f "$ROOT_DIR/tools/sync-icewm-gtk.sh" "$HOME/.icewm/sync-theme-gtk.sh"
        chmod +x "$HOME/.icewm/sync-theme-gtk.sh"

        STARTUP_FILE="$HOME/.icewm/startup"
        if [ -f "$STARTUP_FILE" ]; then
            if ! grep -q "sync-theme-gtk.sh" "$STARTUP_FILE"; then
                echo "$HOME/.icewm/sync-theme-gtk.sh &" >> "$STARTUP_FILE"
            fi
            chmod +x "$STARTUP_FILE"
        else
            printf '#!/bin/sh\n$HOME/.icewm/sync-theme-gtk.sh &\n' > "$STARTUP_FILE"
            chmod +x "$STARTUP_FILE"
        fi

        # Lancement immédiat en arrière-plan à chaud si IceWM tourne actuellement
        if pgrep -x icewm >/dev/null 2>&1 && ! pgrep -f "sync-theme-gtk.sh" >/dev/null 2>&1; then
            "$HOME/.icewm/sync-theme-gtk.sh" &
            echo "  -> Service de synchronisation IceWM/GTK démarré en direct."
        fi
    fi
else
    echo "[5/8] IceWM non détecté sur ce système (étape ignorée)."
fi

# [6/8] Styles Fluxbox (Crunchy-Square & Crunchy-Round)
if command -v fluxbox >/dev/null 2>&1 || [ -d "$HOME/.fluxbox" ]; then
    echo "[6/8] Installation des styles Fluxbox..."
    mkdir -p "$TARGET_FLUXBOX" "$TARGET_FLUXBOX_SHARE"
    if [ -d "$ROOT_DIR/fluxbox-styles" ]; then
        cp -rf "$ROOT_DIR/fluxbox-styles/"* "$TARGET_FLUXBOX/" 2>/dev/null || true
        cp -rf "$ROOT_DIR/fluxbox-styles/"* "$TARGET_FLUXBOX_SHARE/" 2>/dev/null || true
    fi
else
    echo "[6/8] Fluxbox non détecté sur ce système (étape ignorée)."
fi

# [7/8] Patch de lisibilité KWin Aurorae (si privilèges disponibles)
echo "[7/8] Vérification du moteur de titre KWin..."
if [ -f "/usr/share/kwin/aurorae/aurorae.qml" ]; then
    if [ "$(id -u)" -eq 0 ]; then
        sed -i 's/color: decoration.client.active ? auroraeTheme.activeTextColor : auroraeTheme.inactiveTextColor/color: decoration.client.active ? "#ffffff" : "#aaaaaa"/' /usr/share/kwin/aurorae/aurorae.qml 2>/dev/null || true
    elif sudo -n true 2>/dev/null; then
        sudo -n sed -i 's/color: decoration.client.active ? auroraeTheme.activeTextColor : auroraeTheme.inactiveTextColor/color: decoration.client.active ? "#ffffff" : "#aaaaaa"/' /usr/share/kwin/aurorae/aurorae.qml 2>/dev/null || true
    fi
fi

# [8/8] Intégration GIMP 2.10 (Délégation au thème système GTK)
echo "[8/8] Intégration du thème pour GIMP 2.10..."
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
