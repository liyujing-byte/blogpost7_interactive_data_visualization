# Replace numerical placeholders with values computed by analysis.R.
fmt <- function(x, digits = 1) formatC(x, format = "f", digits = digits, big.mark = ",")
article <- paste(readLines("code/template.md", warn = FALSE, encoding = "UTF-8"), collapse = "\n")
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
