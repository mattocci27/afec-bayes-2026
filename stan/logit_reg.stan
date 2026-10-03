data {
  int<lower=0> N;               // number of quadrats
  array[N] int<lower=0> n;      // seedlings per quadrat
  array[N] int<lower=0> suv;    // survivors per quadrat
  vector[N] cons;               // conspecific density (scaled)
}

parameters {
  real alpha;                   // intercept (logit scale)
  real beta;                    // slope (logit scale)
}

model {
  // likelihood: logit(p) = alpha + beta * cons
  suv ~ binomial_logit(n, alpha + beta * cons);
  // priors
  alpha ~ normal(0, 2.5);
  beta ~ normal(0, 2.5);
}
