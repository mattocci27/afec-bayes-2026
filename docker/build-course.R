# Runs during a future image build, not at container startup.
root <- "/opt/afec/template"
setwd(root)
suppressPackageStartupMessages(library(tidyverse))
source("R/functions.R")
source("R/course_data.R")
source("/opt/afec/bin/check-fits.R")
data <- check_course_fits(root)
dir.create("data", showWarnings = FALSE)
for (name in names(data)) {
  readr::write_csv(data[[name]], file.path("data", paste0(name, ".csv")))
}
saveRDS(data, "data/course-data.rds")
writeLines(c("Version: 1.0", "RestoreWorkspace: No", "SaveWorkspace: No",
             "AlwaysSaveHistory: No", "Encoding: UTF-8"), "afec-bayes-2026.Rproj")
writeLines("# Classroom: packages and CmdStan are configured by Rprofile.site.\n# No renv activation or host-specific proxy settings.", ".Rprofile")

bin <- Sys.getenv("AFEC_STAN_BIN_DIR")
dir.create(bin, recursive = TRUE, showWarnings = FALSE)
# mv_logistic.stan refers to undefined phi/plot/xi/census/psi/tag. Preserve its
# source as legacy reference, but never pretend it is a usable compiled model.
stan_files <- setdiff(list.files("stan", pattern = "\\.stan$", full.names = TRUE),
                      "stan/mv_logistic.stan")
manifest <- list()
for (file in stan_files) {
  compiled_source <- file.path(bin, basename(file))
  stopifnot(file.copy(file, compiled_source, overwrite = TRUE))
  mod <- cmdstanr::cmdstan_model(compiled_source, cpp_options = list(stan_threads = TRUE))
  Sys.chmod(mod$exe_file(), "0755")
  manifest[[basename(file)]] <- list(
    md5 = unname(tools::md5sum(file)), executable = basename(mod$exe_file()),
    cmdstan = as.character(cmdstanr::cmdstan_version())
  )
  # Only model-local intermediate files; keep CmdStan's toolchain/PCH/TBB intact.
  stem <- sub("\\.stan$", "", compiled_source)
  unlink(paste0(stem, c(".hpp", ".o", ".d")))
}
saveRDS(manifest, file.path(bin, "manifest.rds"))

# Offline presentation resources. Local copies are image derivatives only;
# do not rewrite the instructor's repository themes or original QMD files.
download <- function(url, path) {
  status <- system2("curl", c("-fL", "--retry", "3", "--connect-timeout", "30",
                             "--max-time", "600", "-o", shQuote(path), shQuote(url)))
  if (status != 0L) stop("Failed build-time download: ", url)
}
archive <- tempfile(fileext = ".tgz")
download("https://registry.npmjs.org/mathjax/-/mathjax-3.2.2.tgz", archive)
extract <- tempfile("afec-mathjax-")
dir.create(extract)
utils::untar(archive, exdir = extract)
stopifnot(file.copy(file.path(extract, "package", "es5"), "assets", recursive = TRUE))
stopifnot(file.rename("assets/es5", "assets/mathjax"))
file.copy(file.path(extract, "package", "LICENSE"), "assets/mathjax/LICENSE", overwrite = TRUE)
unlink(c(archive, extract), recursive = TRUE)
# Record the fetched logo digest with the other assets below. Its upstream
# master URL is not immutable; freeze the completed image digest for deployment.
download("https://raw.githubusercontent.com/stan-dev/logos/master/logo.png", "images/stan-logo.png")
dir.create("assets/fonts", showWarnings = FALSE)
font_src <- "/usr/share/fonts/truetype/lato/Lato-Regular.ttf"
stopifnot(file.copy(font_src, "assets/fonts/Lato-Regular.ttf"))
# Preserve font attribution from the Debian/Ubuntu font package.
file.copy("/usr/share/doc/fonts-lato/copyright", "assets/fonts/Lato-COPYRIGHT")
for (file in c("assets/custom.css", "assets/rladies.scss", "assets/course.css", "assets/course.scss")) {
  lines <- readLines(file)
  writeLines(lines[!grepl("^@import.*https?://", lines)], file)
}
cat('\n@font-face { font-family: Lato; src: url("fonts/Lato-Regular.ttf"); }\n',
    file = "assets/custom.css", append = TRUE)
cat('\n@font-face { font-family: Lato; src: url("fonts/Lato-Regular.ttf"); }\n',
    file = "assets/course.css", append = TRUE)
for (day in paste0("day", 1:3)) {
  for (name in "slides") {
    file <- file.path(day, paste0(name, ".qmd"))
    lines <- readLines(file)
    lines <- gsub("https://raw.githubusercontent.com/stan-dev/logos/master/logo.png",
                  "../images/stan-logo.png", lines, fixed = TRUE)
    # Insert inside each format's options, taking precedence over the old scalar.
    lines <- lines[!grepl("^    html-math-method:", lines)]
    at <- which(grepl("^  (html|revealjs):$", lines))
    stopifnot(length(at) == 1L)
    lines <- append(lines, c("    html-math-method:", "      method: mathjax",
                            "      url: ../assets/mathjax/tex-chtml-full.js",
                            "    embed-resources: false"), after = at)
    # Dynamic MathJax fonts/extensions need ordinary relative URLs, not data URIs.
    lines <- lines[!grepl("^    embed-resources: true$", lines)]
    writeLines(lines, file)
  }
}
Sys.setenv(AFEC_USE_PRECOMPUTED = "TRUE")
# Changed-input inference chunks are eval=FALSE; core handouts load matching fits.
# Remove solution code from participant sources before rendering.
source("R/classroom_materials.R")
build_classroom_materials(root, package = FALSE)
files <- list.files(root, recursive = TRUE, full.names = TRUE, all.files = TRUE)
files <- files[!dir.exists(files)]
write.table(data.frame(file = substring(files, nchar(root) + 2L),
                       md5 = unname(tools::md5sum(files))), "/opt/afec/materials.tsv",
            sep = "\t", quote = FALSE, row.names = FALSE)
writeLines(c(capture.output(sessionInfo()),
             paste("CmdStan:", cmdstanr::cmdstan_version()),
             paste("Quarto:", system2("quarto", "--version", stdout = TRUE))),
           "/opt/afec/build-session.txt")
