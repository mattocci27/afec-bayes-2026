# Helpers shared by the day1-day3 exercises and R/precompute_fits.R.

# Set AFEC_USE_PRECOMPUTED=TRUE (environment variable) to skip all sampling
# and load the stored results in fits/ instead.
USE_PRECOMPUTED <- isTRUE(as.logical(Sys.getenv("AFEC_USE_PRECOMPUTED", "FALSE")))

#' Find CmdStan without hard-coding a machine-specific path.
#' Order: path already known to cmdstanr / CMDSTAN env var -> newest /opt/cmdstan/*.
setup_cmdstan <- function() {
  if (!requireNamespace("cmdstanr", quietly = TRUE)) return(invisible(FALSE))
  ok <- !inherits(try(cmdstanr::cmdstan_path(), silent = TRUE), "try-error")
  if (!ok) {
    cand <- sort(Sys.glob("/opt/cmdstan/cmdstan-*"), decreasing = TRUE)
    if (length(cand) > 0) {
      ok <- !inherits(
        try(suppressMessages(cmdstanr::set_cmdstan_path(cand[1])), silent = TRUE),
        "try-error")
    }
  }
  invisible(ok)
}

#' Run a Stan model, or load a precomputed result if sampling is not possible.
#'
#' Returns a list with
#'   draws:       posterior draws (a `draws_df`; one row per draw)
#'   diagnostics: divergences, max-treedepth hits, E-BFMI (per chain)
#'   data:        the data list that was used
#'   source:      "live" or "precomputed"
#'
#' Classroom defaults: Stan's default of 4 chains x 1000 draws, with the chains
#' run one after another (parallel_chains = 1), so that 30 people can sample
#' at the same time on a shared server.
fit_or_load <- function(name, stan_file, data,
                        seed = 123, chains = 4, parallel_chains = 1,
                        iter_warmup = 1000, iter_sampling = 1000, refresh = 0,
                        ...,
                        use_precomputed = USE_PRECOMPUTED, fallback = TRUE) {
  path <- here::here("fits", paste0(name, ".rds"))

  if (!use_precomputed) {
    res <- try({
      setup_cmdstan()
      mod <- cmdstanr::cmdstan_model(here::here(stan_file))
      fit <- mod$sample(
        data = data, seed = seed, chains = chains,
        parallel_chains = parallel_chains, iter_warmup = iter_warmup,
        iter_sampling = iter_sampling, refresh = refresh, ...
      )
      draws <- posterior::as_draws_df(fit$draws())
      # log_lik is only needed for model comparison; drop it to keep things small
      draws <- posterior::subset_draws(
        draws,
        variable = setdiff(posterior::variables(draws),
          grep("^log_lik", posterior::variables(draws), value = TRUE))
      )
      list(
        draws = draws,
        diagnostics = fit$diagnostic_summary(quiet = TRUE),
        data = data,
        source = "live"
      )
    }, silent = TRUE)
    if (!inherits(res, "try-error")) return(res)
    if (!fallback) stop(res)
    message("Sampling did not work here: loading the precomputed result instead.")
  }

  if (!file.exists(path)) {
    stop("No precomputed result found: ", path, call. = FALSE)
  }
  res <- readRDS(path)
  res$source <- "precomputed"
  if (!isTRUE(all.equal(res$data, data, check.attributes = FALSE))) {
    warning(
      "The precomputed result '", name, "' was fitted to the DEFAULT data/prior, ",
      "not to the data you supplied. It will not reflect your changes.",
      call. = FALSE
    )
  }
  res
}

#' Total number of divergent transitions and max-treedepth hits, lowest E-BFMI.
diagnostic_table <- function(fit) {
  d <- fit$diagnostics
  tibble::tibble(
    divergent = sum(d$num_divergent),
    max_treedepth = sum(d$num_max_treedepth),
    min_ebfmi = round(min(d$ebfmi), 2)
  )
}

# ---- Day 1: prior x likelihood = posterior, for survival data ----------------
# y survivors out of N seedlings, prior p ~ Beta(a, b).
# The posterior is then Beta(a + y, b + N - y): no sampling needed.

beta_update <- function(y, N, a = 1, b = 1) {
  tibble::tibble(
    p = seq(0, 1, length.out = 501),
    Prior = dbeta(p, a, b),
    Likelihood = dbeta(p, y + 1, N - y + 1), # likelihood, rescaled to area 1
    Posterior = dbeta(p, a + y, b + N - y)
  )
}

plot_update <- function(y, N, a = 1, b = 1, linewidth = 1.2) {
  beta_update(y, N, a, b) |>
    tidyr::pivot_longer(-p, names_to = "curve", values_to = "density") |>
    dplyr::mutate(curve = factor(curve, levels = c("Prior", "Likelihood", "Posterior"))) |>
    ggplot2::ggplot(ggplot2::aes(p, density, colour = curve, linetype = curve)) +
    ggplot2::geom_line(linewidth = linewidth) +
    ggplot2::scale_colour_manual(
      values = c(Prior = "#7570b3", Likelihood = "#1b9e77", Posterior = "#d95f02")) +
    ggplot2::scale_linetype_manual(
      values = c(Prior = "dashed", Likelihood = "dotted", Posterior = "solid")) +
    ggplot2::labs(
      x = "Survival probability p", y = "Density", colour = NULL, linetype = NULL,
      title = sprintf("%d of %d survived; prior Beta(%g, %g)", y, N, a, b))
}

summarise_update <- function(y, N, a = 1, b = 1) {
  tibble::tibble(
    data = sprintf("%d/%d", y, N),
    prior = sprintf("Beta(%g, %g)", a, b),
    mle = y / N,
    post_mean = (a + y) / (a + b + N),
    q5 = qbeta(0.05, a + y, b + N - y),
    q95 = qbeta(0.95, a + y, b + N - y)
  )
}
