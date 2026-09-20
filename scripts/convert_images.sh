#!/usr/bin/env bash
# Convierte las imágenes de especies a WebP (calidad 80) preservando los
# originales. Salida: images/especies/webp/<nombre>.webp
# Uso: bash scripts/convert_images.sh
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)/images/especies"
DST="$SRC/webp"
mkdir -p "$DST"

shopt -s nullglob nocaseglob
for img in "$SRC"/*.jpg "$SRC"/*.jpeg "$SRC"/*.png; do
  base="$(basename "$img")"
  out="$DST/${base%.*}.webp"
  if [ ! -f "$out" ]; then
    convert "$img" -quality 80 -define webp:method=6 "$out"
  fi
done

total_src=$(du -ch "$SRC"/*.jpg "$SRC"/*.jpeg "$SRC"/*.png 2>/dev/null | tail -1 | cut -f1)
total_webp=$(du -sh "$DST" | cut -f1)
echo "Originales: $total_src → WebP: $total_webp"
echo "Actualice las referencias en especies/*.qmd a images/especies/webp/<nombre>.webp"
