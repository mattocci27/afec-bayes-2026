# Shared figures and summaries for the agreed three-session course.
# Source after course_data.R and course_utils.R. All inference uses stored fits.
course_fit <- function(name) {
  specification <- switch(
    name,
    day1_seedling = list(
      "stan/binomial.stan",
      list(N = 5, y = 2, a = 1, b = 1)
    ),
    day2_ndd = list("stan/logit_reg.stan", ndd_stan_data(make_ndd_data())),
    day2_allo_bad = {
      data <- allometry_stan_data(make_allometry_data())
      data$beta_sd <- NULL
      list("stan/linear_bad.stan", data)
    },
    day3_trees = list("stan/logistic.stan", tree_stan_data(make_tree_data())),
    day3_vslope = list(
      "stan/vslope.stan",
      vslope_stan_data(make_allometry_data())
    ),
    stop("Unknown course result: ", name)
  )
  result <- fit_or_load(
    name,
    specification[[1]],
    specification[[2]],
    use_precomputed = TRUE
  )
  if (
    !isTRUE(all.equal(
      result$data,
      specification[[2]],
      check.attributes = FALSE
    )) ||
      !identical(result$meta$stan_file, specification[[1]])
  ) {
    stop("Stored result does not match the course model/data: ", name)
  }
  result
}

course_interval <- function(x) {
  tibble::tibble(
    mean = mean(x),
    median = median(x),
    lower = unname(quantile(x, .025)),
    upper = unname(quantile(x, .975))
  )
}

course_diagnostics <- function(fit) {
  s <- posterior::summarise_draws(
    fit$draws,
    rhat = posterior::rhat,
    ess_bulk = posterior::ess_bulk,
    ess_tail = posterior::ess_tail
  )
  dplyr::bind_cols(
    tibble::tibble(
      max_rhat = max(s$rhat, na.rm = TRUE),
      min_bulk_ess = min(s$ess_bulk, na.rm = TRUE),
      min_tail_ess = min(s$ess_tail, na.rm = TRUE)
    ),
    diagnostic_table(fit)
  )
}

plot_normal_prior_scale <- function() {
  # The familiar Normal-regression illustration in main.qmd.
  # Use a consistent slope of 100 in both the line and its label.
  set.seed(123)
  x <- rnorm(100)
  data <- tibble::tibble(x = x, y = rnorm(100, 2 * x - 1, 1))
  ggplot2::ggplot(data, ggplot2::aes(x, y)) +
    ggplot2::geom_point(size = 2.5, alpha = .7) +
    ggplot2::geom_abline(
      intercept = 2,
      slope = 100,
      colour = "#006DAE",
      linetype = 2,
      linewidth = 1.2
    ) +
    ggplot2::annotate(
      "text",
      x = 1.25,
      y = -4.6,
      label = "y = 100x + 2",
      colour = "#006DAE",
      size = 6
    ) +
    ggplot2::coord_cartesian(xlim = c(-3, 3), ylim = c(-6, 4)) +
    ggplot2::labs(
      x = "x (chosen measurement units)",
      y = "y (chosen measurement units)",
      subtitle = "Simulated Normal-response example from main.qmd"
    )
}

cndd_probabilities <- function(draws, x = c(-1, 1)) {
  purrr::map_dfr(x, function(value) {
    tibble::tibble(
      draw = seq_len(nrow(draws)),
      density = value,
      p = plogis(draws$alpha + draws$beta * value)
    )
  })
}

cndd_curve <- function(draws, x = seq(-2, 2, length.out = 81)) {
  purrr::map_dfr(x, function(value) {
    dplyr::bind_cols(
      tibble::tibble(density = value),
      course_interval(plogis(draws$alpha + draws$beta * value))
    )
  })
}

plot_cndd <- function(draws, data = make_ndd_data()) {
  curve <- cndd_curve(
    draws,
    seq(min(data$cons), max(data$cons), length.out = 81)
  )
  ggplot2::ggplot(curve, ggplot2::aes(density, median)) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = lower, ymax = upper),
      fill = "#d95f02",
      alpha = .22
    ) +
    ggplot2::geom_line(colour = "#d95f02", linewidth = 1.2) +
    ggplot2::geom_point(
      data = data,
      ggplot2::aes(cons, suv / n, size = n),
      inherit.aes = FALSE,
      alpha = .65
    ) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    ggplot2::labs(
      x = "Conspecific density (scaled)",
      y = "Survival probability",
      size = "Seedlings",
      subtitle = "Line: posterior median of p. Band: 95% interval for p"
    )
}

plot_cndd_comparison <- function(draws) {
  p <- cndd_probabilities(draws)
  summary <- p |>
    dplyr::group_by(density) |>
    dplyr::summarise(
      median = median(p),
      lower = quantile(p, .025),
      upper = quantile(p, .975)
    )
  ggplot2::ggplot(
    summary,
    ggplot2::aes(
      factor(
        density,
        labels = c("Low density (-1 SD)", "High density (+1 SD)")
      ),
      median
    )
  ) +
    ggplot2::geom_pointrange(
      ggplot2::aes(ymin = lower, ymax = upper),
      colour = "#d95f02",
      linewidth = .9
    ) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    ggplot2::labs(
      x = NULL,
      y = "Survival probability",
      subtitle = "Posterior median and 95% interval"
    )
}

cndd_predictions <- function(draws, n = 20, seed = 20261022) {
  set.seed(seed)
  cndd_probabilities(draws) |>
    dplyr::mutate(seedlings = n, survivors = rbinom(dplyr::n(), n, p))
}

plot_cndd_predictions <- function(predictions) {
  predictions |>
    dplyr::mutate(
      density = factor(
        density,
        labels = c("Low density (-1 SD)", "High density (+1 SD)")
      )
    ) |>
    ggplot2::ggplot(ggplot2::aes(survivors)) +
    ggplot2::geom_bar(fill = "#d95f02") +
    ggplot2::facet_wrap(~density) +
    ggplot2::labs(
      x = paste(
        "Survivors out of",
        unique(predictions$seedlings),
        "new seedlings"
      ),
      y = "Draws"
    )
}

cndd_replicates <- function(draws, data = make_ndd_data(), seed = 20261023) {
  set.seed(seed)
  # Retain the observed density and seedling count of every quadrat.
  t(vapply(
    seq_len(nrow(draws)),
    function(k) {
      rbinom(
        nrow(data),
        data$n,
        plogis(draws$alpha[k] + draws$beta[k] * data$cons)
      )
    },
    numeric(nrow(data))
  ))
}

plot_cndd_check <- function(replicates, data = make_ndd_data()) {
  intervals <- t(apply(
    sweep(replicates, 2, data$n, "/"),
    2,
    quantile,
    c(.025, .5, .975)
  ))
  d <- dplyr::mutate(
    data,
    lower = intervals[, 1],
    median = intervals[, 2],
    upper = intervals[, 3]
  )
  ggplot2::ggplot(d, ggplot2::aes(cons)) +
    ggplot2::geom_linerange(
      ggplot2::aes(ymin = lower, ymax = upper),
      colour = "#d95f02",
      alpha = .65
    ) +
    ggplot2::geom_point(
      ggplot2::aes(y = median),
      colour = "#d95f02",
      size = 2
    ) +
    ggplot2::geom_point(ggplot2::aes(y = suv / n), shape = 1, size = 3) +
    ggplot2::labs(
      x = "Conspecific density (scaled)",
      y = "Proportion surviving",
      subtitle = "Open: observed. Orange: median and 95% interval for replicated proportions"
    )
}

plot_cndd_spread_check <- function(replicates, data = make_ndd_data()) {
  spread <- apply(sweep(replicates, 2, data$n, "/"), 1, sd)
  ggplot2::ggplot(tibble::tibble(spread), ggplot2::aes(spread)) +
    ggplot2::geom_histogram(bins = 30, fill = "#d95f02", alpha = .65) +
    ggplot2::geom_vline(xintercept = sd(data$suv / data$n), linewidth = 1) +
    ggplot2::labs(
      x = "SD of survival proportions across quadrats",
      y = "Data sets",
      subtitle = "Line: observed spread. Histogram: model-generated spread"
    )
}

mother_comparison <- function(fit = course_fit("day3_trees"), seed = 42) {
  trees <- make_tree_data()
  set.seed(seed)
  total <- sum(trees$suv)
  N <- sum(trees$n)
  pooled <- course_interval(rbeta(nrow(fit$draws), 1 + total, 1 + N - total))
  purrr::map_dfr(seq_len(nrow(trees)), function(j) {
    separate <- course_interval(rbeta(
      nrow(fit$draws),
      1 + trees$suv[j],
      1 + trees$n[j] - trees$suv[j]
    ))
    partial <- course_interval(fit$draws[[paste0("p[", j, "]")]])
    dplyr::bind_rows(
      Complete = pooled,
      Separate = separate,
      Partial = partial,
      .id = "model"
    ) |>
      dplyr::mutate(
        tree = trees$tree[j],
        n = trees$n[j],
        observed = trees$suv[j] / trees$n[j]
      )
  }) |>
    dplyr::mutate(
      model = factor(model, levels = c("Complete", "Separate", "Partial"))
    )
}

plot_mother_comparison <- function(comparison = mother_comparison()) {
  tree_order <- comparison |>
    dplyr::filter(model == "Separate") |>
    dplyr::arrange(mean, tree) |>
    dplyr::pull(tree) |>
    as.character()
  estimates <- comparison |>
    dplyr::filter(model != "Complete") |>
    dplyr::mutate(tree = factor(tree, levels = tree_order))
  pooled <- comparison |>
    dplyr::filter(model == "Complete") |>
    dplyr::distinct(mean, lower, upper)
  rows <- estimates |> dplyr::distinct(tree, n)
  row_labels <- stats::setNames(
    paste0(rows$tree, " (n = ", rows$n, ")"),
    rows$tree
  )
  dodge <- ggplot2::position_dodge(width = .5, orientation = "y")
  ggplot2::ggplot(
    estimates,
    ggplot2::aes(mean, tree, colour = model, fill = model, shape = model)
  ) +
    ggplot2::annotate(
      "rect",
      xmin = pooled$lower,
      xmax = pooled$upper,
      ymin = -Inf,
      ymax = Inf,
      fill = "grey60",
      alpha = .14
    ) +
    ggplot2::geom_vline(
      xintercept = pooled$mean,
      colour = "grey45",
      linetype = "dashed",
      linewidth = .6
    ) +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = lower, xmax = upper),
      orientation = "y",
      position = dodge,
      width = .18,
      linewidth = .6,
      show.legend = FALSE
    ) +
    ggplot2::geom_point(position = dodge, size = 3.5, stroke = .8) +
    ggplot2::scale_colour_manual(
      values = c(Separate = "#7570b3", Partial = "#d95f02"),
      labels = c(Separate = "Separate", Partial = "Partial pooling")
    ) +
    ggplot2::scale_fill_manual(
      values = c(Separate = "white", Partial = "#d95f02"),
      labels = c(Separate = "Separate", Partial = "Partial pooling")
    ) +
    ggplot2::scale_shape_manual(
      values = c(Separate = 21, Partial = 16),
      labels = c(Separate = "Separate", Partial = "Partial pooling")
    ) +
    ggplot2::scale_x_continuous(
      breaks = seq(0, 1, .2),
      expand = ggplot2::expansion(mult = 0)
    ) +
    ggplot2::coord_cartesian(xlim = c(0, max(comparison$upper) + .025)) +
    ggplot2::scale_y_discrete(
      limits = tree_order,
      labels = row_labels,
      expand = ggplot2::expansion(add = .55)
    ) +
    ggplot2::labs(
      x = "Survival probability",
      y = "Mother tree",
      colour = NULL,
      fill = NULL,
      shape = NULL,
      subtitle = "Complete pooling: grey line and 95% ribbon"
    ) +
    ggplot2::theme(
      legend.position = "top",
      legend.justification = "left",
      panel.grid.minor = ggplot2::element_blank()
    )
}

plot_mother_truth <- function(
  comparison = mother_comparison(),
  trees = make_tree_data(),
  highlight = "H",
  limits = c(0, .55)
) {
  # Match truth to estimates by ID, independently of row or factor order.
  estimates <- comparison |>
    dplyr::filter(model != "Complete") |>
    dplyr::mutate(tree = as.character(tree)) |>
    dplyr::left_join(
      trees |> dplyr::transmute(tree = as.character(tree), p_true),
      by = "tree",
      relationship = "many-to-one"
    )
  stopifnot(!anyNA(estimates$p_true))
  movement <- estimates |>
    dplyr::select(tree, n, p_true, model, mean) |>
    tidyr::pivot_wider(names_from = model, values_from = mean)
  # Leave space around each point so arrowheads remain visible.
  movement <- movement |>
    dplyr::mutate(
      direction = sign(Partial - Separate),
      inset = pmin(abs(Partial - Separate) / 4, diff(limits) * .025),
      arrow_start = Separate + direction * inset,
      arrow_end = Partial - direction * inset
    )
  highlight_tree <- movement |> dplyr::filter(tree == highlight)
  ggplot2::ggplot(estimates, ggplot2::aes(p_true, mean)) +
    ggplot2::geom_abline(
      intercept = 0,
      slope = 1,
      linetype = "dashed",
      colour = "grey45",
      linewidth = .6
    ) +
    ggplot2::geom_segment(
      data = movement,
      ggplot2::aes(
        x = p_true,
        xend = p_true,
        y = arrow_start,
        yend = arrow_end
      ),
      inherit.aes = FALSE,
      colour = "grey35",
      linewidth = 1.1,
      arrow = grid::arrow(length = grid::unit(.12, "inches"), type = "closed")
    ) +
    ggplot2::geom_point(
      ggplot2::aes(colour = model, fill = model, shape = model),
      size = 7,
      stroke = 1.2
    ) +
    ggplot2::geom_text(
      data = highlight_tree,
      ggplot2::aes(
        x = p_true - .012,
        y = Separate,
        label = paste0("Tree ", tree, "\n(n = ", n, ")")
      ),
      inherit.aes = FALSE,
      hjust = 1,
      vjust = .5,
      size = 6.5,
      colour = "grey20"
    ) +
    ggplot2::scale_colour_manual(
      values = c(Separate = "#7570b3", Partial = "#d95f02"),
      labels = c(Separate = "Separate", Partial = "Partial pooling")
    ) +
    ggplot2::scale_fill_manual(
      values = c(Separate = "white", Partial = "#d95f02"),
      labels = c(Separate = "Separate", Partial = "Partial pooling")
    ) +
    ggplot2::scale_shape_manual(
      values = c(Separate = 21, Partial = 16),
      labels = c(Separate = "Separate", Partial = "Partial pooling")
    ) +
    ggplot2::scale_x_continuous(breaks = seq(0, .5, .1)) +
    ggplot2::scale_y_continuous(breaks = seq(0, .5, .1)) +
    ggplot2::coord_fixed(
      ratio = 1,
      xlim = limits,
      ylim = limits,
      expand = FALSE
    ) +
    ggplot2::labs(
      x = "True probability",
      y = "Survival estimate",
      colour = NULL,
      fill = NULL,
      shape = NULL
    ) +
    ggplot2::theme(
      legend.position = "top",
      legend.justification = "center",
      panel.grid.minor = ggplot2::element_blank()
    )
}

plot_group_spread <- function() {
  d <- tidyr::crossing(tree = LETTERS[1:8], sigma = c(.1, 1, 3)) |>
    dplyr::mutate(
      p = plogis(sigma * qnorm((match(tree, LETTERS[1:8]) - .5) / 8)),
      spread = factor(
        sigma,
        labels = c("Small SD: 0.1", "SD: 1", "Large SD: 3")
      )
    )
  ggplot2::ggplot(d, ggplot2::aes(p, tree)) +
    ggplot2::geom_point(size = 4, colour = "#7570b3") +
    ggplot2::facet_wrap(~spread) +
    ggplot2::scale_x_continuous(
      limits = c(0, 1),
      breaks = c(0, .5, 1),
      labels = c("0", "0.5", "1")
    ) +
    ggplot2::labs(
      x = "Illustrative mother-tree survival probabilities",
      y = "Mother tree",
      subtitle = "Fixed logit centre = 0. Only the group SD changes"
    )
}


# Main-style group illustration. These are hypothetical distributions, not
# posteriors from the mother-tree fit. Keep the same standardized centres and
# within-curve logit SD in every panel so only between-tree SD changes.
plot_group_curves <- function() {
  within_sd <- .2
  centres <- tidyr::crossing(tree = LETTERS[1:8], sigma = c(.1, 1, 3)) |>
    dplyr::mutate(centre = sigma * qnorm((match(tree, LETTERS[1:8]) - .5) / 8))
  d <- tidyr::crossing(centres, logit_p = seq(-7, 7, length.out = 4001)) |>
    dplyr::mutate(
      p = plogis(logit_p),
      # Change of variables: dz/dp = 1 / (p * (1-p)).
      density = dnorm(logit_p, centre, within_sd) / (p * (1 - p))
    ) |>
    dplyr::group_by(sigma, tree) |>
    dplyr::mutate(relative_density = density / max(density)) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      spread = factor(
        sigma,
        levels = c(.1, 1, 3),
        labels = c("sigma == 0.1", "sigma == 1", "sigma == 3")
      )
    )
  ggplot2::ggplot(d, ggplot2::aes(p, relative_density, colour = tree)) +
    ggplot2::geom_line(linewidth = .8) +
    ggplot2::facet_wrap(~spread, ncol = 1, labeller = ggplot2::label_parsed) +
    ggplot2::scale_colour_brewer(palette = "Dark2", guide = "none") +
    ggplot2::scale_x_continuous(
      limits = c(0, 1),
      breaks = c(0, .25, .5, .75, 1),
      expand = ggplot2::expansion(mult = .01)
    ) +
    ggplot2::scale_y_continuous(breaks = c(0, 1)) +
    ggplot2::labs(
      x = "Survival probability, p",
      y = "Relative density",
      subtitle = "Illustrative mother-tree curves; group logit centre = 0",
      caption = "Eight colours: eight mother trees. Curves scaled to peak 1 (not fitted)."
    ) +
    ggplot2::theme(
      axis.title = ggplot2::element_text(size = 20),
      axis.text = ggplot2::element_text(size = 16),
      strip.text = ggplot2::element_text(size = 18),
      plot.subtitle = ggplot2::element_text(size = 18),
      plot.caption = ggplot2::element_text(size = 14)
    )
}

plot_group_sd_priors <- function() {
  d <- tibble::tibble(sigma = seq(0, 10, length.out = 2001)) |>
    dplyr::mutate(
      `Half-Normal(0, 1)` = 2 * dnorm(sigma, 0, 1),
      `Half-Cauchy(0, 1)` = 2 * dcauchy(sigma, 0, 1),
      `Half-Normal(0, 10)` = 2 * dnorm(sigma, 0, 10)
    ) |>
    tidyr::pivot_longer(-sigma, names_to = "prior", values_to = "density") |>
    dplyr::mutate(
      prior = factor(
        prior,
        levels = c(
          "Half-Normal(0, 1)",
          "Half-Cauchy(0, 1)",
          "Half-Normal(0, 10)"
        )
      )
    )
  ggplot2::ggplot(d, ggplot2::aes(sigma, density, colour = prior)) +
    ggplot2::geom_line(linewidth = 1.2) +
    ggplot2::facet_wrap(~prior, nrow = 1) +
    ggplot2::scale_colour_manual(
      values = c(
        "Half-Normal(0, 1)" = "#d95f02",
        "Half-Cauchy(0, 1)" = "#7570b3",
        "Half-Normal(0, 10)" = "grey40"
      ),
      guide = "none"
    ) +
    ggplot2::scale_x_continuous(
      limits = c(0, 10),
      breaks = c(0, 5, 10),
      expand = ggplot2::expansion(mult = .01)
    ) +
    ggplot2::scale_y_continuous(limits = c(0, .85), breaks = c(0, .4, .8)) +
    ggplot2::labs(
      x = expression(sigma ~ "(group SD on the logit scale)"),
      y = "Prior density"
    ) +
    ggplot2::theme(
      axis.title = ggplot2::element_text(size = 22),
      axis.text = ggplot2::element_text(size = 20),
      strip.text = ggplot2::element_text(size = 18),
      panel.spacing.x = grid::unit(1.4, "lines")
    )
}

mother_replicates <- function(fit = course_fit("day3_trees"), seed = 20261025) {
  set.seed(seed)
  trees <- make_tree_data()
  p <- as.matrix(as.data.frame(fit$draws)[, paste0("p[", 1:8, "]")])
  vapply(
    seq_len(8),
    function(j) rbinom(nrow(p), trees$n[j], p[, j]),
    numeric(nrow(p))
  )
}

plot_mother_check <- function(fit = course_fit("day3_trees")) {
  replicates <- mother_replicates(fit)
  trees <- make_tree_data()
  intervals <- t(apply(replicates, 2, quantile, c(.025, .5, .975)))
  d <- dplyr::mutate(
    trees,
    lower = intervals[, 1],
    median = intervals[, 2],
    upper = intervals[, 3]
  )
  ggplot2::ggplot(d, ggplot2::aes(tree, median)) +
    ggplot2::geom_pointrange(
      ggplot2::aes(ymin = lower, ymax = upper),
      colour = "#d95f02"
    ) +
    ggplot2::geom_point(ggplot2::aes(y = suv), shape = 1, size = 4) +
    ggplot2::labs(
      x = "Mother tree",
      y = "Survivors",
      subtitle = "Open: observed. Orange: median and 95% interval for replicated counts"
    )
}

cndd_concept <- function() {
  # Same seeded conceptual example as main.qmd. These are not fitted results.
  set.seed(123)
  abundance <- rnorm(10)
  slope <- rnorm(10, -.8 + .3 * abundance, .1)
  intercept <- rnorm(10, 0, .5)
  species <- tibble::tibble(
    species = factor(seq_len(10)),
    abundance,
    slope,
    intercept
  )
  curves <- tidyr::crossing(species, density = seq(-3, 3, length.out = 80)) |>
    dplyr::mutate(p = plogis(intercept + slope * density))
  list(species = species, curves = curves)
}

plot_cndd_species <- function(concept = cndd_concept()) {
  ggplot2::ggplot(concept$curves, ggplot2::aes(density, p, colour = species)) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::guides(colour = "none") +
    ggplot2::labs(
      x = "Conspecific density (scaled)",
      y = "Survival probability",
      subtitle = "Simulated relationships, for explanation"
    )
}

plot_cndd_abundance <- function(concept = cndd_concept()) {
  ggplot2::ggplot(
    concept$species,
    ggplot2::aes(abundance, slope, colour = species)
  ) +
    ggplot2::geom_abline(
      intercept = -.8,
      slope = .3,
      linetype = 2,
      colour = "grey40"
    ) +
    ggplot2::geom_point(size = 4) +
    ggplot2::guides(colour = "none") +
    ggplot2::labs(
      x = "Species abundance (scaled)",
      y = "Density coefficient",
      subtitle = "Simulated coefficients. Dashed: generating relationship"
    )
}

plot_wood_density <- function(fit = course_fit("day3_vslope")) {
  data <- make_allometry_data() |> dplyr::distinct(sp, wd)
  d <- fit$draws
  points <- purrr::map_dfr(seq_len(nrow(data)), function(j) {
    dplyr::bind_cols(data[j, ], course_interval(d[[paste0("beta[2,", j, "]")]]))
  })
  line <- purrr::map_dfr(
    seq(min(data$wd), max(data$wd), length.out = 51),
    function(w) {
      dplyr::bind_cols(
        tibble::tibble(wd = w),
        course_interval(d[["gamma[2,1]"]] + d[["gamma[2,2]"]] * w)
      )
    }
  )
  ggplot2::ggplot(line, ggplot2::aes(wd, median)) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = lower, ymax = upper),
      fill = "#d95f02",
      alpha = .2
    ) +
    ggplot2::geom_line(colour = "#d95f02") +
    ggplot2::geom_pointrange(
      data = points,
      ggplot2::aes(ymin = lower, ymax = upper),
      colour = "#7570b3"
    ) +
    ggplot2::labs(
      x = "Wood density (scaled)",
      y = "Allometric exponent",
      subtitle = "Simulated tree data. Points: species. Line: expected exponent (95% intervals)"
    )
}
