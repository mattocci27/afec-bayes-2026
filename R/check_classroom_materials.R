# Lightweight integration check: no installation, compilation or sampling.
# Rscript R/check_classroom_materials.R
suppressPackageStartupMessages(library(tidyverse))
library(posterior)
library(here)
source(here("R/classroom_materials.R"))
source(here("R/functions.R"))
source(here("R/course_data.R"))
source(here("R/course_utils.R"))
source(here("R/course_visuals.R"))
source(here("docker/check-fits.R"))
check_course_fits(here())

check_exercises <- function() {
  old <- Sys.getenv(
    c("AFEC_CLASSROOM", "AFEC_STAN_BIN_DIR"),
    unset = NA_character_
  )
  on.exit(
    for (name in names(old)) {
      if (is.na(old[[name]])) {
        Sys.unsetenv(name)
      } else {
        do.call(Sys.setenv, setNames(list(old[[name]]), name))
      }
    },
    add = TRUE
  )
  bin <- tempfile("afec-material-check-")
  dir.create(bin)
  on.exit(unlink(bin, recursive = TRUE), add = TRUE)
  files <- list.files(here("stan"), "\\.stan$", full.names = TRUE)
  manifest <- setNames(
    lapply(files, function(f) list(md5 = unname(tools::md5sum(f)))),
    basename(files)
  )
  saveRDS(manifest, file.path(bin, "manifest.rds"))
  Sys.setenv(AFEC_CLASSROOM = "TRUE", AFEC_STAN_BIN_DIR = bin)
  # This fixture exercises source/data guards, not actual model executables.
  wrap <- function(real) {
    force(real)
    function(..., use_precomputed) {
      if (missing(use_precomputed) || !isTRUE(use_precomputed)) {
        stop("Core attempted live inference")
      }
      real(..., use_precomputed = TRUE)
    }
  }
  original_fit_or_load <- fit_or_load
  on.exit(
    assign("fit_or_load", original_fit_or_load, envir = globalenv()),
    add = TRUE
  )
  for (day in paste0("day", 1:3)) {
    lines <- readLines(here(day, "exercise-student.qmd"))
    stopifnot(identical(
      lines,
      student_source(readLines(here(day, "exercise.qmd")))
    ))
    stopifnot(
      !any(grepl(
        'when-meta="solutions"|ex1b-sol|allo-sol|tenx-sol|## Solution',
        lines
      ))
    )
    env <- new.env(parent = globalenv())
    count <- 0L
    i <- 1L
    while (i <= length(lines)) {
      if (!grepl("^```\\{r", lines[i])) {
        i <- i + 1L
        next
      }
      header <- lines[i]
      label <- sub("^```\\{r[[:space:]]*([^,}]*).*", "\\1", header)
      j <- i + 1L
      while (j <= length(lines) && !grepl("^```[[:space:]]*$", lines[j])) {
        j <- j + 1L
      }
      stopifnot(j <= length(lines))
      code <- paste(lines[(i + 1L):(j - 1L)], collapse = "\n")
      if (!grepl("eval[[:space:]]*=[[:space:]]*FALSE", header)) {
        stopifnot(!grepl("___", code, fixed = TRUE))
        invisible(eval(parse(text = code), env))
        count <- count + 1L
        if (label == "setup") {
          assign(
            "fit_or_load",
            wrap(get("fit_or_load", globalenv())),
            envir = globalenv()
          )
        }
      }
      i <- j + 1L
    }
    if (day == "day1") {
      stopifnot(!any(grepl("source\\(|course_fit\\(|plot_update\\(", lines)))
      exact <- dbeta(env$p, 3, 4)
      exact <- exact / sum(exact)
      stopifnot(max(abs(env$posterior - exact)) < 1e-12)
      # Run two possible participant-chosen surveys using the supplied chunk.
      first <- match("```{r core-data-comparison, fig.height=3.4}", lines)
      last <- first + match("```", lines[(first + 1L):length(lines)])
      starter <- lines[(first + 1L):(last - 1L)]
      variances <- numeric(2)
      for (k in 1:2) {
        N <- c(10, 50)[k]
        y <- 0.4 * N
        code <- starter
        code[code == "y <- 2"] <- paste("y <-", y)
        code[code == "N <- 5"] <- paste("N <-", N)
        chosen <- new.env(parent = globalenv())
        eval(parse(text = code), chosen)
        exact <- dbeta(chosen$p, y + 1, N - y + 1)
        exact <- exact / sum(exact)
        stopifnot(
          max(abs(chosen$posterior - exact)) < 1e-12,
          chosen$y / chosen$N == 0.4,
          identical(chosen$p, env$p)
        )
        variances[k] <- sum(
          chosen$posterior *
            (chosen$p - sum(chosen$p * chosen$posterior))^2
        )
      }
      stopifnot(variances[2] < variances[1])
    }
    if (day == "day2") {
      # The independent, explicit R workflow must match the canonical draw-to-curve
      # transformation, keep chains, and reject mismatched saved data.
      stopifnot(
        !any(grepl("source\\(|course_fit\\(|plot_cndd\\(|cndd_", lines)),
        posterior::nchains(env$coef_draws) == 4L,
        nrow(env$coefficient_table) == 2L,
        all(c("2.5%", "97.5%") %in% names(env$coefficient_table)),
        nrow(env$sampler_table) == 4L
      )
      stopifnot(
        identical(env$sampler_diagnostics, env$fit$diagnostics),
        all(grepl(
          "eval=FALSE",
          lines[grepl("^```\\{r fit-(brms|stan)", lines)]
        ))
      )
      stan_start <- match("```stan", lines)
      stan_end <- stan_start +
        match("```", lines[(stan_start + 1L):length(lines)])
      stopifnot(identical(
        lines[(stan_start + 1L):(stan_end - 1L)],
        readLines(here("stan", "logit_reg.stan"))
      ))
      canonical <- cndd_curve(env$coef_draws, x = env$curve_summary$cons)
      stopifnot(
        isTRUE(all.equal(
          as.matrix(env$curve_summary[, c("median", "lower", "upper")]),
          as.matrix(canonical[, c("median", "lower", "upper")]),
          check.attributes = FALSE
        )),
        all(diff(env$curve_summary$median) < 0)
      )
      layers <- ggplot2::ggplot_build(env$regression_plot)$data
      stopifnot(
        nrow(layers[[1]]) == nrow(env$curve_summary),
        nrow(layers[[3]]) == nrow(env$ndd)
      )
      stopifnot(
        env$fit$meta$stan_file == "stan/logit_reg.stan",
        nrow(env$ndd) == env$fit$data$N,
        identical(as.integer(env$ndd$n), env$fit$data$n),
        identical(as.integer(env$ndd$suv), env$fit$data$suv),
        isTRUE(all.equal(env$ndd$cons, env$fit$data$cons))
      )
    }
    if (day == "day3") {
      stopifnot(
        identical(env$stan_data, env$fit$data),
        identical(env$stan_data$ii, seq_len(env$stan_data$I)),
        length(env$p_a) == 4000L,
        posterior::nchains(env$fit$draws) == 4L,
        max(abs(env$p_a - env$fit$draws[["p[1]"]])) < 1e-5,
        env$survival_summary$lower < env$survival_summary$mean,
        env$survival_summary$mean < env$survival_summary$upper,
        identical(env$sampler_diagnostics, env$fit$diagnostics),
        nrow(env$probability_table) == 8L,
        nrow(env$sampler_table) == 4L,
        max(abs(env$replicated_counts - mother_replicates(env$fit))) == 0,
        all(env$replicated_counts >= 0),
        all(sweep(env$replicated_counts, 2, env$trees$n, "/") <= 1),
        !any(grepl("plot_mother_comparison|plot_mother_truth", lines)),
        !any(grepl(
          "source\\(|course_fit\\(|make_tree_data\\(|tree_stan_data\\(",
          lines
        ))
      )
      stan_start <- match("```stan", lines)
      stan_end <- stan_start +
        match("```", lines[(stan_start + 1L):length(lines)])
      stopifnot(
        identical(
          lines[(stan_start + 1L):(stan_end - 1L)],
          readLines(here("stan", "logistic.stan"))
        ),
        all(grepl("eval=FALSE", lines[grepl("^```\\{r fit-stan", lines)]))
      )
      # One data set, three distinct hierarchies, joint-draw predictions.
      stopifnot(
        nrow(env$reg_data) == 118L,
        nrow(env$species_info) == 12L,
        all(env$reg_data$suv <= env$reg_data$n),
        all(table(env$reg_data$species) == env$species_info$quadrats),
        abs(mean(env$species_info$u)) < 1e-12,
        abs(sd(env$species_info$u) - 1) < 1e-12,
        !any(grepl("_true", names(env$regression_base))),
        nrow(env$regression_curves) == 3L * 12L * 61L,
        all(env$regression_curves$lower <= env$regression_curves$median),
        all(env$regression_curves$upper >= env$regression_curves$median),
        all(env$regression_curves$lower >= 0),
        all(env$regression_curves$upper <= 1)
      )
      for (model_name in names(env$regression_fits)) {
        saved <- env$regression_fits[[model_name]]
        stopifnot(identical(saved$data, env$regression_inputs[[model_name]]))
        # Recover an individual grid prediction independently.
        expected <- plogis(
          saved$draws[["alpha[1]"]] +
            saved$draws[["beta[1]"]] * env$curve_grid[10]
        )
        actual <- env$regression_curves |>
          filter(model == model_name, species == "A", x == env$curve_grid[10])
        stopifnot(abs(actual$median - median(expected)) < 1e-12)
      }
      shared <- env$regression_fits$intercepts$draws
      stopifnot(identical(shared[["beta[1]"]], shared[["beta[12]"]]))
      # x*u has two main effects and an interaction; the trait is constant by species.
      design <- model.matrix(~ x * u, env$reg_data)
      stopifnot(
        identical(colnames(design), c("(Intercept)", "x", "u", "x:u")),
        max(abs(design[, "x:u"] - env$reg_data$x * env$reg_data$u)) < 1e-12,
        all(
          tapply(env$reg_data$u, env$reg_data$species, function(x) {
            length(unique(x))
          }) ==
            1L
        ),
        ncol(env$replicated_species) == 12L,
        all(env$replicated_species >= 0),
        all(
          sweep(
            env$replicated_species,
            2,
            as.numeric(tapply(env$reg_data$n, env$reg_data$species, sum)),
            "/"
          ) <=
            1
        )
      )
    }
    core <- grep(
      if (day == "day2") {
        "^# Seedling survival regression$"
      } else if (day == "day3") {
        "^# Mother-tree survival$"
      } else {
        "^# Core exercise:"
      },
      lines,
      value = TRUE
    )
    stopifnot(length(core) == 1L)
    if (day != "day1") {
      diagnostics <- course_diagnostics(env$fit)
      stopifnot(
        all(is.finite(as.matrix(diagnostics))),
        diagnostics$max_rhat <= 1.01,
        diagnostics$min_bulk_ess > 400,
        diagnostics$divergent == 0
      )
    }
    cat(
      day,
      ":",
      count,
      "safe chunks and",
      if (day == "day2") {
        "one guided walkthrough"
      } else {
        "one completed core exercise"
      },
      "passed with classroom guards\n"
    )
  }
  changed <- try(
    fit_or_load(
      "day1_seedling",
      "stan/binomial.stan",
      list(N = 100, y = 40, a = 1, b = 1),
      use_precomputed = TRUE
    ),
    silent = TRUE
  )
  stopifnot(inherits(changed, "try-error"), grepl("does not match", changed))
  manifest$binomial.stan$md5 <- "stale-source"
  saveRDS(manifest, file.path(bin, "manifest.rds"))
  stale <- try(
    fit_or_load(
      "day1_seedling",
      "stan/binomial.stan",
      list(N = 5, y = 2, a = 1, b = 1),
      use_precomputed = TRUE
    ),
    silent = TRUE
  )
  stopifnot(
    inherits(stale, "try-error"),
    grepl("No matching precompiled", stale)
  )
  cat("Changed-input and stale-source rejection retained.\n")
}
check_exercises()
for (file in list.files(here("fits"), "\\.rds$", full.names = TRUE)) {
  fit <- readRDS(file)
  s <- summarise_draws(fit$draws, rhat, ess_bulk, ess_tail)
  row <- tibble(
    fit_name = basename(file),
    max_rhat = max(s$rhat, na.rm = TRUE),
    min_bulk = min(s$ess_bulk, na.rm = TRUE),
    min_tail = min(s$ess_tail, na.rm = TRUE),
    divergences = sum(fit$diagnostics$num_divergent),
    treedepth = sum(fit$diagnostics$num_max_treedepth),
    min_ebfmi = min(fit$diagnostics$ebfmi)
  )
  print(row, width = Inf)
  if (!grepl("_bad\\.rds$", file)) {
    stopifnot(
      row$max_rhat <= 1.01,
      row$min_bulk > 400,
      row$min_tail > 400,
      row$divergences == 0,
      row$treedepth == 0,
      row$min_ebfmi > .3
    )
  }
}
cat(
  "Ten fits checked; the deliberately bad fit is exempt from healthy-fit thresholds.\n"
)
