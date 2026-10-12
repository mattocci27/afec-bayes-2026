# Non-root smoke test (build hook and later manual runtime/offline validation).
args <- commandArgs(trailingOnly = TRUE)
root <- if (length(args)) args[1] else "/home/rstudio/workspace/afec-bayes-2026"
stopifnot(Sys.info()[["effective_user"]] != "root", as.character(getRversion()) == "4.6.1")
setwd(root)
versions <- read.delim("/opt/afec/packages.tsv", stringsAsFactors = FALSE)
for (i in seq_len(nrow(versions))) {
  stopifnot(as.character(packageVersion(versions$package[i])) == versions$version[i])
}
for (name in readLines("/opt/afec/course-packages.txt")) {
  stopifnot(requireNamespace(name, quietly = TRUE))
}
stopifnot(as.character(cmdstanr::cmdstan_version()) == "2.38.0",
          normalizePath(cmdstanr::cmdstan_path()) == normalizePath(Sys.getenv("CMDSTAN")),
          getOption("mc.cores") == 1L,
          all(Sys.getenv(c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS")) == "1"))
suppressPackageStartupMessages(library(tidyverse))
source("R/functions.R")
source("R/course_data.R")
source("R/course_utils.R")
source("/opt/afec/bin/check-fits.R")
check_course_fits(root)
manifest <- readRDS(file.path(Sys.getenv("AFEC_STAN_BIN_DIR"), "manifest.rds"))
for (name in names(manifest)) {
  mod <- course_model(file.path("stan", name))
  stopifnot(file.access(mod$exe_file(), 1) == 0L)
  status <- system2(mod$exe_file(), "help", stdout = FALSE, stderr = FALSE)
  stopifnot(status == 0L)
}
stored <- fit_or_load("day1_seedling", "stan/binomial.stan",
                      data = list(N = 5, y = 2, a = 1, b = 1), use_precomputed = TRUE)
stopifnot(stored$source == "precomputed")
live <- fit_or_load("day1_seedling", "stan/binomial.stan",
                    data = list(N = 5, y = 2, a = 1, b = 1),
                    chains = 2, parallel_chains = 1, threads_per_chain = 1,
                    iter_warmup = 50, iter_sampling = 50,
                    use_precomputed = FALSE, fallback = FALSE)
# Short run checks execution, NOT convergence or adequacy for scientific use.
stopifnot(live$source == "live", nrow(live$draws) == 100L)
ggplot2::ggsave(tempfile(fileext = ".png"), plot_update(2, 5), width = 5, height = 3)
cat("AFEC smoke test passed; this is not a 30-user load test.\n")
