#!/bin/sh
# ==============================================================================
# Script de bascule du style d'onglets Firefox (Classique vs Moderne Proton)
# Thème Crunchy
# Exécution : sh toggle-firefox-tabs.sh [legacy|modern]
# ==============================================================================

TARGET_MODE="$1" # "legacy", "modern", ou vide pour bascule automatique

found_profiles=0

for FF_DIR in "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox" "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"; do
    if [ -d "$FF_DIR" ]; then
        for prof in "$FF_DIR"/*.*; do
            if [ -d "$prof" ]; then
                if [ -f "$prof/prefs.js" ] || [ -f "$prof/compatibility.ini" ]; then
                    found_profiles=1
                    CHROME_DIR="$prof/chrome"
                    USERCHROME="$CHROME_DIR/userChrome.css"
                    mkdir -p "$CHROME_DIR"

                    CURRENT_STATE="modern"
                    if [ -f "$USERCHROME" ] && grep -q "^@import "tabs-legacy.css";" "$USERCHROME" 2>/dev/null; then
                        CURRENT_STATE="legacy"
                    fi

                    NEW_STATE=""
                    if [ "$TARGET_MODE" = "legacy" ]; then
                        NEW_STATE="legacy"
                    elif [ "$TARGET_MODE" = "modern" ]; then
                        NEW_STATE="modern"
                    else
                        if [ "$CURRENT_STATE" = "legacy" ]; then
                            NEW_STATE="modern"
                        else
                            NEW_STATE="legacy"
                        fi
                    fi

                    if [ "$NEW_STATE" = "legacy" ]; then
                        if [ -f "$USERCHROME" ] && grep -q "^/\* @import "tabs-legacy.css"; \*/" "$USERCHROME" 2>/dev/null; then
                            sed -i 's|^/\* @import "tabs-legacy.css"; \*/|@import "tabs-legacy.css";|' "$USERCHROME"
                        elif [ ! -f "$USERCHROME" ] || ! grep -q "^@import "tabs-legacy.css";" "$USERCHROME" 2>/dev/null; then
                            printf '@import "tabs-legacy.css";\n' | cat - "$USERCHROME" 2>/dev/null > "$USERCHROME.tmp" && mv "$USERCHROME.tmp" "$USERCHROME"
                        fi
                        echo "✔ Profil $(basename "$prof") : Onglets CLASSIQUES attachés ACTIVÉS."
                    else
                        if [ -f "$USERCHROME" ]; then
                            sed -i 's|^@import "tabs-legacy.css";|/* @import "tabs-legacy.css"; */|' "$USERCHROME" 2>/dev/null || true
                        fi
                        echo "✔ Profil $(basename "$prof") : Onglets MODERNES Proton ACTIVÉS."
                    fi
                fi
            fi
        done
    fi
done

if [ "$found_profiles" -eq 0 ]; then
    echo "Aucun profil Firefox trouvé pour le moment."
    exit 1
fi
