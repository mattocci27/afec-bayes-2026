// DELIBERATELY BROKEN MODEL -- for the diagnostics exercise only.
// The model has two intercepts (alpha1 + alpha2). The data can only
// inform their sum, so alpha1 and alpha2 are not identified.
data {
  int<lower=0> N;
  vector[N] x;
  vector[N] y;
}

parameters {
  real alpha1;
  real alpha2;
  real beta;
  real<lower=0> sigma;
}

model {
  y ~ normal(alpha1 + alpha2 + beta * x, sigma);
  alpha1 ~ normal(0, 1000);
  alpha2 ~ normal(0, 1000);
  beta ~ normal(0, 2.5);
  sigma ~ normal(0, 1);
}
