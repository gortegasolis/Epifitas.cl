#!/usr/bin/env Rscript
# Combina los CSV de ocurrencias por especie en un único GeoJSON para el
# mapa general de distribucion.qmd.
# Uso: Rscript scripts/combinar_ocurrencias.R
pacman::p_load(tidyverse, jsonlite, here)

oc_files <- list.files(here("ocurrencias"), pattern = "\\.csv$", full.names = TRUE)

forma_por_especie <- list.files(here("especies"), pattern = "\\.qmd$", full.names = TRUE) |>
  map_dfr(function(f) {
    txt <- read_lines(f, n_max = 10)
    cats <- str_extract(txt[str_detect(txt, "^categories:")], "(?<=\\[).*(?=\\])") |>
      str_split(",\\s*") |> pluck(1)
    tibble(
      slug = tools::file_path_sans_ext(basename(f)),
      forma = case_when(
        "Trepadoras" %in% cats ~ "trepadora",
        "Hemiepífitas" %in% cats ~ "hemiepifita",
        TRUE ~ "epifita"
      )
    )
  })

features <- map_dfr(oc_files, function(f) {
  slug <- tools::file_path_sans_ext(basename(f))
  read_csv(f, show_col_types = FALSE) |>
    filter(!is.na(decimalLongitude), !is.na(decimalLatitude)) |>
    mutate(slug = slug)
}) |>
  left_join(forma_por_especie, by = "slug") |>
  mutate(
    nombre = str_replace_all(slug, "-", " ") |>
      str_to_sentence()
  )

geojson <- list(
  type = "FeatureCollection",
  features = pmap(
    list(features$decimalLongitude, features$decimalLatitude,
         features$slug, features$nombre, features$forma,
         features$year, features$basisOfRecord),
    function(lon, lat, slug, nombre, forma, yr, bor) {
      list(
        type = "Feature",
        geometry = list(type = "Point", coordinates = c(lon, lat)),
        properties = list(
          species = slug, nombre = nombre, forma = forma,
          year = yr, basisOfRecord = bor
        )
      )
    }
  )
)

write_json(geojson, here("ocurrencias", "todas-las-especies.geojson"),
           auto_unbox = TRUE, digits = 6)
message("GeoJSON escrito: ", nrow(features), " registros")
