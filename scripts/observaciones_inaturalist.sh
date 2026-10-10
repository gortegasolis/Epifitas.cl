#!/usr/bin/env bash
# Descarga las 12 observaciones más recientes del proyecto de iNaturalist y
# guarda solo los campos que usa ciencia-ciudadana.qmd en data/inaturalist.json.
# Uso: bash scripts/observaciones_inaturalist.sh
set -euo pipefail

PROJECT_ID="epifitas-hemiepifitas-y-trepadoras-de-chile"
SALIDA="data/inaturalist.json"
URL="https://api.inaturalist.org/v1/observations?project_id=${PROJECT_ID}&order_by=observed_on&order=desc&per_page=12&photos=true"

# Se escribe a un archivo temporal para no dejar un JSON a medias si falla la descarga
tmp=$(mktemp)
curl -fsSL --retry 3 -H "User-Agent: epifitas.cl (https://epifitas.cl)" "$URL" |
  jq '{
    actualizado: (now | strftime("%Y-%m-%d")),
    observaciones: [.results[] | {
      id,
      observed_on,
      usuario: .user.login,
      nombre: ((.taxon.preferred_common_name // .taxon.name) // "Sin identificar"),
      foto: (.photos[0].url // null | if . then sub("square"; "medium") else . end)
    }]
  }' > "$tmp"
mv "$tmp" "$SALIDA"
echo "Guardadas $(jq '.observaciones | length' "$SALIDA") observaciones en $SALIDA"
