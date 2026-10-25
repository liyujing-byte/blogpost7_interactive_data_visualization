# Data provenance and measurement

- Dataset: `gapminder::gapminder`, historical filtered excerpt, R package 1.0.1.
- Source documentation: https://jennybc.github.io/gapminder/reference/gapminder.html
- Package source: https://github.com/jennybc/gapminder
- Original data provider: https://www.gapminder.org/data/
- Snapshot exported on 2026-10-25 using `code/export_source_data.R`.
- Coverage: 142 countries, 1952-2007 at five-year intervals; 1,704 rows.
- `country`: country label; `continent`: package's five-continent grouping.
- `year`: observation year; `pop`: population count.
- `lifeExp`: life expectancy at birth, years (not observed mean age at death).
- `gdpPercap`: GDP per capita, inflation-adjusted US dollars, as described in the package documentation. That help page does not state the price base or PPP methodology. This project retains the published units and does not label them as current dollars or assert an unsupported base year.

This CSV is the actual input used to reproduce this analysis. It is not freshly downloaded current data. The filtered package dataset retains complete country records; it does not represent every country or every year. No imputation, country reassignment, or population weighting is applied. `data/processed/analysis_data.csv` adds log10 GDP per capita and sorts records; it retains all input rows. Source data are credited to Gapminder and the R package maintainers; see their documentation for original underlying sources and reuse terms. The optional export script refreshes from the locally installed package and can change the snapshot if the package changes.
