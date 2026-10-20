# Instructor script: fit every course model once and store the results in fits/.
#
#   Rscript R/precompute_fits.R
#
# The slides read these files (so rendering slides never needs CmdStan), and
# the exercises fall back to them when live sampling is not possible.
# Sampling settings are the defaults of fit_or_load(), i.e. the same settings
# the participants use, unless stated otherwise below.

library(tidyverse)
library(cmdstanr)
library(posterior)
library(here)

source(here("R/functions.R"))
source(here("R/course_data.R"))
source(here("R/course_utils.R"))

dir.create(here("fits"), showWarnings = FALSE)

save_fit <- function(name, stan_file, data, ...) {
  res <- fit_or_load(
    name,
    stan_file,
    data,
    ...,
    use_precomputed = FALSE,
    fallback = FALSE
  )
  res$meta <- list(
    stan_file = stan_file,
    cmdstan = cmdstanr::cmdstan_version(),
    args = list(...),
    created = format(Sys.time(), "%Y-%m-%d")
  )
  saveRDS(res, here("fits", paste0(name, ".rds")), compress = "xz")
  message(
    name,
    ": ",
    paste(
      names(diagnostic_table(res)),
      unlist(diagnostic_table(res)),
      collapse = ", "
    )
  )
  invisible(res)
}

allo <- make_allometry_data()
ndd <- make_ndd_data()
trees <- make_tree_data()

# Day 1: 2 survivors out of 5 seedlings, flat prior
save_fit(
  "day1_seedling",
  "stan/binomial.stan",
  list(N = 5, y = 2, a = 1, b = 1)
)

# Day 2: allometry, all trees pooled
save_fit("day2_allo", "stan/linear.stan", allometry_stan_data(allo))

# Day 2: deliberately non-identified model (diagnostics exercise).
# Precomputed only: it is slow and it is supposed to fail.
allo_bad_data <- allometry_stan_data(allo)
allo_bad_data$beta_sd <- NULL
save_fit("day2_allo_bad", "stan/linear_bad.stan", allo_bad_data)

# Day 2: seedling survival vs conspecific density
save_fit("day2_ndd", "stan/logit_reg.stan", ndd_stan_data(ndd))

# Day 3: eight mother trees, partial pooling
save_fit("day3_trees", "stan/logistic.stan", tree_stan_data(trees))

# Day 3: allometry, varying intercepts
save_fit("day3_vint", "stan/vint.stan", vint_stan_data(allo))

# Day 3: allometry, varying intercepts and slopes + wood density
# Heavier model: default to the precomputed result in class.
save_fit(
  "day3_vslope",
  "stan/vslope.stan",
  vslope_stan_data(allo),
  adapt_delta = 0.95
)

# Day 3: the three CNDD regression models used in the expanded handout.
source(here("R/precompute_day3_regression.R"))

writeLines(capture.output(sessionInfo()), here("fits", "sessionInfo.txt"))
