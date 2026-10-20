# R packages

For the night sessions on October 21–23, 2026.
Created by Masatoshi Katabuchi.

```r
install.packages(c(
  "tidyverse", "posterior", "bayesplot", "patchwork",
  "here", "knitr", "rmarkdown", "kableExtra", "brms"
))

install.packages(
  "cmdstanr",
  repos=c("https://stan-dev.r-universe.dev", "https://cloud.r-project.org")
)
```

## Only for fitting new models locally

We may use precomputed model results during the sessions.
To fit the models yourself, prepare the following tools beforehand:

- **Windows:** install [Rtools](https://cran.r-project.org/bin/windows/Rtools/)
  matching your R version, then restart RStudio. Keep the project and CmdStan
  in folders without spaces; OneDrive paths can cause compilation problems.
- **Mac:** install Xcode Command Line Tools if missing by running
  `xcode-select --install` in **Terminal**, not R. Use the
  [R installer](https://cran.r-project.org/bin/macosx/) for your Mac:
  arm64 for Apple Silicon, x86_64 for Intel.

Then run in **R** on either system (install CmdStan once):

```r
cmdstanr::check_cmdstan_toolchain()
cmdstanr::install_cmdstan(cores=2)
```

See the [CmdStanR setup instructions](https://mc-stan.org/cmdstanr/articles/cmdstanr.html#installing-cmdstan).

To render `.qmd` files, also install [Quarto](https://quarto.org/docs/get-started/).
