# No image build/run/download/install. Use the existing local project library:
#   RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript docker/test-static.R
suppressPackageStartupMessages(library(tidyverse))
source("docker/package-plan.R")
source("R/functions.R")
source("R/course_data.R")
source("R/course_utils.R")
source("docker/check-fits.R")

for (file in c(list.files("docker", pattern = "\\.R$", full.names = TRUE),
               "docker/Rprofile.site", "R/course_utils.R")) parse(file)
lock <- renv::lockfile_read("renv.lock")
packages <- package_plan(lock)
stopifnot(lock$R$Version == "4.6.1", length(packages) == 156L,
          !any(c("emo", "targets", "devtools", "clustermq", "sf") %in% packages))
check_course_fits(getwd())

expect_error <- function(expr, pattern) {
  result <- tryCatch(force(expr), error = identity)
  stopifnot(inherits(result, "error"), grepl(pattern, conditionMessage(result)))
}
test_stored <- function() {
  old <- Sys.getenv(c("AFEC_CLASSROOM", "AFEC_STAN_BIN_DIR"), unset = NA_character_)
  on.exit({
    for (name in names(old)) {
      if (is.na(old[[name]])) Sys.unsetenv(name)
      else do.call(Sys.setenv, setNames(list(old[[name]]), name))
    }
  })
  bin <- tempfile("afec-static-models-")
  dir.create(bin)
  on.exit(unlink(bin, recursive = TRUE), add = TRUE)
  manifest <- list(binomial.stan = list(
    md5 = unname(tools::md5sum("stan/binomial.stan")), executable = "binomial"))
  saveRDS(manifest, file.path(bin, "manifest.rds"))
  Sys.setenv(AFEC_CLASSROOM = "TRUE", AFEC_STAN_BIN_DIR = bin)
  data <- list(N = 5, y = 2, a = 1, b = 1)
  fit <- fit_or_load("day1_seedling", "stan/binomial.stan", data, use_precomputed = TRUE)
  stopifnot(fit$source == "precomputed", nrow(fit$draws) == 4000L)
  data$a <- 2
  expect_error(fit_or_load("day1_seedling", "stan/binomial.stan", data,
                           use_precomputed = TRUE), "does not match")
  manifest$binomial.stan$md5 <- "stale-source"
  saveRDS(manifest, file.path(bin, "manifest.rds"))
  expect_error(fit_or_load("day1_seedling", "stan/binomial.stan",
                           list(N = 5, y = 2, a = 1, b = 1), use_precomputed = TRUE),
               "No matching precompiled")
  Sys.unsetenv("AFEC_CLASSROOM")
  # Existing non-classroom warning/fallback behavior is unchanged.
  changed <- suppressWarnings(fit_or_load("day1_seedling", "stan/binomial.stan",
                                          data, use_precomputed = TRUE))
  stopifnot(changed$source == "precomputed")
}
test_stored()

# File-operation simulation, NOT an actual Rocker/UID/Docker volume test.
# Substitute only the fixed paths, and stub chown (no privilege changes).
test_workspace <- function() {
  area <- tempfile("afec-static-init-")
  dir.create(area)
  on.exit(unlink(area, recursive = TRUE))
  template <- file.path(area, "template")
  dir.create(template)
  writeLines("starter", file.path(template, "student.txt"))
  dir.create(file.path(template, "nested"))
  writeLines("data", file.path(template, "nested", "data.txt"))
  home <- file.path(area, "home")
  script <- readLines("docker/03-afec-workspace.sh")[-1]
  script <- gsub("/home/rstudio", home, script, fixed = TRUE)
  script <- gsub("/opt/afec/template", template, script, fixed = TRUE)
  # GNU mv -T in production; translate the option for macOS simulation only.
  body <- paste(c("chown() { :; }", "mv() { if [ \"$1\" = -T ]; then shift; fi; command mv \"$@\"; }",
                  script), collapse = "\n")
  run <- function() processx::run("bash", c("-c", body), error_on_status = TRUE)
  run()
  course <- file.path(home, "workspace", "afec-bayes-2026")
  stopifnot(readLines(file.path(course, "student.txt")) == "starter")
  writeLines("student edit", file.path(course, "student.txt"))
  unlink(file.path(course, "nested", "data.txt"))
  writeLines("new template", file.path(template, "student.txt"))
  run()
  stopifnot(readLines(file.path(course, "student.txt")) == "student edit",
            !file.exists(file.path(course, "nested", "data.txt")))
  # Equivalent to a recreated container's non-persistent IDE preferences.
  unlink(file.path(home, ".config"), recursive = TRUE)
  run()
  stopifnot(readLines(file.path(course, "student.txt")) == "student edit")
  stopifnot(file.rename(course, paste0(course, "-saved")))
  stopifnot(file.symlink(file.path(area, "nonexistent"), course))
  rejected <- processx::run("bash", c("-c", body), error_on_status = FALSE)
  stopifnot(rejected$status != 0L, grepl("real directory", rejected$stderr))
  cat("Workspace copy/non-overwrite simulation OK (chown/mv platform stubs).\n")
}
test_workspace()
guard <- paste(readLines("docker/00-afec-guard.sh")[-1], collapse = "\n")
for (case in list(c(ROOT = "FALSE", DISABLE_AUTH = "FALSE", PASSWORD = "test-only"),
                  c(ROOT = "TRUE", DISABLE_AUTH = "FALSE", PASSWORD = "test-only"),
                  c(ROOT = "FALSE", DISABLE_AUTH = "TRUE", PASSWORD = "test-only"),
                  c(ROOT = "FALSE", DISABLE_AUTH = "FALSE", PASSWORD = ""))) {
  result <- processx::run("bash", c("-c", guard), env = c(case, DEFAULT_USER = "rstudio",
                          RUNROOTLESS = "false"), error_on_status = FALSE)
  expected <- case[["ROOT"]] == "FALSE" && case[["DISABLE_AUTH"]] == "FALSE" &&
    nzchar(case[["PASSWORD"]])
  stopifnot(identical(result$status == 0L, expected))
}
cat("Static R parsing, 156-package closure, 7 RDS, stored-fit guards, auth guards OK.\n")

dockerfile <- readLines("Dockerfile")
stopifnot(any(dockerfile == "FROM rocker/tidyverse:4.6.1"),
          tail(dockerfile[grepl("^USER ", dockerfile)], 1) == "USER root",
          !any(grepl("^(ENTRYPOINT|CMD) ", dockerfile)),
          !any(grepl("^ENV.*PASSWORD", dockerfile)))
for (line in dockerfile[grepl("^COPY ", dockerfile)]) {
  tokens <- strsplit(line, "[[:space:]]+")[[1]]
  for (src in tokens[2:(length(tokens) - 1L)]) stopifnot(length(Sys.glob(src)) > 0L)
}
for (file in c("README.md", "docker/README.md")) {
  points <- utf8ToInt(enc2utf8(paste(readLines(file), collapse = "\n")))
  stopifnot(!any((points >= 0x3040 & points <= 0x30ff) |
                  (points >= 0x4e00 & points <= 0x9fff)))
}
cat("Dockerfile invariants/COPY sources and English README checks OK.\n")
