# R packages

```r
install.packages(c(
  "tidyverse", "posterior", "bayesplot", "patchwork",
  "here", "knitr", "brms"
))

install.packages(
  "cmdstanr",
  repos=c("https://stan-dev.r-universe.dev", "https://cloud.r-project.org")
)
```

New model fitting also requires CmdStan and a C++ toolchain;
see the [CmdStanR setup instructions](https://mc-stan.org/cmdstanr/).
