# Architecture & Charte Technique — Crunchy Desktop Theme

Ce document constitue la référence officielle et la mémoire pérenne de l'architecture du thème de bureau **Crunchy** (`Crunchy-Light` et `Crunchy-Dark`). Il garantit la cohérence transverse entre les toolkits graphiques Linux supportés (**GTK 2.0**, **GTK 3.0**, **GTK 4.0**).

---

## 1. Identité Visuelle & Principes Fondateurs

1. **Contraste & Économie Visuelle :**
   - Palette claire sobre et reposante (`#f8f8f9` pour le fond de fenêtre, `#ffffff` pour les vues et cartes documentaires).
   - En-têtes de fenêtres et barres de menus sombres unifiés (`#222226` et `#242320`), que le thème soit en mode sombre (*Dark*) ou clair (*Light*).
2. **Signature Crunchy :**
   - Couleur d'accentuation verte vive : `#35A854`.
   - Dégradé vert horizontal sur les sélections et survols de menus :
     - Gauche : `#206e33` (vert profond)
     - Centre (55%) : `#35ad54` (vert vif)
     - Droite : `#48dc6f` (vert lumineux)
3. **Frugalité Low-Tech & Anti-Boîte Noire :**
   - Pas de dépendances tierces opaques.
   - Contrôles dessinés en vectoriel / CSS natif partout où c'est possible (éradication des PNG/SVG inutiles).
   - Code CSS linéaire et factorisé.

---

## 2. Matrice d'Équivalence des Jetons de Thème (Tokens)

### Thème Crunchy-Light

| Rôle Sémantique | Token GTK 3.0 / GTK 4.0 | Variable GTK 2.0 (`gtk-color-scheme`) | Valeur Hexadécimale |
| :--- | :--- | :--- | :--- |
| **Accent Principal** | `@accent_color` / `@selected_bg_color` | `selected_bg_color` | `#35A854` |
| **Texte sur Accent** | `@accent_fg_color` / `@selected_fg_color` | `selected_fg_color` | `#ffffff` |
| **Fond de Fenêtre** | `@window_bg_color` / `@theme_bg_color` | `bg_color` | `#f8f8f9` |
| **Texte de Fenêtre** | `@window_fg_color` / `@theme_fg_color` | `fg_color` | `#2e2e33` |
| **Fond des Vues/Listes** | `@view_bg_color` / `@theme_base_color` | `base_color` | `#ffffff` |
| **Texte des Vues/Listes**| `@view_fg_color` / `@theme_text_color` | `text_color` | `#303030` |
| **Fond En-tête (Titlebar)** | `@headerbar_bg_color` | `bg_color_dark` | `#222226` |
| **Texte En-tête** | `@headerbar_fg_color` | `fg_color_dark` | `#ffffff` |
| **Bordure En-tête** | `@headerbar_border_color` | `borders` | `#18181b` |
| **Fond Menubar** | `@menubar_bg_left` | `menubar_bg_left` | `#242320` |
| **Texte Menubar** | `@menubar_fg` | `menubar_fg` | `#ffffff` |
| **Fond Popover / Menu** | `@menu_bg_left` / `@popover_bg_color` | `menu_bg_left` | `#22211e` |
| **Bordures d'Éléments** | `@borders` | `borders` | `#c8c8ce` |
| **Boutons** | `@button_bg` | Calculé (`bg_color`) | `#f0f0f4` |
| **Boutons (Survol)** | `@button_hover_bg` | Calculé (`#ffffff`) | `#ffffff` |
| **Interrupteurs (Switch)**| `@switch_bg` | Calculé | `#d8d8de` |

### Thème Crunchy-Dark

| Rôle Sémantique | Token GTK 3.0 / GTK 4.0 | Variable GTK 2.0 (`gtk-color-scheme`) | Valeur Hexadécimale |
| :--- | :--- | :--- | :--- |
| **Accent Principal** | `@accent_color` / `@selected_bg_color` | `selected_bg_color` | `#35A854` |
| **Texte sur Accent** | `@accent_fg_color` / `@selected_fg_color` | `selected_fg_color` | `#ffffff` |
| **Fond de Fenêtre** | `@window_bg_color` / `@theme_bg_color` | `bg_color` | `#2e2e33` |
| **Texte de Fenêtre** | `@window_fg_color` / `@theme_fg_color` | `fg_color` | `#ffffff` |
| **Fond des Vues/Listes** | `@view_bg_color` / `@theme_base_color` | `base_color` | `#242321` |
| **Texte des Vues/Listes**| `@view_fg_color` / `@theme_text_color` | `text_color` | `#dadada` |
| **Fond En-tête (Titlebar)** | `@headerbar_bg_color` | `bg_color_dark` | `#222226` |
| **Texte En-tête** | `@headerbar_fg_color` | `fg_color_dark` | `#ffffff` |
| **Bordure En-tête** | `@headerbar_border_color` | `borders` | `#18181b` |
| **Fond Menubar** | `@menubar_bg_left` | `menubar_bg_left` | `#242320` |
| **Texte Menubar** | `@menubar_fg` | `menubar_fg` | `#ffffff` |
| **Fond Popover / Menu** | `@menu_bg_left` / `@popover_bg_color` | `menu_bg_left` | `#22211e` |
| **Bordures d'Éléments** | `@borders` | `borders` | `#202023` |
| **Boutons** | `@button_bg` | Calculé | `#38383e` |
| **Boutons (Survol)** | `@button_hover_bg` | Calculé | `#484850` |
| **Interrupteurs (Switch)**| `@switch_bg` | Calculé | `#33322E` |

---

## 3. Règles d'Or & Conventions Validées

### A. Règle des 55 % d'Opacité sur Éléments Désactivés
Les éléments inactifs (items de menu, contrôles grisés) doivent être strictement calibrés à **55 % d'opacité** :
```css
/* GTK3 & GTK4 */
menuitem:disabled,
menuitem:disabled label,
.menuitem:disabled label {
  color: alpha(#ffffff, 0.55);
}
```
En GTK2 :
```ini
bg[INSENSITIVE] = shade (0.55, @fg_color_dark)
fg[INSENSITIVE] = shade (0.55, @fg_color_dark)
```
*Justification ergonomique :* Garantit un contraste suffisant pour déchiffrer le libellé sans ambiguïté, tout en marquant distinctement l'état non cliquable.

### B. Prise en Charge Navigateurs (Brave, Chromium, Firefox) & États `:backdrop`
- Chromium et Brave interrogent le sélecteur GTK `menubar:backdrop label.title` pour déterminer la couleur de premier plan des onglets inactifs lorsque la fenêtre n'a pas le focus.
- Dans les thèmes à en-tête sombre, ce sélecteur doit impérativement renvoyer une couleur claire (`#c8c8cf` ou `#a7a7ab`) pour interdire formellement le texte noir sur fond sombre en arrière-plan.
- Règle explicite ajoutée pour couvrir les modes CSD et SSD :
```css
.chromium tab, window.chromium tab,
.chromium tab:backdrop, window.chromium tab:backdrop {
  color: #c8c8cf;
}
```

### C. Fenêtres Maximisées & Jonction Titre/Menubar
- Les fenêtres maximisées adoptent un fond d'en-tête sombre uniforme `#222226` avec une bordure inférieure fine `#18181b` et marge nulle (`margin: 0; padding-bottom: 2px`).
- La menubar se connecte sans interstice (`padding: 0; border-bottom: 1px solid #18181b; background-color: #242320;`).

### D. Gestionnaires de Fichiers (Thunar, Nemo, Caja, Nautilus, PCManFM)
- **Barre de chemin (Path-bar) :** Boutons légèrement éclaircis `#42413c` (survol `#52514a`, actif vert `#35A854`), texte blanc.
- **Barre latérale (Places Sidebar) :** Rangée sélectionnée en vert `#35A854`, texte blanc et typographie en gras (`font-weight: bold`).

### E. Dégradé Horizontal des Menus & Parité GTK2 / GTK3
- **Identité du Dégradé :** La sélection active des menus déroulants (`GtkMenuItem:hover` / `state = PRELIGHT`) utilise un dégradé strictement **horizontal** :
  `linear-gradient(to right, #206e33 0%, #35ad54 55%, #48dc6f 100%)`
- **Contrainte Technique GTK2 (Murrine) :** Le moteur Murrine ne permet pas de générer de dégradés horizontaux natifs (la directive `gradient_shades` n'agit que sur l'axe vertical).
- **Architecture de Rendu GTK2 :**
  - Pour garantir une parité visuelle 100% avec GTK3 sans impacter la stabilité de GIMP 2.10, les styles `menu_item` et `menubar_item` dans `gtk-2.0/gtkrc` s'appuient sur le moteur `pixmap` (`engine "pixmap"`) pour l'état `state = PRELIGHT`.
  - Un asset 9-slice étirable (`assets/menu_item_prelight.png`, 48x24 px avec liseré lumineux supérieur et coins arrondis 2px) est utilisé.
  - Toutes les autres composantes de l'interface GTK2 continuent d'être calculées et rendues dynamiquement par Murrine.

---

## 4. Politique de Gestion des Assets & Zéro Relique

1. **Aucun Fichier Fantôme :**
   - Tout fichier `.rc` présent dans `gtk-2.0/apps/` doit être formellement inclus dans `gtkrc`. Les reliques non appelées sont proscrites.
2. **Pas d'Assets Inutilisés :**
   - Les dossiers `assets/` ne doivent contenir que des fichiers SVG/PNG activement référencés par les feuilles de style CSS ou les fichiers `gtkrc`.
   - GTK2 contient uniquement l'asset 9-slice horizontal `assets/menu_item_prelight.png`.
   - GTK4 ne contient que les 6 SVG vectoriels de contrôles de fenêtre (`close`, `maximize`, `hide` et leurs états `:hover`).

---

## 5. Déploiement & Cycle de Vie (`install.sh` / `uninstall.sh`)

### A. Détection Dynamique de l'Arborescence
Les scripts `install.sh` et `uninstall.sh` déterminent automatiquement le répertoire racine (`ROOT_DIR`), qu'ils soient exécutés depuis la racine du dépôt ou depuis un sous-dossier (`Crunchy-Dark/`, `Crunchy-Light/`).

### B. Intégration Non-Destructive de GIMP 2.10
- GIMP 2.10 gère son interface graphique via GTK2, mais force par défaut un thème interne (`Dark`) codé en dur avec le moteur pixmap dans `/usr/share/gimp/2.0/themes/Dark/gtkrc`, ce qui ignore le thème du bureau.
- **Délégation au Thème Système :** L'instruction `(theme "System")` dans `~/.config/GIMP/2.10/gimprc` et `themerc` délègue intégralement le rendu au thème GTK2 du système en cours. Dès lors, GIMP s'adapte automatiquement à tout thème actif, actuel ou futur.
- **Préservation Absolue des Données Utilisateur :**
  - Les raccourcis clavier personnalisés sont stockés séparément par GIMP dans `menurc`. Ce fichier n'est jamais altéré.
  - Avant toute modification de `gimprc`, une sauvegarde préventive `gimprc.crunchy-backup` est générée.
  - La modification est ciblée via expression régulière (`sed`) pour préserver toutes les options préexistantes de l'utilisateur.
- **Restauration Intégrale (`uninstall.sh`) :**
  - La désinstallation réintègre le fichier `gimprc.crunchy-backup` d'origine s'il existe, ou rétablit proprement la valeur `(theme "Dark")`.
  - Aucune trace orpheline n'est conservée.

---

## 6. Gestionnaires de Fenêtres Autonomes (SSD) & Portabilité Frugale

### A. Découplage SSD / CSD & Boutons « Square Relief »
- Contrairement aux applications CSD (GTK3 / GTK4) qui dessinent leur en-tête directement en interne via `gtk.css`, les gestionnaires de fenêtres légers (IceWM, Openbox, Labwc, Fluxbox, Metacity, XFWM4) gèrent la décoration de façon indépendante (*Server-Side Decorations*).
- **Identité Square en Relief :** L'ADN visuel historique de Crunchy repose sur des boutons carrés adoucis (radius 2.5px) avec effet de biseau supérieur lumineux, ombre inférieure et glyphe estampé en creux.
  - **Openbox (X11) :** Les boutons utilisent des masques XBM 1-bit nets (évitant le crénelage inévitable des cercles sans antialiasing) combinés aux capacités de relief natives de `themerc` (`raised` en état normal, `sunken` lors du clic).
  - **Labwc (Wayland) :** Prise en charge vectorielle SVG complète avec dégradés verticaux organiques, lueur verte Crunchy sur `close` (`#78ae74` -> `#599455`, survol `#a4d4a2`) et reflets argentés sur `max` et `iconify`.
  - **IceWM :** Deux thèmes autonomes complets intégrés : `Crunchy-Square` (boutons carrés en relief, design de prédilection) et `Crunchy-Round` (boutons ronds Ambiance).
  - **Fluxbox :** Deux styles autonomes complets intégrés dans `fluxbox-styles/` : `Crunchy-Square` et `Crunchy-Round`. Fluxbox implémente nativement les dégradés horizontaux via `menu.frame: flat gradient horizontal` (`#22211e` -> `#484741`) et `menu.hilite: flat gradient horizontal` (`#206e33` -> `#48dc6f`), garantissant une harmonie visuelle totale avec les menus GTK3 et GTK2.
  - **XFWM4 (XFCE) & Metacity-1 :** Boutons vectoriels SVG originaux préservés et standardisés rigoureusement au format 20×20 px. Résolution du défaut géométrique historique (où `close` mesurait 20×20 px alors que `hide`, `maximize` et `unmaximize` mesuraient 18.5×20 px). Alignement au sous-pixel près, conservation intégrale des dégradés lumineux (vert Crunchy pour `close`, aluminium brossé subtil pour les contrôles de fenêtre, ombre intérieure 3D en état `pressed`), et transparence native des boutons d'action secondaires (`shade`, `stick`, `menu`, `above`) sur les bandeaux de titre.

### B. Règle Impérative de Portabilité des Fichiers (Zéro Lien Symbolique)
- **Constat d'Ingénierie :** Les systèmes de fichiers non-POSIX couramment utilisés sur supports amovibles (**FAT32**, **exFAT**) ne supportent pas les liens symboliques UNIX. La présence de symlinks dans un dépôt entraîne leur conversion en fichiers texte corrompus ou des échecs d'écriture lors de la copie sur clé USB.
- **Standard Crunchy :** L'arborescence des sources du projet est strictement exempte de tout lien symbolique. Chaque composant est autonome dans son propre dossier physique.
- **Stratégie Labwc :** Labwc recherche nativement le dossier `openbox-3/` en l'absence de dossier `labwc/`. Pour une compatibilité absolue avec les outils tiers exigeant un répertoire nommé `labwc`, le script `install.sh` réalise une copie physique directe (`openbox-3/` vers `labwc/`) au moment de l'installation sur la machine cible.

---

## 7. Environnements de Bureau Complexes (Cinnamon & GNOME Shell)

### A. Panneau Sombre Unifié (Dark & Light)
- Dans la tradition ergonomique Ambiance / Radiance, le panneau de bureau (`#panel`, `.panel-top`, `.panel-bottom`) reste **strictement sombre** (`#222226` avec bordure `#18181b`), que le thème soit en mode Dark ou Light.
- **Rationnel ergonomique :** Garantit le contraste maximal et la lisibilité immédiate des icônes du systray, de l'horloge, des indicateurs de statut et des applets sans nécessiter d'icônes spécifiques claires/sombres.

### B. Déclinaisons Crunchy-Dark vs Crunchy-Light
- **Crunchy-Dark :**
  - Popups, menus déroulants, menu d'applications Kickoff (`.menu`, `.popup-menu`) et dialogues en fond sombre dégradé horizontal `#22211e` $\rightarrow$ `#484741`, bordure `#18181b` et texte blanc `#ffffff`.
  - Sélections et survols en dégradé vert horizontal Crunchy : `background-gradient-direction: horizontal;` (`#206e33` $\rightarrow$ `#48dc6f`).
- **Crunchy-Light :**
  - Popups, menus déroulants, menu Kickoff, dialogues modaux et notifications basculent en fond clair document `#ffffff` / `#f8f8f9` avec bordures claires fines `#dcdce2` et texte sombre `#2e2e33`.
  - Champs de recherche (`#menu-search-entry`) sur fond blanc avec ombre interne subtile.
  - Sélections actives conservant le vert Crunchy avec libellé contrasté en blanc.



