# Optional: refresh the snapshot from the installed gapminder R package.
# Ordinary replication uses the CSV already committed to this repository.
stopifnot(requireNamespace("gapminder", quietly = TRUE))
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
write.csv(as.data.frame(gapminder::gapminder),
          "data/raw/gapminder.csv", row.names = FALSE)
writeLines(paste("gapminder package version:", packageVersion("gapminder")),
           "data/raw/package_version.txt")
