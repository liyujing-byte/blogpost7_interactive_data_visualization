# Blog Post 7: complete reproducible workflow in one script.
# Open the repository RStudio project, then run:
# source("code/blogpost7_all_process.R")
# Sections: packages, bundled data, checks, summaries, figures, article, validation.

# 1. Install missing packages (first run requires CRAN access).
packages <- c("plotly", "htmlwidgets", "htmltools", "jsonlite", "gapminder")
missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}
if (!rmarkdown::pandoc_available()) {
  stop("Pandoc is needed for self-contained HTML. Run in RStudio, or configure RSTUDIO_PANDOC.")
}

# 2. Use the committed input snapshot. Set TRUE only to refresh from gapminder.
refresh_data <- FALSE
if (!file.exists("blogpost7_interactive_data_visualization.Rproj")) {
  stop("Open the repository RStudio project or set the working directory to its root.")
}
if (refresh_data || !file.exists("data/raw/gapminder.csv")) {
  dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
  write.csv(as.data.frame(gapminder::gapminder), "data/raw/gapminder.csv", row.names = FALSE)
  writeLines(paste("gapminder package version:", packageVersion("gapminder")),
             "data/raw/package_version.txt")
}

# 3-6. Check data, compute results, create figures and write the article.
# Descriptive analysis: GDP per capita and life expectancy, 1952-2007.
required <- c("plotly", "htmlwidgets", "htmltools", "jsonlite")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Required packages were not installed successfully.")
for (folder in c("data/processed", "data/results", "figures/evidence", "figures", "figures/post")) {
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
}
d <- read.csv("data/raw/gapminder.csv", stringsAsFactors = FALSE)
d <- d[order(d$year, d$continent, d$country), ]
years <- sort(unique(d$year))
checks <- c(
  expected_rows = nrow(d) == 1704L,
  expected_countries = length(unique(d$country)) == 142L,
  expected_years = identical(years, seq.int(1952L, 2007L, by = 5L)),
  no_missing_values = !anyNA(d),
  unique_country_year = !anyDuplicated(d[c("country", "year")]),
  positive_gdp = all(d$gdpPercap > 0),
  positive_population = all(d$pop > 0),
  valid_life_expectancy = all(d$lifeExp > 0 & d$lifeExp < 120),
  balanced_panel = all(table(d$country) == length(years))
)
write.csv(data.frame(check = names(checks), passed = unname(checks)),
          "figures/evidence/data_checks.csv", row.names = FALSE)
stopifnot(all(checks))
d$log10_gdp <- log10(d$gdpPercap)
write.csv(d, "data/processed/analysis_data.csv", row.names = FALSE)
summaries <- do.call(rbind, lapply(years, function(y) {
  z <- d[d$year == y, ]
  data.frame(year = y, countries = nrow(z),
             median_life_expectancy = median(z$lifeExp),
             median_gdp_per_capita = median(z$gdpPercap),
             correlation_log_gdp_life = cor(z$log10_gdp, z$lifeExp))
}))
write.csv(summaries, "data/results/year_summary.csv", row.names = FALSE)
selected <- c("China", "India", "Costa Rica", "South Africa", "United States")
cases <- d[d$country %in% selected, ]
cases <- cases[order(cases$country, cases$year), ]
write.csv(cases, "data/results/country_cases.csv", row.names = FALSE)
cr <- d[d$country == "Costa Rica" & d$year == 2007, ]
sa07 <- d[d$country == "South Africa" & d$year == 2007, ]
sa92 <- d[d$country == "South Africa" & d$year == 1992, ]
claims <- data.frame(
  claim = c("2007 Costa Rica GDP per capita", "2007 South Africa GDP per capita",
            "2007 Costa Rica life expectancy", "2007 South Africa life expectancy",
            "2007 Costa Rica minus South Africa life expectancy",
            "1992-2007 South Africa GDP change percent",
            "1992-2007 South Africa life expectancy change years"),
  value = c(cr$gdpPercap, sa07$gdpPercap, cr$lifeExp, sa07$lifeExp,
            cr$lifeExp - sa07$lifeExp,
            100 * (sa07$gdpPercap / sa92$gdpPercap - 1),
            sa07$lifeExp - sa92$lifeExp)
)
write.csv(claims, "data/results/article_claims.csv", row.names = FALSE)

continents <- c("Africa", "Americas", "Asia", "Europe", "Oceania")
colors <- c("#B45309", "#007C91", "#9D3E84", "#3157A4", "#4D7C0F")
d$continent <- factor(d$continent, levels = continents)
d$tooltip <- sprintf(
  "<b>%s</b><br>Year: %d<br>Continent: %s<br>GDP per capita: $%s<br>Life expectancy: %.1f years<br>Population: %s",
  d$country, d$year, d$continent,
  format(round(d$gdpPercap), big.mark = ",", trim = TRUE),
  d$lifeExp, format(d$pop, big.mark = ",", scientific = FALSE, trim = TRUE)
)
# Keep five stable traces and update their coordinates with a year slider.
# This preserves legend visibility when switching years, without animation resets.
p <- plotly::plot_ly(height = 660)
for (i in seq_along(continents)) {
  z <- d[d$year == years[1] & d$continent == continents[i], ]
  p <- plotly::add_trace(p, x = z$gdpPercap, y = z$lifeExp,
    ids = z$country, text = z$tooltip, hoverinfo = "text",
    type = "scatter", mode = "markers", name = continents[i],
    legendgroup = continents[i],
    marker = list(size = 10, opacity = 0.78, color = colors[i],
                  line = list(color = "white", width = 0.6)))
}
steps <- lapply(years, function(y) {
  groups <- lapply(continents, function(ct) d[d$year == y & d$continent == ct, ])
  list(label = as.character(y), method = "restyle",
       args = list(list(x = lapply(groups, function(z) z$gdpPercap),
                        y = lapply(groups, function(z) z$lifeExp),
                        text = lapply(groups, function(z) z$tooltip),
                        ids = lapply(groups, function(z) z$country))))
})
p <- plotly::layout(
  p, title = list(text = "Income and life expectancy across countries", x = 0.02),
  xaxis = list(title = "GDP per capita (inflation-adjusted US$; log scale)",
               type = "log", range = log10(c(200, 130000)), autorange = FALSE),
  yaxis = list(title = "Life expectancy at birth (years)", range = c(20, 90),
               autorange = FALSE),
  legend = list(orientation = "h", x = 0, y = 1.12),
  sliders = list(list(active = 0, currentvalue = list(prefix = "Year: "),
                      steps = steps, pad = list(t = 45), x = 0, len = 1)),
  paper_bgcolor = "white", plot_bgcolor = "#F6F8FA",
  font = list(family = "Arial, sans-serif", color = "#182B3A"),
  margin = list(l = 75, r = 25, t = 115, b = 120)
)
p <- plotly::config(p, displaylogo = FALSE, responsive = TRUE,
                    toImageButtonOptions = list(filename = "income_life_expectancy"))

# A second interactive view makes a country's complete trajectory readable.
q <- plotly::plot_ly(height = 540)
for (i in seq_along(selected)) {
  z <- cases[cases$country == selected[i], ]
  txt <- sprintf("<b>%s</b><br>Year: %d<br>GDP per capita: $%s<br>Life expectancy: %.1f years",
                 z$country, z$year, format(round(z$gdpPercap), big.mark = ",", trim = TRUE), z$lifeExp)
  q <- plotly::add_trace(q, x = z$gdpPercap, y = z$lifeExp,
                         type = "scatter", mode = "lines+markers", name = selected[i],
                         text = txt, hoverinfo = "text", visible = i == 1,
                         marker = list(size = 9), line = list(width = 2))
}
buttons <- lapply(seq_along(selected), function(i) {
  list(method = "update", label = selected[i],
       args = list(list(visible = seq_along(selected) == i)))
})
q <- plotly::layout(q,
  title = list(text = "Follow one country through all 12 observations", x = 0.02),
  xaxis = list(title = "GDP per capita (inflation-adjusted US$; log scale)",
               type = "log", range = log10(c(200, 130000)), autorange = FALSE),
  yaxis = list(title = "Life expectancy at birth (years)", range = c(20, 90), autorange = FALSE),
  updatemenus = list(list(type = "dropdown", buttons = buttons,
                          x = 0, y = 1.16, xanchor = "left", yanchor = "top")),
  showlegend = FALSE, margin = list(l = 75, r = 25, t = 110, b = 65),
  font = list(family = "Arial, sans-serif", color = "#182B3A"),
  plot_bgcolor = "#F6F8FA"
)
q <- plotly::config(q, displaylogo = FALSE, responsive = TRUE)

# Include all JavaScript locally. No CDN is required to view saved figures.
p <- htmlwidgets::prependContent(p, htmltools::tags$style(
  "html,body{min-width:680px} .html-widget{min-width:680px}"))
q <- htmlwidgets::prependContent(q, htmltools::tags$style(
  "html,body{min-width:680px} .html-widget{min-width:680px}"))
htmlwidgets::saveWidget(p, "figures/interactive_plot.html", selfcontained = TRUE)
htmlwidgets::saveWidget(q, "figures/country_trajectories.html", selfcontained = TRUE)
# saveWidget leaves temporary dependency folders even for self-contained files.
unlink(c("figures/interactive_plot_files", "figures/country_trajectories_files"), recursive = TRUE)

# Static preview is supplementary; it does not replace the interactive figures.
png("figures/preview_2007.png", width = 1600, height = 1050, res = 150)
par(mar = c(5.6, 5, 3.7, 1))
z <- d[d$year == 2007, ]
plot(z$gdpPercap, z$lifeExp, log = "x", pch = 21, bg = colors[as.integer(z$continent)],
     col = "white", cex = 1.2, xlim = c(200, 130000), ylim = c(20, 90),
     xlab = "GDP per capita (inflation-adjusted US$; log scale)",
     ylab = "Life expectancy at birth (years)",
     main = "Income and life expectancy, 2007")
legend("topleft", legend = continents, pch = 21, pt.bg = colors, bty = "n", cex = 0.85)
for (country in c("Costa Rica", "South Africa")) {
  a <- z[z$country == country, ]
  text(a$gdpPercap, a$lifeExp, labels = country, pos = 4, cex = 0.75)
}
mtext("Source: gapminder R package, historical excerpt. Each point is one country.",
      side = 1, line = 4, cex = 0.72)
dev.off()

# Export the actual Plotly specifications for audit and structural checks.
writeLines(as.character(plotly::plotly_json(p, jsonedit = FALSE, pretty = FALSE)),
           "figures/evidence/main_plot_spec.json")
writeLines(as.character(plotly::plotly_json(q, jsonedit = FALSE, pretty = FALSE)),
           "figures/evidence/trajectory_plot_spec.json")
capture.output(sessionInfo(), file = "data/results/sessionInfo.txt")
versions <- data.frame(package = required,
                       version = vapply(required, function(x) as.character(packageVersion(x)), character(1)))
write.csv(versions, "data/results/package_versions.csv", row.names = FALSE)
# 6. Generate the article from the computed values. Edit the prose below.
fmt <- function(x, digits = 1) formatC(x, format = "f", digits = digits, big.mark = ",")
article <- paste(c(
  "# Does Higher Income Always Go with Longer Lives?",
  "",
  "Countries with higher GDP per capita often have longer life expectancies. But does this association describe every country, and does economic growth always coincide with improvements in longevity? An interactive view lets us investigate both the broad relationship and cases that a single snapshot can hide. I compare countries over time rather than treating national income as a complete measure of well-being.",
  "",
  "## Data and approach",
  "",
  "I use the historical excerpt distributed with the gapminder R package: 142 countries observed every five years from 1952 to 2007, for 1,704 country-year observations. This is a historical sample, not a current global census. GDP per capita is reported in inflation-adjusted US dollars in the package documentation; life expectancy is measured at birth in years. GDP per capita measures national output per person, not household income. The script checks missing values, positive GDP and unique country-year records before creating the figures.",
  "",
  "Each dot represents one country, with color indicating continent. The horizontal axis uses a logarithmic scale, so equal distances represent equal GDP ratios rather than equal dollar differences. Axis ranges remain fixed across years. Countries receive equal marker sizes; population is available on hover. The chart therefore compares country outcomes without visually weighting large populations more heavily.",
  "",
  "## Explore the interactive chart",
  "",
  "Drag the year slider to compare observations. Hover over a dot to identify its country and read its GDP per capita, life expectancy and population. Click a continent in the legend to hide or restore it; double-click to isolate a continent. These controls let readers investigate specific observations and regional differences without placing every country label on one crowded static figure.",
  "",
  "## Three patterns to investigate",
  "",
  "First, the cloud generally slopes upward: higher GDP per capita is associated with longer life expectancy. Moving between early and late years also reveals substantial improvements in longevity across much of the sample. Median life expectancy across the 142 countries rises from {{median1952}} years in 1952 to {{median2007}} in 2007. These are unweighted country medians, not population-weighted global life expectancy estimates. The slider makes the changing distribution visible while keeping the measurement scales constant.",
  "",
  "Second, similar GDP does not guarantee similar longevity. In 2007, Costa Rica's GDP per capita is approximately ${{crgdp}}, compared with ${{sagdp}} in South Africa. Yet their life expectancies are {{crlife}} and {{salife}} years, respectively: a {{gap}}-year difference. Hovering identifies the countries behind this large vertical separation. Filtering continents can then help readers see whether these observations resemble other countries in their respective regions. This comparison shows why a country's position relative to the overall pattern deserves attention.",
  "",
  "## Follow a country",
  "",
  "The supplementary dropdown traces five selected countries through all twelve observations. Select South Africa and hover over successive points. Between 1992 and 2007, its GDP per capita increases by {{sagrowth}}%, while life expectancy falls from {{sa92life}} to {{salife}} years, a decline of {{sadecline}} years. This third pattern distinguishes a cross-country association from a country's trajectory. A 2007-only chart would show the endpoint but conceal the reversal. The selected countries are illustrative cases, not a random subsample or a formal test.",
  "",
  "## What can we conclude?",
  "",
  "These comparisons are descriptive. They do not estimate the causal effect of GDP on longevity or establish why particular countries differ. National averages conceal inequalities within countries, and five-year observations can miss short-lived changes. The filtered historical sample also excludes countries without complete records. Although the package identifies GDP as inflation-adjusted US dollars, its help page does not specify the price base; I retain its published units and avoid interpreting these values as present-day dollars.",
  "",
  "The central takeaway is that GDP per capita provides useful context for health outcomes, but it does not determine them completely. Interactive identification and time comparisons reveal both substantial differences at similar economic levels and trajectories that depart from the overall association."
), collapse = "\n")
replacements <- c(
  median1952 = fmt(summaries$median_life_expectancy[summaries$year == 1952]),
  median2007 = fmt(summaries$median_life_expectancy[summaries$year == 2007]),
  crgdp = fmt(cr$gdpPercap, 0), sagdp = fmt(sa07$gdpPercap, 0),
  crlife = fmt(cr$lifeExp), salife = fmt(sa07$lifeExp),
  gap = fmt(cr$lifeExp - sa07$lifeExp),
  sa92life = fmt(sa92$lifeExp),
  sagrowth = fmt(100 * (sa07$gdpPercap / sa92$gdpPercap - 1)),
  sadecline = fmt(sa92$lifeExp - sa07$lifeExp)
)
for (key in names(replacements)) {
  article <- gsub(paste0("{{", key, "}}"), replacements[[key]], article, fixed = TRUE)
}
stopifnot(!grepl("{{", article, fixed = TRUE))
links <- c("", "## Interactive figures and sources", "",
  "[Open the main interactive chart](../interactive_plot.html) | [Open country trajectories](../country_trajectories.html)", "",
  "Data: [gapminder R package documentation](https://jennybc.github.io/gapminder/reference/gapminder.html), [Gapminder](https://www.gapminder.org/data/).", "",
  "[Code, input data and reproducibility evidence](https://github.com/liyujing-byte/blogpost7_interactive_data_visualization).")
writeLines(c(article, links), "figures/post/blogpost7.md", useBytes = TRUE)
qmd <- c("---", 'title: "Does Higher Income Always Go with Longer Lives?"',
         "format: html", "---", "", sub("^# [^\n]*\n", "", article), links)
writeLines(qmd, "figures/post/blogpost7.qmd", useBytes = TRUE)

# Standalone reading page. It can be served by GitHub Pages without Quarto.
chunks <- strsplit(article, "\n\n", fixed = TRUE)[[1]]
body <- lapply(chunks, function(chunk) {
  if (startsWith(chunk, "# ")) return(htmltools::tags$h1(substring(chunk, 3)))
  if (startsWith(chunk, "## ")) return(htmltools::tags$h2(substring(chunk, 4)))
  htmltools::tags$p(chunk)
})
style <- "body{font:18px/1.65 Georgia,serif;color:#182b3a;margin:0;background:#f7f9fb}main{max-width:1040px;margin:40px auto;padding:32px;background:white}h1,h2,h3{font-family:Arial,sans-serif;line-height:1.2}h1{font-size:36px}h2{font-size:25px;margin-top:35px}a{color:#007c91}iframe{width:100%;border:1px solid #dde4e9}aside{padding:20px;background:#eef5f8}p{max-width:850px}@media(max-width:700px){main{margin:0;padding:18px}h1{font-size:28px}}"
# Insert the main graph after its dedicated heading and the country graph after its heading.
reading <- list()
for (i in seq_along(chunks)) {
  reading <- append(reading, list(body[[i]]))
  if (identical(chunks[i], "## Explore the interactive chart")) {
    reading <- append(reading, list(htmltools::tags$iframe(
      src = "interactive_plot.html", height = "720", title = "Interactive income and life expectancy scatterplot")))
  }
  if (identical(chunks[i], "## Follow a country")) {
    reading <- append(reading, list(htmltools::tags$iframe(
      src = "country_trajectories.html", height = "590", title = "Selected country trajectories")))
  }
}
page <- htmltools::tags$html(lang = "en",
  htmltools::HTML(paste0('<head><meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1">',
    '<title>Does Higher Income Always Go with Longer Lives?</title>',
    '<style>', style, '</style></head>')),
  htmltools::tags$body(htmltools::tags$main(
    reading,
    htmltools::tags$aside(
      htmltools::tags$h2("Sources and reproducibility"),
      htmltools::tags$p(htmltools::tags$a(href = "https://jennybc.github.io/gapminder/reference/gapminder.html", "Gapminder R dataset documentation")),
      htmltools::tags$p(htmltools::tags$a(href = "https://www.gapminder.org/data/", "Gapminder data sources")),
      htmltools::tags$p(htmltools::tags$a(href = "https://plotly.com/r/animations/", "Plotly R animation documentation")),
      htmltools::tags$p(htmltools::tags$a(href = "https://github.com/liyujing-byte/blogpost7_interactive_data_visualization", "Code, data, numerical evidence and replication instructions")),
      htmltools::tags$p(htmltools::tags$a(href = "interactive_plot.html", "Open the main interactive figure separately")),
      htmltools::tags$p(htmltools::tags$a(href = "country_trajectories.html", "Open the country trajectory figure separately"))
    )
  )))
writeLines(as.character(htmltools::tagList(htmltools::HTML("<!doctype html>"), page)),
           "figures/index.html", useBytes = TRUE)
words <- length(strsplit(gsub("[#\n]", " ", article), "[[:space:]]+")[[1]])
writeLines(paste("Approximate article word count (including headings):", words),
           "figures/evidence/article_word_count.txt")

files <- c("data/raw/gapminder.csv", "data/processed/analysis_data.csv",
           "data/results/year_summary.csv", "data/results/country_cases.csv", "data/results/article_claims.csv")
write.csv(data.frame(file = files, md5 = unname(tools::md5sum(files))),
          "figures/evidence/data_result_checksums.csv", row.names = FALSE)
message("PASS: ", length(checks), " data checks; HTML figures, article, tables and evidence generated.")


# 7. Validate all slider years, country trajectories and generated outputs.
local({
# Validate meaningful correspondence between data, controls and published claims.
d <- read.csv("data/raw/gapminder.csv", stringsAsFactors = FALSE)
p <- jsonlite::fromJSON("figures/evidence/main_plot_spec.json", simplifyVector = FALSE)
q <- jsonlite::fromJSON("figures/evidence/trajectory_plot_spec.json", simplifyVector = FALSE)
steps <- p$layout$sliders[[1]]$steps
stopifnot(length(steps) == 12L, length(p$data) == 5L)
for (step in steps) {
  year <- as.integer(step$label)
  update <- step$args[[1]]
  for (i in seq_along(p$data)) {
    expected <- d[d$year == year & d$continent == p$data[[i]]$name, ]
    expected <- expected[order(expected$country), ]
    stopifnot(isTRUE(all.equal(unlist(update$x[[i]]), expected$gdpPercap,
                              check.attributes = FALSE, tolerance = 1e-8)),
              isTRUE(all.equal(unlist(update$y[[i]]), expected$lifeExp,
                              check.attributes = FALSE, tolerance = 1e-8)),
              identical(unname(unlist(update$ids[[i]])), expected$country))
  }
}
stopifnot(length(q$data) == 5L,
          length(q$layout$updatemenus[[1]]$buttons) == 5L)
for (i in seq_along(q$data)) {
  expected <- d[d$country == q$data[[i]]$name, ]
  expected <- expected[order(expected$year), ]
  stopifnot(isTRUE(all.equal(unlist(q$data[[i]]$y), expected$lifeExp,
                            check.attributes = FALSE, tolerance = 1e-8)))
}
summary <- read.csv("data/results/year_summary.csv")
stopifnot(all(summary$countries == 142L),
          abs(summary$median_life_expectancy[1] - median(d$lifeExp[d$year == 1952])) < 1e-10)
for (file in c("figures/interactive_plot.html", "figures/country_trajectories.html")) {
  html <- paste(readLines(file, warn = FALSE), collapse = "\n")
  stopifnot(!grepl('<script[^>]+src="https?://', html),
            !grepl('<script[^>]+src="[^\"]+_files/', html))
}
post <- paste(readLines("figures/post/blogpost7.md", warn = FALSE), collapse = "\n")
stopifnot(!grepl("{{", post, fixed = TRUE))
checksums <- read.csv("figures/evidence/data_result_checksums.csv")
stopifnot(identical(unname(tools::md5sum(checksums$file)), checksums$md5))
message("PASS: all 12 slider years match raw data for all 5 continents.")
message("PASS: all 5 country trajectories match raw data; 5 dropdown choices present.")
message("PASS: summaries, input/result checksums, standalone scripts and article placeholders.")

})
