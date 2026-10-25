# Blog Post 7 — Interactive Data Visualization with Plotly

**Question:** How does the relationship between GDP per capita and life expectancy vary across countries and over time?

An R/RStudio project using the historical Gapminder excerpt (142 countries, 1952–2007). It includes an English article, two functional Plotly HTML figures, original input data, computed result tables, session information, and validation evidence.

## Open and reproduce in RStudio

1. Download or clone this repository and open `blogpost7.Rproj`.
2. In the RStudio Console, run:

```r
source("scripts/install_packages.R") # once; CRAN access required
source("run.R")                     # bundled CSV; no data download required
```

Or run `Rscript scripts/install_packages.R` followed by `Rscript run.R` from the repository root. R 4.5 or a compatible version is recommended; the exact R and package versions used here are recorded in `results/sessionInfo.txt` and `results/package_versions.csv`. Pandoc must be installed for self-contained HTML export; RStudio normally bundles it. If running outside RStudio, put Pandoc on PATH or configure `RSTUDIO_PANDOC`.

The code regenerates data checks, processed data, CSV results, a static preview, the two HTML figures, plot specifications, checksums, and article pages. Open `docs/index.html` in a browser to read the article with both figures. The figure HTML files include their JavaScript and do not require a CDN or an R session. Narrow windows allow horizontal scrolling within figures to preserve readable axes and controls.

The process log in `evidence/run.log` was captured from an actual run. Browser screenshots and the browser validation record document a separate UI validation; they are not recreated by `run.R` and must not be represented as new tests after changing the code.

## Read and explore

- `post/blogpost7.md`: generated English article, approximately 640 words.
- `post/blogpost7.qmd`: Quarto-ready article source; charts are hosted separately in `docs/`.
- `docs/index.html`: standalone article with both interactive figures embedded.
- `docs/interactive_plot.html`: year slider, continent legend filters, country hover details; equal-size country markers and fixed log-GDP/life-expectancy axes.
- `docs/country_trajectories.html`: dropdown selecting China, India, Costa Rica, South Africa or United States; connected observations show the time order, and hover gives years.
- `results/preview_2007.png`: static supplementary preview; not a replacement for the interactive HTML.

The year slider uses `restyle` on five stable continent traces, preserving legend filters between years. This avoids the legend/animation interaction found during validation of an initial animated version. There is no Play control in the final chart.

## Project organization

| Folder/file | Purpose |
|---|---|
| `run.R` | Main entry point |
| `scripts/analysis.R` | Data validation, summaries, figures and audit outputs |
| `scripts/write_post.R` | Insert computed numbers into the article; create reading page |
| `scripts/install_packages.R` | Install missing R dependencies |
| `scripts/export_source_data.R` | Optional snapshot export from installed gapminder package |
| `data/raw/` | Actual input CSV, package version and source documentation |
| `data/processed/` | Complete analysis table with log10 GDP |
| `results/` | Year summaries, country cases, article claim values, preview and R environment |
| `post/template.md` | Editable prose template; edit this before rerunning |
| `evidence/` | Input checks, run log, plot specs, checksums, screenshots and rubric map |
| `docs/` | Standalone reading page and interactive HTML figures |

## Findings and interpretation

The unweighted median country life expectancy rises from 45.1 years in 1952 to 71.9 in 2007. In 2007, Costa Rica and South Africa have GDP per capita of about $9,645 and $9,270, but life expectancy differs by 29.4 years. From 1992 to 2007, South Africa's GDP per capita rises about 28.3% while life expectancy falls about 12.5 years. All article values are generated from the bundled data; see `results/article_claims.csv` and `results/country_cases.csv` for full precision.

These are descriptive country comparisons, not causal effects or global population-weighted estimates. National averages hide within-country inequalities. GDP units follow the package's inflation-adjusted US-dollar description; its help page does not specify a price base. See `data/raw/SOURCES.md` for measurement and coverage details.

## Publishing and submission

Repository: https://github.com/liyujing-byte/blogpost7_interactive_data_visualization

The committed HTML files can be published with GitHub Pages using branch `main`, folder `/docs`. In GitHub, open Settings → Pages → Deploy from a branch → main → /docs → Save. After GitHub confirms deployment, the expected URL is:

https://liyujing-byte.github.io/blogpost7_interactive_data_visualization/

This expected address is not proof that Pages is enabled. Verify the deployment before submitting it. If using an existing course blog, publish the article there and embed or link to the hosted HTML figures. Do not use a GitHub file-preview URL as the interactive chart URL. This repository does not alter an existing blog or submit coursework.

Submit the actual published blog URL and this repository URL. `evidence/rubric_checklist.md` maps files to the ten assignment criteria.
