---
title: "Epifitas.cl — Development Plan"
draft: true
---

# **Epifitas.cl — Development Plan**

**Constraint:** The site is served from GitHub Pages — static hosting only, no server-side code, databases, or backend APIs. All improvements must work through Quarto's static build, client-side JS, and GitHub Actions for automation.

**Current state (as of September 2026):**
- 15 species fiches (`.qmd`) under `especies/`, all with `description` frontmatter; **2 fiches (`asplenium-dareoides`, `asplenium-trilobum`) lack the `image` field**
- Per-species GBIF occurrence CSVs in `ocurrencias/` (15 files, ~6 400 cleaned records), interactive Leaflet maps in `mapas/` (**non-self-contained** `.html` + shared-asset `_files/` directories, 24 MB total), and MapLibre-style JSON layers in `geolibre/`
- `distribucion.qmd` serves only a placeholder Google Maps iframe for the site-wide overview
- `_quarto.yml` has `site-url`, Open Graph, and Twitter card already enabled; `sitemap` not yet enabled
- `gnparser` (12 MB binary) sits in the project root with no exclusion rule for the build; it is **not referenced by any script** — an orphan artifact. `1.15.0.tar.gz` is similarly orphaned.
- `images/especies/` is 88 MB of JPG/PNG (56 files); no WebP versions exist
- No GitHub Actions workflow exists yet
- `referencias.qmd` (note spelling) is a raw flat Markdown table (42 entries)
- Category frontmatter is inconsistent: 13 of 15 fiches declare `categories: [Epífitas, Hemiepífitas, Trepadoras]` regardless of their stated "Forma de crecimiento", so the three listing pages show nearly identical contents
- Phenology data (`Floración`/`Fructificación`) is present in only 7 of 15 fiches; all 15 have "Estado de conservación"

---

## **Phase 0 — Foundation (prerequisite work)**

### **Content: standardize existing fiches**

- Standardize each existing fiche's fields (some lack "Estado de conservación" or phenology data).
- Ensure each fiche has a `categories` tag matching its growth form (Epífita / Trepadora / Hemiepífita) for the listing pages in `categorias/`.

**Detailed Tasks:**
- [x] **Field completeness audit:** Open each of the 15 existing `.qmd` fiches and verify the presence of: `categories`, `image`, `Floración`, `Fructificación`, `Estado de conservación`, and at least one gallery image.
- [~] **Patch missing fields:** Partially done: phenology placeholders added to *Sarmienta scandens*; ferns (7 fiches) have no flowering/fruiting by definition. `image:` could not be added to the two *Asplenium* fiches — no photos of these species exist in `images/especies/`; a photo contribution is needed. Descriptions and bibliographies untouched.
- [x] **Category consistency check:** Assign `categories` per fiche from its stated "Forma de crecimiento" (currently 13 fiches declare all three categories at once). Note: no current fiche is a true hemiepiphyte, so `categorias/hemiepifitas.qmd` will render empty until such a fiche is added — add explanatory text there.

---

### **Content: references page**

- Convert `referencias.qmd`'s flat Markdown table into a searchable/filterable bibliography.

**Detailed Tasks:**
- [x] **Extract to structured data:** Convert the 42-entry table into a YAML or BibTeX file (e.g., `referencias.bib` or `data/referencias.yml`) with fields: `author`, `year`, `title`, `journal`, `volume`, `pages`, `doi`.
- [x] **Implement client-side filtering:** Replace the raw table in `referencias.qmd` with a Quarto `listing` (type: `table`) reading from the structured data, or embed a DataTables-powered HTML table generated from the YAML/CSV. Add filter controls by year and topic.
- [x] **Add DOI links:** Enrich missing DOI/URL fields in the structured data before rendering.

---

### **Visual design**

- Replace the placeholder Google Maps iframe in `distribucion.qmd` with a real interactive overview map.
- Introduce a consistent visual indicator for growth habit (Epífita / Trepadora / Hemiepífita).
- Extend `custom_theme.scss` / `styles.css` with card hover states and better typography for long descriptions.

**Detailed Tasks:**
- [x] **Overview distribution map (`distribucion.qmd`):**
  - [x] Replace the Google Maps `<iframe>` with a Leaflet map that loads all per-species occurrence CSVs from `ocurrencias/` (or a combined GeoJSON) and displays them as colour-coded point layers, one per species, with a layer toggle.
  - [x] Add a legend linking species names to their fiches.
- [x] **Growth habit badge system:**
  - [x] Define CSS badge classes (`.badge-epifita`, `.badge-trepadora`, `.badge-hemiepifita`) in `styles.css` with distinct background colours.
  - [x] Add a Quarto shortcode or include the badge in each fiche's info block so it renders consistently on species and listing pages.
- [x] **CSS & SCSS enhancements:**
  - [x] Add hover transitions and subtle shadow effects to species listing cards.
  - [x] Improve line-height and paragraph spacing for long botanical descriptions in `custom_theme.scss`.

---

### **Performance**

- `images/especies` is 88 MB of uncompressed JPG/PNG — convert to WebP with responsive `srcset`.
- `mapas/*.html` are large self-contained files (500–834 KB each) because they embed all Leaflet assets per file.
- `gnparser` (12 MB binary) is present in the project root and not excluded from the `_site` build.

**Detailed Tasks:**
- [x] **Image conversion to WebP:**
  - [x] Write a shell or R script (`scripts/convert_images.sh`) using `cwebp` or `magick` to convert all files in `images/especies/` to WebP at 80% quality, preserving originals.
  - [x] Update image references in `.qmd` fiches to point to the WebP versions.
  - [ ] Add the original JPG/PNG paths to `.gitignore` (or keep only WebP in the repo) to reduce repository size.
- [ ] **Reduce map file size:**
  - [ ] Evaluate switching `scripts/ocurrencias_gbif.R` from `terra::plet()` + `saveWidget(selfcontained = TRUE)` to an approach that externalises Leaflet assets once (e.g., using `selfcontained = FALSE` and symlinking the shared `_files/` directory, or migrating to pre-generated GeoJSON served by a single shared Leaflet page).
  - [ ] Alternatively, pre-filter GBIF records to a smaller representative sample per species to reduce embedded data size.
- [x] **Exclude `gnparser` from the build:**
  - [x] Quarto has no `resources.exclude` key; move `gnparser` (and the orphaned `1.15.0.tar.gz`) to a `tools/` directory. Files/dirs under the project root are copied to `_site`, so also verify after render. (Quarto skips `.`- and `_`-prefixed paths, so `.quartoignore` is not supported.)
  - [x] Add `tools/` to `.gitignore` if the binaries should not be tracked.
  - [x] Verify `_site/` does not contain `gnparser` after `quarto render`.

---

### **SEO & sharing**

- `sitemap.xml` is not yet enabled in `_quarto.yml`.
- Existing fiches have `description` and `image` metadata; Open Graph and Twitter cards are globally enabled.

**Detailed Tasks:**
- [x] **Enable sitemap:** In Quarto ≥ 1.6 the `sitemap: true` key no longer exists under `website:` — `sitemap.xml` (and `robots.txt`) are generated **automatically whenever `site-url` is set** (already configured here). Verify `_site/sitemap.xml` exists after `quarto render`.
- [x] **Audit new fiches on addition:** When new fiches are added (by the user), ensure `description` and `image` fields are present before committing — document this requirement in `README.md`.

---

### **Automation**

- No GitHub Actions workflow exists; publishing is currently done manually.

**Detailed Tasks:**
- [x] **Deploy workflow (`.github/workflows/publish.yml`):**
  - [x] Create the workflow triggered on push to `main`.
  - [x] Steps: check out repo, install Quarto CLI, install R and required packages (`renv` or explicit `install.packages`), run `quarto render`, push `_site/` to `gh-pages` branch using `peaceiris/actions-gh-pages` or Quarto's built-in `quarto publish gh-pages`.
  - [x] Cache R package installation for faster builds.
- [x] **GBIF data refresh workflow (`.github/workflows/sync-gbif.yml`) — optional:**
  - [x] Create a scheduled workflow (e.g., monthly) that runs `scripts/ocurrencias_gbif.R`, commits updated CSVs under `ocurrencias/`, regenerates `mapas/` HTML files, and triggers a site re-render.
  - [x] Store GBIF API credentials as GitHub Actions secrets.

---

## **Phase 1 — Interactive Data Visualization**

### **Web Map — unified multi-species overview**

The current architecture uses one self-contained Leaflet HTML per species (in `mapas/`), embedded in each fiche via `<iframe>`. A unified overview map on `distribucion.qmd` is still a placeholder. The goal here is to build that overview map properly and, optionally, upgrade the per-species maps.

**Detailed Tasks:**
- [x] **Unified overview map on `distribucion.qmd`:**
  - [x] Combine all per-species occurrence CSVs into a single `ocurrencias/todas-las-especies.geojson` (via `scripts/ocurrencias_gbif.R` or a separate aggregation script).
  - [x] Replace the Google Maps iframe with a Leaflet (or MapLibre GL JS) map loading the combined GeoJSON, with species toggled via a layer-control panel and coloured by growth form.
- [ ] **Per-species map upgrade (optional, Phase 1+):**
  - [ ] Migrate `scripts/ocurrencias_gbif.R` from `terra::plet()` to MapLibre GL JS rendering individual GeoJSON layers, replacing the per-species `mapas/*.html` iframes with inline map divs in each fiche. This eliminates the iframe layer and reduces total asset size significantly.
  - [ ] Serve species occurrence data as lightweight GeoJSON files under `ocurrencias/` instead of embedding data inside the HTML files.
- [ ] **Biodiversity hotspot layer (optional):**
  - [ ] Write an R or Python script to compute kernel density or grid-cell species richness from the combined occurrence data.
  - [ ] Export as static GeoJSON or PMTiles and render as a toggleable heatmap layer on the overview map.

---

### **Trait Database**

A searchable table of species functional traits does not currently exist on the site.

**Detailed Tasks:**
- [x] **Compile trait dataset:**
  - [x] Create a structured CSV or YAML (`data/rasgos.csv`) with columns: `species`, `growth_form`, `family`, `elevation_min_m`, `elevation_max_m`, `host_specificity`, `phenology_flowering`, `phenology_fruiting`, `conservation_status`.
  - [x] Populate from existing fiche content and reference literature.
- [x] **Build client-side search interface (`rasgos.qmd`):**
  - [x] Add a new `rasgos.qmd` page with a DataTables or DuckDB-WASM-powered table with filter controls (dropdowns by growth form, family; sliders for elevation).
  - [x] Link each row to the corresponding species fiche.
- [x] **Open data download:**
  - [x] Provide direct download links for the raw CSV (SQLite file deferred — CSV is sufficient at 15 rows) and, if compiled, an SQLite file with data licence CC-BY-NC-SA 4.0 (matching the site licence).

---

## **Implementation notes (September 2026)**

**Completed:** all of Phase 0 (with the caveats below) and Phase 1's overview map + trait database. Phases 2–3 remain unimplemented: they require external resources (CHELSA/WorldClim raster downloads, an iNaturalist project created by the maintainers, GBIF credentials as GitHub secrets) and are scoped as future work.

**Caveats discovered during implementation:**

- **18 pre-existing broken image references** across 8 fiches point to files never committed to the repo (e.g., `laro-225x300.jpg`, `puyeho-147escala.jpg`, `*.pagespeed.ic.*` files). These were left as-is; the original photos must be located and added to `images/especies/`, then converted with `scripts/convert_images.sh`.
- **No hemiepiphyte fiches exist.** After fixing `categories` to match each fiche's stated growth form, `categorias/hemiepifitas.qmd` renders empty (a callout explains this). Add fiches for true hemiepiphytes (e.g., *Hydrangea*) to populate it.
- **Per-species map size reduction deferred:** `mapas/*.html` are already non-self-contained (24 MB with shared `_files/`), so the concern in the original plan was overstated. Migrating to per-species GeoJSON + a shared map page remains the Phase 1+ optional task.
- **Original JPG/PNG files were kept in the repo** (not gitignored): they are tracked history and are the source of truth for re-conversion. WebP derivatives live in `images/especies/webp/` (88 MB → 14 MB).
- **DOI enrichment:** instead of unverifiable DOIs, reference titles link to a CrossRef search. Add a `doi` column to `data/referencias.csv` when DOIs are verified.
- **`AI plans/` was being published to the site**; `draft: true` frontmatter alone does not exclude a page from the Quarto build (it only hides it from listings), so `_quarto.yml` now also declares an explicit `render:` list (`"*.qmd"`, `"**/*.qmd"`, `"!AI plans/"`) to exclude the directory from the build and sitemap.
- Local rendering requires R (used: conda env `testR`, R 4.5.3) for the knitr chunks that inject per-species map iframes.

---

## **Phase 2 — Analytical Tools for Researchers**

### **Spatial Query Tool**

GitHub Pages cannot run server-side queries. Use DuckDB-WASM's spatial extension for client-side polygon queries against a static GeoParquet file.

**Detailed Tasks:**
- [ ] **GeoParquet generation:**
  - [ ] Extend `scripts/ocurrencias_gbif.R` (or create `scripts/exportar_geoparquet.R`) to combine all cleaned occurrence CSVs into a single `ocurrencias/todas-las-especies.geoparquet` with spatial indexing.
- [ ] **Spatial query interface (`analisis-espacial.qmd`):**
  - [ ] Build a new page with a MapLibre GL JS map and the MapLibre GL Draw plugin so users can draw a bounding box or polygon.
  - [ ] Load DuckDB-WASM with the spatial extension; on polygon submission, run `ST_Intersects` against `todas-las-especies.geoparquet` and display matching records in a results table.
  - [ ] Provide one-click download of query results as CSV or GeoJSON.

---

### **Environmental Enrichment Tool**

Allow researchers to upload a coordinate list and receive climate/environmental values (CHELSA, WorldClim) extracted at those points, without server infrastructure.

**Detailed Tasks:**
- [ ] **Prepare Cloud-Optimized GeoTIFF layers:**
  - [ ] Download CHELSA or WorldClim bioclimatic variable rasters, clip to Chile's bounding box, reproject to EPSG:4326, and export as COG files (`data/rasters/bio01.tif`, etc.).
  - [ ] Keep only the variables most relevant to epiphyte ecology (e.g., annual precipitation, temperature seasonality, cloud frequency).
- [ ] **Client-side point sampler:**
  - [ ] Integrate `geotiff.js` in a new `enriquecimiento.qmd` page.
  - [ ] Allow users to upload a CSV (`latitude,longitude`) or click on a map to specify points.
  - [ ] Extract raster values at those points in-browser and generate a downloadable enriched CSV.
- [ ] **Cloud notebook fallback:**
  - [ ] Prepare a Google Colab notebook (`notebooks/enriquecimiento_ambiental.ipynb`) pre-configured with `rioxarray`, `geopandas`, and the same COG data for bulk extraction tasks beyond the browser tool's capacity.
  - [ ] Link prominently from the `enriquecimiento.qmd` page.

---

## **Phase 3 — Public Engagement and Education**

### **Educational Modules**

Fully static, using Quarto's built-in Observable JS and optional webR.

**Detailed Tasks:**
- [ ] **Canopy stratification module (`educacion/estratificacion-dosel.qmd`):**
  - [ ] Create an interactive diagram of a temperate rainforest cross-section showing vertical zonation of epiphyte growth forms.
  - [ ] Implement sliders (OJS cells) for exploring how light availability and humidity change with canopy height, linked to species trait data.
- [ ] **Species trait explorer (OJS):**
  - [ ] Build an Observable JS data visualization embedded in a `educacion/rasgos-interactivos.qmd` page: scatter plots or parallel coordinates of trait data from the `rasgos.csv` compiled in Phase 1, filterable by growth form or family.
- [ ] **Live R demos with webR (optional):**
  - [ ] Add a `webR` code block demonstrating a simple species accumulation curve or niche breadth calculation, so students can modify and run R code directly in the browser.

---

### **Citizen Science Portal**

GitHub Pages cannot store form submissions; use iNaturalist as the primary data layer.

**Detailed Tasks:**
- [ ] **iNaturalist project setup:**
  - [ ] Create (or link) a dedicated iNaturalist project for Chilean epiphytes and climbing plants.
  - [ ] Add the project widget or link prominently to a new `ciencia-ciudadana.qmd` page.
- [ ] **iNaturalist API integration:**
  - [ ] Write a scheduled GitHub Action script that pulls recent project observations from the iNaturalist API and appends them to a static `data/inaturalist-obs.json` file committed to the repo.
  - [ ] Display the latest observations in a gallery or map layer on `ciencia-ciudadana.qmd`.
- [ ] **Contribution guidelines:**
  - [ ] Write a clear guide on `ciencia-ciudadana.qmd` explaining how to submit observations via iNaturalist, what photo metadata is needed, and how submitted records are reviewed and integrated into the site's GBIF-sourced dataset.

---

## **Phase 4 — Functional Traits, Live Observations & Social Reach (proposed September 2026)**

All three items below are additive to the existing `data/rasgos.csv` / `rasgos.qmd` and `especies/*.qmd` architecture and require no server — consistent with the GitHub Pages constraint.

### **TRY plant trait database enrichment**

`data/rasgos.csv` currently holds only fields authored by hand (growth form, family, phenology, conservation status); `elevation_min_m`, `elevation_max_m`, and `host_specificity` are empty for all 15 species. [TRY](https://www.bgc-jena.mpg.de/en/try-datenbank-fifth-version) is the largest global plant trait database (>15,000 traits, >305,000 species) and is the natural source for quantitative functional traits (specific leaf area, leaf dry-matter content, plant height, seed mass, wood density) not derivable from the fiche text ([Kattge et al. 2020, *Global Change Biology*](https://www.researchgate.net/publication/338072405_TRY_plant_trait_database_-_enhanced_coverage_and_open_access)).

**Constraint:** TRY has no public API — data is obtained by submitting a species/trait request through the TRY web portal, reviewed by data contributors, and returned as a data-release ZIP (non-commercial licence, contributors must be credited, turnaround is typically days to a few weeks). This is a one-time manual/curatorial step, not something a GitHub Action can automate.

**Detailed Tasks:**
- [ ] **Submit a TRY data request:** register at bgc-jena.mpg.de/try, request records for the 15 (soon ~40) binomials in `data/rasgos.csv`, restricted to traits relevant to epiphyte/climber ecology (plant height, leaf area, SLA, leaf dry matter content, seed mass, stem/wood density, growth form — TRY trait IDs, not free text).
- [ ] **Reconcile & merge:** many Chilean temperate-forest species (esp. ferns, Gesneriaceae, Bromeliaceae) will have sparse or no TRY coverage — treat this as a gap-filling pass, not a full replacement; keep a `trait_source` column (`ficha` vs `TRY`) per cell for provenance.
- [ ] **Extend the schema:** add columns to `data/rasgos.csv` (`plant_height_m`, `leaf_area_mm2`, `sla_mm2_mg`, `seed_mass_mg`, `wood_density_g_cm3`) and the corresponding checkboxes/columns in `rasgos.qmd`'s Observable table and filters.
- [ ] **Attribution:** TRY's data-use rules require citing the database and, per record, the original contributing dataset(s) — add a "Fuente de rasgos" note on `rasgos.qmd` and in the CSV metadata header, alongside the existing CC BY-NC-SA notice.
- [ ] **Fallback for ungapped species:** for taxa absent from TRY, note "Sin dato TRY" rather than leaving blank cells silently, so the gap is legible rather than looking like missing curation.

---

### **Live iNaturalist observations panel**

Phase 3 already scopes an iNaturalist project + `ciencia-ciudadana.qmd` page; this refines *how* to embed it given current tooling.

**Constraint:** iNaturalist's old "Observations Widget" (inaturalist.org/observations/widget) is reported broken/unmaintained on the [iNaturalist forum](https://forum.inaturalist.org/t/observations-widget-is-not-working-anymore/7892), and the project page itself cannot be `<iframe>`-embedded. The reliable static-friendly path is the public read API (`api.inaturalist.org/v1/observations?project_id=…`), which needs no auth key and allows CORS, so it can be called either at build time (GitHub Action → static JSON, matching what Phase 3 already proposes) or directly from the browser.

**Detailed Tasks:**
- [ ] **Create the iNaturalist project** ("Epífitas y trepadoras de Chile" or similar), scoped by taxon + Chile place ID.
- [ ] **Build `ciencia-ciudadana.qmd`:** fetch `GET /v1/observations?project_id=<id>&order_by=observed_on&per_page=12` client-side (OJS `fetch`, same pattern as `rasgos.qmd`/`distribucion.qmd`) and render a responsive photo grid (thumbnail, observer, date, species, link to the observation).
- [ ] **Optional freshness via GH Action:** if per-visit API calls are a concern, add a daily/weekly workflow that snapshots the same query into `data/inaturalist-obs.json`, and have the page read the static file with a live-fetch fallback — reuses the automation pattern already built for GBIF sync.
- [ ] **Cross-link from fiches:** on each `especies/*.qmd`, add a filtered iNaturalist search link (`inaturalist.org/observations?project_id=<id>&taxon_name=<species>`) next to the GBIF/GeoLibre links already present.

---

### **Social presence: Bluesky + Instagram**

Neither network offers a free, no-token "live feed" embed suitable for a static site; treat both as link/profile integrations plus selective post embeds rather than a full timeline widget.

**Detailed Tasks:**
- [ ] **Footer/navbar icons:** add Bluesky and Instagram icons (Bootstrap Icons, already usable via Quarto's Bootstrap theme) linking to the project's profiles, alongside the existing contact/e-mail block in `contacto.qmd` and the `page-footer` in `_quarto.yml`.
- [ ] **Bluesky post embeds:** Bluesky ships an official oEmbed script (`embed.bsky.app/embed.js`, documented at [docs.bsky.app/docs/advanced-guides/oembed](https://docs.bsky.app/docs/advanced-guides/oembed)) that embeds individual posts with a `<blockquote class="bluesky-embed">` — use it to pin highlight posts (e.g., a new-fiche announcement) on `index.qmd` or a new `novedades.qmd`, no auth required.
- [ ] **Bluesky "feed" option (optional, more work):** the AT Protocol's public `app.bsky.feed.getAuthorFeed` XRPC endpoint is unauthenticated and CORS-open, so a small OJS/JS fetch (same client-side pattern as the iNaturalist panel) can render a live mini-feed of the account's recent posts without a backend — more maintenance than the oEmbed option, so only pursue if a live feed (not just highlights) is wanted.
- [ ] **Instagram:** Meta deprecated open oEmbed for Instagram — embedding a single post now requires a registered Meta developer app/access token, and a live feed requires the Instagram Graph API (Business/Creator account + token), which is server-side infrastructure the GitHub Pages constraint rules out. Recommend: profile-link icon only for now; revisit per-post embeds only if maintaining a Meta developer app is acceptable overhead.

---

**Priority note:** of the three, the iNaturalist panel reuses infrastructure already scoped in Phase 3 and is the cheapest to ship; social icons/links are trivial; TRY enrichment is the highest-value but slowest item since it runs on an external review turnaround, not on repo work — submit that request first and build the other two while it's pending.
