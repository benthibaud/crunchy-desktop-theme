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
        if ".git" in root or "tests" in root:
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

def main():
    print("======================================================================")
    print("  Audit Qualité & Intégrité — Crunchy Desktop Theme")
    print("======================================================================")
    
    r1 = test_css_asset_urls()
    r2 = test_zero_symlinks()
    r3 = test_gtk3_css_parsing()
    
    print("======================================================================")
    if r1 and r2 and r3:
        print("  🎉 Tous les tests d'intégrité sont passés avec succès !")
        print("======================================================================")
        sys.exit(0)
    else:
        print("  💥 Échec d'un ou plusieurs tests d'intégrité.")
        print("======================================================================")
        sys.exit(1)

if __name__ == "__main__":
    main()
