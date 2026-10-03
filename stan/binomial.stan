data {
  int<lower=0> N;             // number of seedlings
  int<lower=0, upper=N> y;    // number of survivors
  real<lower=0> a;            // prior: p ~ Beta(a, b)
  real<lower=0> b;
}

parameters {
  real<lower=0, upper=1> p;   // survival probability
}

model {
  // prior
  p ~ beta(a, b);
  // likelihood
  y ~ binomial(N, p);
}
