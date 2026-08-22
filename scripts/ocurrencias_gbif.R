pacman::p_load(
  tidyverse,
  rgbif,
  terra,
  here,
  CoordinateCleaner,
  bdc,
  rnaturalearth,
  rnaturalearthdata,
  htmlwidgets
)

here()

especies <- list.files("especies/", pattern = ".qmd") %>%
  str_remove_all(".qmd") %>%
  str_replace_all("-", " ")

especies <- bdc_clean_names(especies)


chile <- ne_countries(
  scale = "medium",
  country = "Chile",
  returnclass = "sv"
) %>%
  forceCCW() %>%
  geom(wkt = TRUE)

ocurrencias <- map(1:nrow(especies), function(x) {
  filename <- str_replace_all(especies[x, ]$scientificName, " ", "-")
  especie <- especies[x, ]$names_clean
  occ_search(
    scientificName = especie,
    limit = 100000,
    hasCoordinate = TRUE,
    geometry = chile,
    geom_big = "bbox"
  ) %>%
    pluck("data") %>%
    mutate(species = filename) %>%
    select(
      species,
      decimalLongitude,
      decimalLatitude,
      countryCode,
      year,
      basisOfRecord
    ) %>%
    clean_coordinates(
      lon = "decimalLongitude",
      lat = "decimalLatitude",
      species = "species",
      tests = c(
        "capitals",
        "centroids",
        "equal",
        "gbif",
        "institutions",
        "zeros"
      )
    ) %>%
    filter(.summary == TRUE) %>%
    select(-.summary) %>%
    write_csv(here("ocurrencias", paste0(filename, ".csv")))
})

oc_files <- list.files(here("ocurrencias"), pattern = ".csv", full.names = TRUE)

oc_data <- oc_files %>%
  set_names(tools::file_path_sans_ext(basename(oc_files))) %>%
  map(~ read_csv(.x) %>% filter(!is.na(decimalLongitude) & !is.na(decimalLatitude))) %>%
  keep(~ nrow(.x) > 0)

oc_list <- map(
  oc_data,
  ~ vect(.x, geom = c("decimalLongitude", "decimalLatitude"), crs = "EPSG:4326")
)

mapas <- map(oc_list, plet)

dir.create(here("mapas"), showWarnings = FALSE)

iwalk(mapas, function(widget, nm) {
  saveWidget(
    widget,
    file = here("mapas", paste0(nm, ".html")),
    selfcontained = TRUE
  )
})
