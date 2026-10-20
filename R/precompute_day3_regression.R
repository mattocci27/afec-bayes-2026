# Instructor only: refit the three CNDD models, leaving other course fits alone.
# Rscript R/precompute_day3_regression.R
# Requires the project's instructor CmdStan environment.
library(tidyverse)
library(posterior)
library(cmdstanr)
library(here)

# Evaluate the exact visible simulation and Stan-data chunks in the handout.
# This avoids maintaining a second, potentially different simulation.
lines <- readLines(here("day3", "exercise.qmd"))
for (label in c("regression-data", "regression-stan-data")) {
  start <- grep(paste0("^```\\{r ", label, "[,}]"), lines)
  stopifnot(length(start) == 1L)
  end <- start + match("```", lines[(start + 1L):length(lines)])
  eval(parse(text = lines[(start + 1L):(end - 1L)]))
}

if (nzchar(Sys.getenv("CMDSTAN"))) {
  set_cmdstan_path(Sys.getenv("CMDSTAN"))
}
model <- cmdstan_model(here("stan", "cndd_hierarchical.stan"))
dir.create(here("fits"), showWarnings = FALSE)
for (m in seq_along(regression_inputs)) {
  sampled <- model$sample(
    data = regression_inputs[[m]],
    seed = 20261026 + m,
    chains = 4,
    parallel_chains = 2,
    iter_warmup = 1000,
    iter_sampling = 1000,
    adapt_delta = 0.98,
    refresh = 0
  )
  variables <- c("gamma", "tau", "alpha", "beta")
  if (m > 1L) {
    variables <- c(variables, "Omega[1,2]")
  }
  result <- list(
    draws = as_draws_df(sampled$draws(variables)),
    diagnostics = sampled$diagnostic_summary(),
    data = regression_inputs[[m]],
    source = "live",
    meta = list(
      stan_file = "stan/cndd_hierarchical.stan",
      stan_md5 = unname(tools::md5sum(here("stan", "cndd_hierarchical.stan"))),
      cmdstan = as.character(cmdstan_version()),
      seed = 20261026 + m,
      chains = 4,
      iter_warmup = 1000,
      iter_sampling = 1000,
      adapt_delta = 0.98,
      created = format(Sys.time(), "%Y-%m-%d")
    )
  )
  saveRDS(
    result,
    here("fits", paste0("day3_cndd_", names(regression_inputs)[m], ".rds")),
    compress = "xz"
  )
  print(sampled$summary(c("gamma", "tau")))
  print(result$diagnostics)
}
writeLines(
  capture.output(sessionInfo()),
  here("fits", "day3-cndd-sessionInfo.txt")
)
