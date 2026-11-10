#!/usr/bin/env python3
"""
tests/lint_theme.py — Suite de tests et de contrôle d'intégrité Crunchy Desktop Theme.
Vérifie :
1. L'absence de liens morts vers des assets dans tous les fichiers CSS (url(...)).
2. La conformité stricte 0 lien symbolique (compatibilité FAT32/exFAT).
3. La validité syntaxique GTK3 des feuilles de styles via Gtk.CssProvider.
"""

import os
import re
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

def test_css_asset_urls():
    print("▶ Vérification des liens d'assets dans les fichiers CSS...")
    broken = []
    total_urls = 0
    total_css = 0
    for root, dirs, files in os.walk(REPO_ROOT):
        if ".git" in root or "tests" in root or "temp" in root:
            continue
        for f in files:
            if f.endswith(".css"):
                total_css += 1
                css_path = os.path.join(root, f)
                with open(css_path, errors="ignore") as fp:
                    content = fp.read()
                urls = re.findall(r'url\s*\(\s*[\'"]?([^\'"\)]+)[\'"]?\s*\)', content)
                for u in urls:
                    total_urls += 1
                    if u.startswith("data:") or u.startswith("http") or u.startswith("#"):
                        continue
                    clean_u = u.split("?")[0].split("#")[0]
                    target = os.path.normpath(os.path.join(root, clean_u))
                    if not os.path.exists(target):
                        broken.append((os.path.relpath(css_path, REPO_ROOT), u, target))
    
    if broken:
        for c, u, t in broken:
            print(f"  ❌ LIEN MORT: dans {c} -> '{u}' (cible introuvable: {t})")
        return False
    print(f"  ✅ 100% des {total_urls} URL d'assets sont valides dans les {total_css} fichiers CSS.")
    return True

def test_zero_symlinks():
    print("▶ Vérification de la conformité FAT32 (0 lien symbolique)...")
    symlinks = []
    for root, dirs, files in os.walk(REPO_ROOT):
        if ".git" in root:
            continue
        for name in dirs + files:
            p = os.path.join(root, name)
            if os.path.islink(p):
                symlinks.append(os.path.relpath(p, REPO_ROOT))
    if symlinks:
        for s in symlinks:
            print(f"  ❌ LIEN SYMBOLIQUE INTERDIT: {s}")
        return False
    print("  ✅ 0 lien symbolique détecté (Conformité FAT32/exFAT respectée).")
    return True

def test_gtk3_css_parsing():
    print("▶ Validation du parseur CSS GTK3 via Gtk.CssProvider...")
    try:
        import gi
        gi.require_version("Gtk", "3.0")
        from gi.repository import Gtk
    except Exception as e:
        print(f"  ⚠️ PyGObject GTK3 non disponible pour le test syntaxique: {e}")
        return True

    success = True
    for theme in ["Crunchy-Dark", "Crunchy-Light"]:
        css_path = os.path.join(REPO_ROOT, theme, "gtk-3.0", "gtk.css")
        if os.path.exists(css_path):
            provider = Gtk.CssProvider()
            try:
                provider.load_from_path(css_path)
                print(f"  ✅ {theme}/gtk-3.0/gtk.css chargé sans erreur par le moteur GTK3.")
            except Exception as e:
                print(f"  ❌ Erreur de chargement GTK3 pour {theme}: {e}")
                success = False
    return success

def test_common_css_parity():
    print("▶ Vérification de la parité stricte du cœur commun (common.css)...")
    source_master = os.path.join(REPO_ROOT, "src", "gtk-3.0", "common.css")
    if not os.path.exists(source_master):
        print(f"  ❌ Fichier maître introuvable : {source_master}")
        return False
    with open(source_master, "rb") as fp:
        master_data = fp.read()

    success = True
    for theme in ["Crunchy-Dark", "Crunchy-Light"]:
        theme_common = os.path.join(REPO_ROOT, theme, "gtk-3.0", "common.css")
        if not os.path.exists(theme_common):
            print(f"  ❌ common.css introuvable dans {theme}")
            success = False
            continue
        with open(theme_common, "rb") as fp:
            theme_data = fp.read()
        if theme_data != master_data:
            print(f"  ❌ DÉSÉQUILIBRE: {theme}/gtk-3.0/common.css diffère de src/gtk-3.0/common.css ! Lancez ./tools/sync-theme.sh.")
            success = False
        else:
            print(f"  ✅ {theme}/gtk-3.0/common.css est 100% conforme au maître.")
    return success

def test_dark_menus_and_palette_invariants():
    print("▶ Vérification des Invariants Dark Menus & Palette Crunchy...")
    errors = []

    # 1. Vérification headerbar & popover sombres dans Crunchy-Light GTK3 & GTK4
    gtk3_light_colors = os.path.join(REPO_ROOT, "Crunchy-Light", "gtk-3.0", "colors.css")
    if os.path.exists(gtk3_light_colors):
        with open(gtk3_light_colors) as fp:
            c3 = fp.read()
        if not re.search(r'@define-color\s+headerbar_bg_color\s+#222226\s*;', c3):
            errors.append("Crunchy-Light/gtk-3.0/colors.css: headerbar_bg_color doit valoir #222226")
        if not re.search(r'@define-color\s+popover_bg\s+#22211e\s*;', c3):
            errors.append("Crunchy-Light/gtk-3.0/colors.css: popover_bg doit être sombre (#22211e)")

    gtk4_light_css = os.path.join(REPO_ROOT, "Crunchy-Light", "gtk-4.0", "gtk.css")
    if os.path.exists(gtk4_light_css):
        with open(gtk4_light_css) as fp:
            c4 = fp.read()
        if not re.search(r'@define-color\s+headerbar_bg_color\s+#222226\s*;', c4):
            errors.append("Crunchy-Light/gtk-4.0/gtk.css: headerbar_bg_color doit valoir #222226")

    # 2. Absence totale des reliques cyan obsolètes
    cyan_relics = ["#29d0df", "#0c4a4f"]
    for root, dirs, files in os.walk(REPO_ROOT):
        if ".git" in root or "tests" in root or "temp" in root:
            continue
        for f in files:
            if f.endswith(".css"):
                p = os.path.join(root, f)
                with open(p, errors="ignore") as fp:
                    content = fp.read().lower()
                for relic in cyan_relics:
                    if relic in content:
                        errors.append(f"{os.path.relpath(p, REPO_ROOT)}: contient le code cyan obsolète {relic}")

    # 3. Absence de menus blancs dans Cinnamon et GNOME Shell Crunchy-Light
    cinnamon_light = os.path.join(REPO_ROOT, "Crunchy-Light", "cinnamon", "cinnamon.css")
    if os.path.exists(cinnamon_light):
        with open(cinnamon_light) as fp:
            cin_content = fp.read()
        if re.search(r'\.popup-menu\s*\{[^}]*background-color\s*:\s*#ffffff', cin_content):
            errors.append("Crunchy-Light/cinnamon/cinnamon.css: .popup-menu ne doit pas être en fond blanc #ffffff")

    gnome_light = os.path.join(REPO_ROOT, "Crunchy-Light", "gnome-shell", "gnome-shell.css")
    if os.path.exists(gnome_light):
        with open(gnome_light) as fp:
            gnome_content = fp.read()
        if re.search(r'\.popup-menu-content\s*\{[^}]*background-color\s*:\s*#ffffff', gnome_content):
            errors.append("Crunchy-Light/gnome-shell/gnome-shell.css: .popup-menu-content ne doit pas être en fond blanc #ffffff")

    if errors:
        for err in errors:
            print(f"  ❌ {err}")
        return False

    print("  ✅ Invariants Dark Menus respectés à 100% (Headerbars sombres, popovers sombres, 0 relique cyan).")
    return True

def test_orphan_assets():
    print("▶ Vérification des assets orphelins (frugalité & zéro déchet)...")
    with open(os.path.join(REPO_ROOT, "src", "gtk-3.0", "common.css")) as fp:
        css = fp.read()
    referenced = set(re.findall(r'url\s*\(\s*[\'"]?assets/([^\'"\)]+)[\'"]?\s*\)', css))
    
    orphans = []
    for check_dir in ["src/gtk-3.0/assets", "Crunchy-Dark/gtk-3.0/assets", "Crunchy-Light/gtk-3.0/assets"]:
        p = os.path.join(REPO_ROOT, check_dir)
        if os.path.exists(p):
            for f in os.listdir(p):
                if f.endswith((".svg", ".png")) and f not in referenced:
                    orphans.append(f"{check_dir}/{f}")
    
    if orphans:
        for o in orphans:
            print(f"  ❌ ASSET ORPHELIN INUTILISÉ: {o}")
        return False
    print("  ✅ Zéro asset orphelin dans les répertoires gtk-3.0/assets.")
    return True

def test_install_script_validity():
    print("▶ Vérification de la cohérence des cibles de install.sh...")
    install_sh = os.path.join(REPO_ROOT, "install.sh")
    with open(install_sh) as fp:
        content = fp.read()
    
    # Check that directories referenced in test conditions exist
    checked_dirs = re.findall(r'\[ -d "\$ROOT_DIR/([^"]+)" \]', content)
    missing = []
    for d in checked_dirs:
        full_path = os.path.join(REPO_ROOT, d)
        if not os.path.exists(full_path):
            missing.append(d)
    
    if missing:
        for m in missing:
            print(f"  ❌ CIBLE FANTÔME DANS install.sh: $ROOT_DIR/{m} introuvable sur le disque !")
        return False
    print(f"  ✅ 100% des {len(checked_dirs)} répertoires sources de install.sh existent sur le disque.")
    return True

def main():
    print("======================================================================")
    print("  Audit Qualité & Intégrité — Crunchy Desktop Theme")
    print("======================================================================")
    
    r1 = test_css_asset_urls()
    r2 = test_zero_symlinks()
    r3 = test_common_css_parity()
    r4 = test_gtk3_css_parsing()
    r5 = test_dark_menus_and_palette_invariants()
    r6 = test_orphan_assets()
    r7 = test_install_script_validity()
    
    print("======================================================================")
    if r1 and r2 and r3 and r4 and r5 and r6 and r7:
        print("  🎉 Tous les tests d'intégrité sont passés avec succès !")
        print("======================================================================")
        sys.exit(0)
    else:
        print("  💥 Échec d'un ou plusieurs tests d'intégrité.")
        print("======================================================================")
        sys.exit(1)

if __name__ == "__main__":
    main()
