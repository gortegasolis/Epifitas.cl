#!/usr/bin/env python3
"""Extrae la tabla Markdown de referencias.qmd a data/referencias.csv.

Uso: python3 scripts/extraer_referencias.py
Vuelve a generar el CSV si se edita manualmente la tabla en referencias.qmd.
"""
import csv
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
text = (ROOT / "referencias.qmd").read_text()

rows = []
in_table = False
for line in text.splitlines():
    if line.startswith("| Autor |"):
        in_table = True
        continue
    if in_table:
        if not line.startswith("|"):
            break
        if set(line) <= set("|- "):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) >= 5:
            rows.append(cells[:5])

out, seen = [], set()
for autor, titulo, anio, revista, tipo in rows:
    m = re.match(r"^(.*?)\s*Vol\.\s*(.*)$", revista)
    journal = m.group(1).strip().title() if m else revista.strip()
    vol = pages = ""
    if m:
        mv = re.match(r"([\d()\-, SI]+?)(?:,\s*pp\.\s*(.*))?$", m.group(2))
        if mv:
            vol = mv.group(1).strip().rstrip(",")
            pages = (mv.group(2) or "").strip()
    key = (autor.lower(), titulo.lower(), anio)
    dup = "yes" if key in seen else ""
    seen.add(key)
    out.append([autor, titulo, anio, journal, vol, pages, tipo, dup])

out_path = ROOT / "data" / "referencias.csv"
out_path.parent.mkdir(exist_ok=True)
with out_path.open("w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["author", "title", "year", "journal", "volume", "pages", "type", "possible_duplicate"])
    w.writerows(out)
print(f"Escritas {len(out)} referencias en {out_path}")
