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
| **Qt / KDE Plasma** | QSS & Color scheme | Intégration Qt5/Qt6, schéma de couleurs `.colors`. |
| **XFCE (XFWM4)** | SVG 100% vectoriel | Boutons Square (radius 5px) et Round, Whisker Menu intégré. |
| **Cinnamon & GNOME** | Shell CSS | Panneaux sombres, menus et popups contextuels contrastés. |
| **Openbox & Metacity** | XML / themerc | Dégradés horizontaux et boutons vectoriels coordonnés. |

---

## 🚀 Installation Rapide

Pour installer les deux thèmes dans votre espace utilisateur (`~/.themes`) :

```bash
cd Crunchy-Dark && ./install.sh
cd ../Crunchy-Light && ./install.sh
```

Ou copiez simplement les dossiers `Crunchy-Dark` et `Crunchy-Light` dans `~/.themes/` ou `/usr/share/themes/`.

---

## 📌 Historique & Points de Sauvegarde

* **Tag `v-actuelle-reference` :** Version de référence en service en octobre 2026 avant la phase d'alignement unifié des fichiers `gtk.css`.
