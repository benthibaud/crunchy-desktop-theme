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

---

## 4. Politique de Gestion des Assets & Zéro Relique

1. **Aucun Fichier Fantôme :**
   - Tout fichier `.rc` présent dans `gtk-2.0/apps/` doit être formellement inclus dans `gtkrc`. Les reliques non appelées sont proscrites.
2. **Pas d'Assets Inutilisés :**
   - Les dossiers `assets/` ne doivent contenir que des fichiers SVG/PNG activement référencés par les feuilles de style CSS.
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

