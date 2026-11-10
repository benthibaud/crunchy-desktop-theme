#!/bin/sh
# =============================================================================
#  SYNCHRONISATION THÈME ICEWM -> GTK (CRUNCHY DESKTOP THEME)
# =============================================================================
# Surveille les sélections de thèmes dans le menu IceWM ("Paramètres > Thèmes")
# et applique automatiquement le thème GTK correspondant par défaut (Crunchy-Light).
# Les personnalisations manuelles ultérieures faites dans le Centre de Contrôle
# (LXAppearance) sont préservées tant qu'un nouveau thème IceWM n'est pas choisi.
# =============================================================================

THEME_FILE="$HOME/.icewm/theme"

apply_gtk() {
    [ -f "$THEME_FILE" ] || return 0

    CURRENT_THEME=$(sed -n 's/Theme="\([^/]*\).*/\1/p' "$THEME_FILE")
    [ -z "$CURRENT_THEME" ] && return 0

    # Détermine le thème GTK : par défaut Crunchy-Light
    case "$CURRENT_THEME" in
        *Dark*|*dark*) GTK_THEME="Crunchy-Dark" ;;
        *)             GTK_THEME="Crunchy-Light" ;;
    esac

    # 1. Mise à jour GTK2 (~/.gtkrc-2.0)
    if [ -f "$HOME/.gtkrc-2.0" ]; then
        if grep -q "include .*/gtkrc" "$HOME/.gtkrc-2.0"; then
            sed -i "s|^include \".*\"|include \"$HOME/.themes/$GTK_THEME/gtk-2.0/gtkrc\"|" "$HOME/.gtkrc-2.0"
        fi
        if grep -q "gtk-theme-name=" "$HOME/.gtkrc-2.0"; then
            sed -i "s|^gtk-theme-name=.*|gtk-theme-name=\"$GTK_THEME\"|" "$HOME/.gtkrc-2.0"
        else
            echo "gtk-theme-name=\"$GTK_THEME\"" >> "$HOME/.gtkrc-2.0"
        fi
    fi

    # 2. Mise à jour GTK3 (~/.config/gtk-3.0/settings.ini)
    if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
        if grep -q "gtk-theme-name=" "$HOME/.config/gtk-3.0/settings.ini"; then
            sed -i "s|^gtk-theme-name=.*|gtk-theme-name=$GTK_THEME|" "$HOME/.config/gtk-3.0/settings.ini"
        fi
    fi

    # 3. Notification en direct XSettings (prise en compte immédiate sans redémarrer)
    if pgrep -x xsettingsd > /dev/null 2>&1; then
        killall -HUP xsettingsd 2>/dev/null || true
    fi
}

# Attente de l'existence du fichier si premier démarrage
while [ ! -f "$THEME_FILE" ]; do
    sleep 2
done

# Surveillance événementielle stricte avec inotifywait (inclus dans inotify-tools)
if command -v inotifywait >/dev/null 2>&1; then
    while inotifywait -q -e close_write,moved_to "$THEME_FILE" >/dev/null 2>&1; do
        apply_gtk
    done
else
    # Fallback sobre sans inotifywait
    LAST_MTIME=$(stat -c %Y "$THEME_FILE" 2>/dev/null || echo 0)
    while true; do
        sleep 3
        CUR_MTIME=$(stat -c %Y "$THEME_FILE" 2>/dev/null || echo 0)
        if [ "$CUR_MTIME" != "$LAST_MTIME" ]; then
            LAST_MTIME="$CUR_MTIME"
            apply_gtk
        fi
    done
fi
