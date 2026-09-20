# Enriquecer data/rasgos.csv con rasgos funcionales de BIEN (Botanical Information
# and Ecology Network) para las especies que Rasgos-CL no cubre (helechos, trepadoras
# herbáceas y epífitas no leñosas).
#
# Rasgos-CL (https://github.com/dylancraven/Rasgos-CL) ya fue incorporado directamente
# desde su repositorio GitHub (ver commit que agrega las columnas de rasgos a
# data/rasgos.csv) — solo cubrió *Gaultheria insana* porque está acotado a plantas
# leñosas. Este script llena el resto vía BIEN.
#
# Requiere ejecutarse en una máquina con R y acceso a internet normal: el paquete BIEN
# habla con la base de datos del proyecto en bien.nceas.ucsb.edu, que no es alcanzable
# desde el entorno de nube donde se preparó este script (dominio fuera de la lista
# blanca de red), así que esta parte quedó pendiente de correr localmente.
#
# Uso:
#   Rscript scripts/enriquecer_rasgos_bien.R

if (!requireNamespace("BIEN", quietly = TRUE)) {
  install.packages("BIEN", repos = "https://cloud.r-project.org")
}
library(BIEN)
library(dplyr)
library(readr)

rasgos <- read_csv("data/rasgos.csv", show_col_types = FALSE)

# Solo consultar BIEN para especies sin datos aún (trait_source == "Sin dato").
# "Sin dato" es también lo que queda mostrado en el sitio si BIEN no cubre la especie,
# así que este filtro simplemente reintenta todo lo que no viene ya de Rasgos-CL.
pendientes <- rasgos$species[rasgos$trait_source == "Sin dato"]

traits_bien <- c(
  "whole plant height",
  "leaf area",
  "leaf area per leaf dry mass",  # SLA
  "seed mass",
  "stem wood density"
)

trait_col_map <- c(
  "whole plant height" = "plant_height_m",
  "leaf area" = "leaf_area_mm2",
  "leaf area per leaf dry mass" = "sla_mm2_mg",
  "seed mass" = "seed_mass_mg",
  "stem wood density" = "wood_density_g_cm3"
)

resultados <- BIEN_trait_traitbyspecies(species = pendientes, trait = traits_bien)

if (nrow(resultados) == 0) {
  message("BIEN no devolvió registros para ninguna de las especies pendientes ",
          "(esperable para helechos: BIEN cubre sobre todo angiospermas). ",
          "Revisar cobertura manualmente o dejar 'Sin dato' en el sitio.")
} else {
  resumen <- resultados %>%
    group_by(scrubbed_species_binomial, trait_name) %>%
    summarise(valor = mean(as.numeric(trait_value), na.rm = TRUE), .groups = "drop") %>%
    mutate(columna = trait_col_map[trait_name]) %>%
    filter(!is.na(columna))

  for (i in seq_len(nrow(resumen))) {
    sp <- resumen$scrubbed_species_binomial[i]
    col <- resumen$columna[i]
    val <- resumen$valor[i]
    fila <- which(rasgos$species == sp)
    if (length(fila) == 1) {
      rasgos[[col]][fila] <- val
      rasgos$trait_source[fila] <- ifelse(
        rasgos$trait_source[fila] == "Sin dato", "BIEN", rasgos$trait_source[fila]
      )
    }
  }

  # Especies que BIEN tampoco cubrió (helechos, en general) quedan como "Sin dato" sin cambios.
  write_csv(rasgos, "data/rasgos.csv")
  message("data/rasgos.csv actualizado con rasgos de BIEN donde hubo cobertura.")
}
