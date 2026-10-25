# Run from the repository root, or open blogpost7.Rproj in RStudio.
if (!file.exists("scripts/analysis.R")) {
  stop("Open blogpost7.Rproj or set the working directory to the repository root.")
}
source("scripts/analysis.R", encoding = "UTF-8")
