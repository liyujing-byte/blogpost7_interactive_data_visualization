required <- c("plotly", "htmlwidgets", "htmltools", "jsonlite", "gapminder")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
message("Required packages are available. Run source('code/run.R') from the project root.")
