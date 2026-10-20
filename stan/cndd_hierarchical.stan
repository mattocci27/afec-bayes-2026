// Three CNDD models: K = varying coefficients, T = columns in group design.
data {
  int<lower=1> N;
  int<lower=2> J;
  array[N] int<lower=1, upper=J> species;
  array[N] int<lower=0> n;
  array[N] int<lower=0> suv;
  vector[N] x;
  vector[J] u;
  int<lower=1, upper=2> K;
  int<lower=1, upper=2> T;
}
parameters {
  // Rows: intercept, density slope. Columns: constant, species trait.
  matrix[2, T] gamma;
  vector<lower=0>[K] tau;
  cholesky_factor_corr[K] L;
  matrix[K, J] z;
}
transformed parameters {
  vector[J] alpha;
  vector[J] beta;
  matrix[K, J] deviation = diag_pre_multiply(tau, L) * z;
  matrix[K, K] Omega = multiply_lower_tri_self_transpose(L);
  for (j in 1:J) {
    alpha[j] = gamma[1, 1] + deviation[1, j];
    beta[j] = gamma[2, 1];
    if (K == 2) beta[j] += deviation[2, j];
    if (T == 2) {
      alpha[j] += gamma[1, 2] * u[j];
      beta[j] += gamma[2, 2] * u[j];
    }
  }
}
model {
  to_vector(gamma) ~ normal(0, 1.5);
  tau ~ normal(0, 0.7);
  L ~ lkj_corr_cholesky(2);
  to_vector(z) ~ std_normal();
  suv ~ binomial_logit(n, alpha[species] + beta[species] .* x);
}
