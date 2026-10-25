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
