# Simulated data sets shared by the day1-day3 slides, exercises, and
# R/precompute_fits.R. Every function sets its own seed, so the slides,
# the exercises, and the precomputed fits always see the same data.

#' Tree allometry: height ~ DBH for 10 species (Day 2 and Day 3)
#'
#' log(h_ij) ~ Normal(log(beta0_j) + beta1_j * log(dbh_ij / dbh_ref), sigma)
#' log(beta0_j) ~ Normal(gamma00 + gamma01 * wd_j, tau0)
#' beta1_j      ~ Normal(gamma10 + gamma11 * wd_j, tau1)
#'
#' beta0_j is the height (m) of species j at the reference DBH (40 cm).
#' Species differ a lot in sample size (3 to 40 trees), as in real plots.
allometry_truth <- list(
  dbh_ref = 40,
  gamma00 = log(16), gamma01 = 0.05, tau0 = 0.10,
  gamma10 = 0.60,    gamma11 = 0.10, tau1 = 0.05,
  sigma = 0.10
)

make_allometry_data <- function(seed = 5, truth = allometry_truth) {
  set.seed(seed)
  n_tree <- c(40, 35, 30, 25, 20, 15, 10, 6, 4, 3)
  n_sp <- length(n_tree)
  wd <- rnorm(n_sp, 0, 1) # wood density (scaled: mean 0, sd 1)
  log_beta0 <- rnorm(n_sp, truth$gamma00 + truth$gamma01 * wd, truth$tau0)
  beta1 <- rnorm(n_sp, truth$gamma10 + truth$gamma11 * wd, truth$tau1)

  sp_id <- rep(seq_len(n_sp), times = n_tree)
  dbh <- exp(rnorm(sum(n_tree), log(truth$dbh_ref), 0.5))
  log_h <- rnorm(
    sum(n_tree),
    log_beta0[sp_id] + beta1[sp_id] * log(dbh / truth$dbh_ref),
    truth$sigma
  )

  tibble::tibble(
    sp = factor(paste0("sp", sp_id), levels = paste0("sp", seq_len(n_sp))),
    wd = round(wd[sp_id], 2),
    dbh = round(dbh, 1),
    h = round(exp(log_h), 1)
  )
}

#' Seedling survival vs conspecific density in 60 quadrats (Day 2)
#'
#' suv_i ~ Binomial(n_i, p_i), logit(p_i) = alpha + beta * cons_i
ndd_truth <- list(alpha = qlogis(0.3), beta = -0.8)

make_ndd_data <- function(seed = 11, n_quadrat = 60, truth = ndd_truth) {
  set.seed(seed)
  cons <- rnorm(n_quadrat, 0, 1) # conspecific density (scaled)
  n <- sample(5:20, n_quadrat, replace = TRUE)
  suv <- rbinom(n_quadrat, n, plogis(truth$alpha + truth$beta * cons))
  tibble::tibble(
    quadrat = seq_len(n_quadrat),
    cons = round(cons, 2),
    n = n,
    suv = suv
  )
}

#' Seedling survival under eight mother trees (Day 3)
#'
#' Same data as the "Eight mother trees problem" in main.qmd
#' (generate_dummy_simple() in R/functions.R, as called in _targets.R).
make_tree_data <- function() {
  generate_dummy_simple(n_sp = 8, sig = 0.2, seed = 500) |>
    dplyr::rename(tree = sp)
}

# ---- Stan data lists ---------------------------------------------------------

allometry_stan_data <- function(d, beta_sd = 2.5, dbh_ref = allometry_truth$dbh_ref) {
  list(
    N = nrow(d),
    x = log(d$dbh / dbh_ref),
    y = log(d$h),
    beta_sd = beta_sd
  )
}

ndd_stan_data <- function(d) {
  list(N = nrow(d), n = d$n, suv = d$suv, cons = d$cons)
}

tree_stan_data <- function(d) {
  list(I = nrow(d), ii = seq_len(nrow(d)), suv = d$suv, N = d$n)
}

vint_stan_data <- function(d, dbh_ref = allometry_truth$dbh_ref) {
  list(
    N = nrow(d),
    J = nlevels(d$sp),
    sp = as.integer(d$sp),
    log_dbh = log(d$dbh / dbh_ref), # centred at the reference DBH
    log_h = log(d$h)
  )
}

vslope_stan_data <- function(d, dbh_ref = allometry_truth$dbh_ref) {
  wd_sp <- tapply(d$wd, d$sp, unique)
  list(
    N = nrow(d),
    K = 2, # tree-level predictors: intercept, log(DBH / dbh_ref)
    J = nlevels(d$sp),
    jj = as.integer(d$sp),
    L = 2, # species-level predictors: intercept, wood density
    x = cbind(1, log(d$dbh / dbh_ref)),
    u = rbind(1, as.numeric(wd_sp)),
    y = log(d$h)
  )
}
