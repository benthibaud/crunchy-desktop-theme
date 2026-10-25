# 🌿 Crunchy Desktop Theme Suite

Suite complète de thèmes de bureau Linux sobre, low-tech, contrastée et élégante, basée sur l'identité visuelle **Crunchy** (vert organique `#35a854`, nuances terre/cendre, géométrie douce 5px).

---

## 🎨 Variantes Disponibles

* **`Crunchy-Dark`** : Thème sombre à fort contraste et faible fatigue visuelle.
* **`Crunchy-Light`** : Thème clair harmonieux avec en-têtes et menus sombres contrastés.

---

## 🖥️ Environnements et Composants Pris en Charge

| Composant / Bureau | Technologie | Caractéristiques |
| :--- | :--- | :--- |
| **GTK 3.24 & GTK 4** | CSS | Variables centralisées en en-tête, contrôles vectoriels SVG Crunchy, support LibreOffice. |
| **GTK 2.0** | Murrine engine | Nuances synchronisées, padding de menu calibré, configuration isolée GIMP. |
| **Qt / KDE Plasma** | QSS & Color scheme | Intégration Qt5/Qt6, schéma de couleurs `.colors`, KWin Aurorae, Look-and-Feel. |
| **LXQt** | QSS / Palette | Thèmes natifs LXQt. |
| **XFCE (XFWM4)** | SVG 100% vectoriel | Boutons Square (radius 5px) et Round, Whisker Menu intégré. |
| **Cinnamon & GNOME** | Shell CSS | Panneaux sombres, menus et popups contextuels contrastés. |
| **Openbox & Labwc** | themerc / SVG | Boutons carrés vectoriels en relief (Square Relief), dégradés horizontaux et masques XBM nets. |
| **IceWM** | XPM / default.theme | Thèmes complets `Crunchy-Square` (boutons relief signature) et `Crunchy-Round` (Ambiance). |
| **Metacity & XFWM4** | XML / themerc | Dégradés horizontaux et boutons vectoriels coordonnés. |
| **GIMP 2.10** | GTK2 engine | Délégation propre au thème système avec préservation des raccourcis utilisateur. |

---

## 🚀 Installation & Désinstallation

### Installation Automatique Complète

Le script détecte automatiquement son emplacement (racine du projet ou sous-dossier de thème) et installe l'ensemble des composants :

```bash
./install.sh
```

*(Ou depuis un sous-dossier : `cd Crunchy-Dark && ./install.sh`)*

**Ce que fait l'installateur :**
1. Installe `Crunchy-Dark` et `Crunchy-Light` dans `~/.themes/` (avec prise en charge native d'Openbox et Labwc).
2. Installe les schémas de couleurs Plasma (`.colors`) dans `~/.local/share/color-schemes/`.
3. Installe les décorations de fenêtres KWin Aurorae dans `~/.local/share/aurorae/themes/`.
4. Installe les thèmes de bureau Plasma dans `~/.local/share/plasma/desktoptheme/`.
5. Installe les thèmes globaux Look-and-Feel Plasma dans `~/.local/share/plasma/look-and-feel/`.
6. Installe les styles d'applications KStyle dans `~/.local/share/kstyle/themes/`.
7. Installe les thèmes LXQt dans `~/.local/share/lxqt/themes/`.
8. Installe les thèmes IceWM (`Crunchy-Square` et `Crunchy-Round`) dans `~/.icewm/themes/` et `~/.local/share/icewm/themes/`.
9. Configure l'intégration Firefox (`userChrome.css`, `userContent.css`).
10. Applique le patch de lisibilité KWin Aurorae si possible.
11. **Intégration GIMP 2.10 non destructive :**
    - Configure GIMP sur le thème système `(theme "System")` dans `gimprc` et `themerc`.
    - Sauvegarde préventivement `gimprc` sous `gimprc.crunchy-backup`.
    - Préserve l'intégralité des configurations et raccourcis clavier utilisateur (stockés dans `menurc`).
    - Permet à GIMP d'hériter automatiquement de n'importe quel thème de bureau actuel ou futur.

### Note Importante : Portabilité & Systèmes de Fichiers (FAT32 / exFAT)

Le dépôt n'utilise **aucun lien symbolique POSIX** dans son arborescence de sources. Les fichiers et dossiers sont tous physiques et autonomes :
- Cela autorise la copie directe, le clonage Git ou la décompression d'archives sur des supports amovibles (clés USB, disques externes) formatés en **FAT32** ou **exFAT**, sans risque de casser ou corrompre les thèmes.
- Pour Labwc, le compositeur reconnaît nativement le sous-dossier `openbox-3/`, et l'installateur génère une copie physique propre dans `labwc/` lors du déploiement.

### Désinstallation & Restauration

Pour supprimer la suite et restaurer l'état antérieur :

```bash
./uninstall.sh
```

**Ce que fait le désinstallateur :**
1. Supprime les dossiers thèmes `Crunchy-Dark` et `Crunchy-Light` de `~/.themes/`.
2. Supprime les schémas de couleurs KDE Plasma, décorations Aurorae, thèmes Plasma et LXQt.
3. Supprime les personnalisations injectées dans les profils Firefox.
4. **Restaure GIMP 2.10 :** restaure le `gimprc` d'origine depuis `gimprc.crunchy-backup` (ou réactive `Dark` par défaut) et réinitialise `themerc`.
5. Réinitialise les descripteurs Plasma vers les valeurs par défaut et rafraîchit l'affichage.

---

## 📌 Historique & Points de Sauvegarde

* **Tag `v-actuelle-reference` :** Version de référence en service en octobre 2026 avant la phase d'alignement unifié des fichiers `gtk.css`.
