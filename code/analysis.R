# Descriptive analysis: GDP per capita and life expectancy, 1952-2007.
required <- c("plotly", "htmlwidgets", "htmltools", "jsonlite")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Install required packages with code/install_packages.R")
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
source("code/write_post.R", encoding = "UTF-8")
files <- c("data/raw/gapminder.csv", "data/processed/analysis_data.csv",
           "data/results/year_summary.csv", "data/results/country_cases.csv", "data/results/article_claims.csv")
write.csv(data.frame(file = files, md5 = unname(tools::md5sum(files))),
          "figures/evidence/data_result_checksums.csv", row.names = FALSE)
message("PASS: ", length(checks), " data checks; HTML figures, article, tables and evidence generated.")
