data {
  int<lower=0> N;           // number of observations
  vector[N] x;              // predictor
  vector[N] y;              // response
  real<lower=0> beta_sd;    // prior SD for the slope
}

parameters {
  real alpha;               // intercept
  real beta;                // slope
  real<lower=0> sigma;      // residual SD
}

model {
  // likelihood
  y ~ normal(alpha + beta * x, sigma);
  // priors
  alpha ~ normal(0, 2.5);
  beta ~ normal(0, beta_sd);
  sigma ~ normal(0, 1);     // half-normal, because sigma > 0
}
