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

#' Use a matching image-built executable; never use stale code after editing.
#' Outside the classroom image, retain cmdstanr's normal compilation behavior.
.course_model_record <- function(stan_file) {
  source_file <- here::here(stan_file)
  bin_dir <- Sys.getenv("AFEC_STAN_BIN_DIR")
  manifest <- readRDS(file.path(bin_dir, "manifest.rds"))
  record <- manifest[[basename(stan_file)]]
  if (is.null(record) || !identical(unname(tools::md5sum(source_file)), record$md5)) {
    stop("No matching precompiled model for ", stan_file,
         ". Source edits require an instructor-prepared executable; ",
         "automatic classroom recompilation is disabled.", call. = FALSE)
  }
  record
}

course_model <- function(stan_file) {
  source_file <- here::here(stan_file)
  bin_dir <- Sys.getenv("AFEC_STAN_BIN_DIR")
  if (!nzchar(bin_dir)) return(cmdstanr::cmdstan_model(source_file))
  record <- .course_model_record(stan_file)
  exe <- file.path(bin_dir, record$executable)
  if (file.access(exe, 1) != 0L) stop("Stan executable is not accessible: ", exe)
  cmdstanr::cmdstan_model(source_file, exe_file = exe, compile = FALSE)
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
#' run one after another (parallel_chains = 1) to limit per-session CPU use.
#' Shared-server capacity must still be measured before concurrent live fits.
fit_or_load <- function(name, stan_file, data,
                        seed = 123, chains = 4, parallel_chains = 1,
                        iter_warmup = 1000, iter_sampling = 1000, refresh = 0,
                        threads_per_chain = 1,
                        ...,
                        use_precomputed = USE_PRECOMPUTED, fallback = TRUE) {
  path <- here::here("fits", paste0(name, ".rds"))

  if (!use_precomputed) {
    res <- try({
      setup_cmdstan()
      mod <- course_model(stan_file)
      sample_threads <- threads_per_chain
      # A non-threaded model is already single-threaded. Retain compatibility
      # with locally compiled models without a spurious cmdstanr warning.
      if (identical(threads_per_chain, 1) && !isTRUE(mod$cpp_options()$stan_threads))
        sample_threads <- NULL
      fit <- mod$sample(
        data = data, seed = seed, chains = chains,
        parallel_chains = parallel_chains, iter_warmup = iter_warmup,
        iter_sampling = iter_sampling, refresh = refresh,
        threads_per_chain = sample_threads, ...
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
  if (identical(Sys.getenv("AFEC_CLASSROOM"), "TRUE")) {
    .course_model_record(stan_file) # Reject edited Stan code even in stored mode.
    if (!identical(basename(res$meta$stan_file), basename(stan_file)))
      stop("Stored fit belongs to a different Stan model", call. = FALSE)
  }
  if (!isTRUE(all.equal(res$data, data, check.attributes = FALSE))) {
    if (identical(Sys.getenv("AFEC_CLASSROOM"), "TRUE")) {
      stop("Stored fit '", name, "' does not match the supplied data/prior. ",
           "Use use_precomputed = FALSE, fallback = FALSE for this task ",
           "after the instructor enables live sampling.", call. = FALSE)
    }
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
