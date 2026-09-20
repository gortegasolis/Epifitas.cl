# Epifitas.cl
 Sitio web sobre epífitas, trepadoras y otras plantas que viven sobre los árboles.

## Agregar una nueva ficha de especie

Cada ficha en `especies/*.qmd` debe incluir en su frontmatter YAML:

- `title` y `subtitle` (nombre científico en cursiva y nombres comunes).
- `description`: resumen de una línea (usado por buscadores y tarjetas sociales).
- `image`: ruta a la imagen destacada en `images/especies/webp/` (convertir con `bash scripts/convert_images.sh`).
- `categories`: una o más de `Epífitas`, `Trepadoras`, `Hemiepífitas`, según la "Forma de crecimiento" declarada en la ficha. Estas etiquetas alimentan las páginas de listado en `categorias/`.

## Scripts

- `scripts/ocurrencias_gbif.R`: descarga y limpia registros GBIF por especie (`ocurrencias/`) y genera los mapas por especie (`mapas/`).
- `scripts/combinar_ocurrencias.R`: combina los CSV en `ocurrencias/todas-las-especies.geojson` para el mapa general de `distribucion.qmd`.
- `scripts/extraer_referencias.py`: regenera `data/referencias.csv` desde la tabla de `referencias.qmd`.
- `scripts/convert_images.sh`: convierte `images/especies/` a WebP en `images/especies/webp/` (los originales se preservan).
