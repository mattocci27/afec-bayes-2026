# Call after sourcing R/functions.R and R/course_data.R with tidyverse attached.
check_course_fits <- function(root) {
  allo <- make_allometry_data()
  ndd <- make_ndd_data()
  trees <- make_tree_data()
  bad_data <- allometry_stan_data(allo)
  bad_data$beta_sd <- NULL
  expected <- list(
    day1_seedling = list(N = 5, y = 2, a = 1, b = 1),
    day2_allo = allometry_stan_data(allo), day2_allo_bad = bad_data,
    day2_ndd = ndd_stan_data(ndd), day3_trees = tree_stan_data(trees),
    day3_vint = vint_stan_data(allo), day3_vslope = vslope_stan_data(allo)
  )
  models <- c("binomial", "linear", "linear_bad", "logit_reg", "logistic", "vint", "vslope")
  for (i in seq_along(expected)) {
    name <- names(expected)[i]
    path <- file.path(root, "fits", paste0(name, ".rds"))
    if (!file.exists(path)) stop("Instructor must supply precomputed fit: ", path)
    fit <- readRDS(path)
    stopifnot(isTRUE(all.equal(fit$data, expected[[name]], check.attributes = FALSE)),
              nrow(fit$draws) == 4000L,
              inherits(fit$draws, "draws_df"),
              all(c("num_divergent", "num_max_treedepth", "ebfmi") %in% names(fit$diagnostics)),
              fit$meta$cmdstan == "2.38.0",
              fit$meta$stan_file == paste0("stan/", models[i], ".stan"))
    # Deliberately do NOT refit or reject the intentionally bad diagnostics fit.
  }
  invisible(list(allometry = allo, ndd = ndd, trees = trees))
}
