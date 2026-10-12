[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

# The 8th Advanced Statistics Workshop: Bayesian estimation for ecology

Slides and materials for 2025-06-14 at XTBG.

View the accompanying slides [here](https://forest-canopy.github.io/assets/bayes-workshop-xtbg/main.html)

# References:

- [Gelman, A. et al. Bayesian Data Analysis, Third Edition. (Chapman & Hall/CRC, 2013)](http://www.stat.columbia.edu/~gelman/book/)

- [Stan User's Guide](https://mc-stan.org/docs/stan-users-guide/index.html)

- [Stan Functions Reference](https://mc-stan.org/docs/functions-reference/index.html)

- [AIcia Solid Project](https://youtu.be/mX_NpDD7wwg) (in Japanese and Math)

- [DanyangDai/brownbag_2022_10_11](https://github.com/DanyangDai/brownbag_2022_10_11)

- [emitanaka/talks](https://github.com/emitanaka/talks)


# 2026 course: three 90-minute sessions (draft)

The 2025 workshop materials (`main.qmd`, `exercise.qmd`) are kept unchanged as source material.
The restructured course lives in:

| | Slides | Exercises | Theme |
|---|---|---|---|
| Day 1 | `day1/slides.qmd` | `day1/exercise.qmd` | Bayesian foundations: likelihood, prior, posterior, first Stan model |
| Day 2 | `day2/slides.qmd` | `day2/exercise.qmd` | Regression, prediction, model checking, diagnostics |
| Day 3 | `day3/slides.qmd` | `day3/exercise.qmd` | Hierarchical models and ecological applications |

Shared resources:

- `stan/`: Stan models (new for 2026: `binomial.stan`, `linear.stan`, `linear_bad.stan`, `logit_reg.stan`)
- `R/course_data.R`: simulated data sets (seeded); `R/course_utils.R`: `fit_or_load()` and helpers; `R/slides_setup.R`: setup for the slides
- `R/precompute_fits.R`: fits every course model once and stores the results in `fits/`
- `fits/`: stored posterior draws and diagnostics. The slides read these, and the exercises fall back to them when live sampling fails.

```bash
# 1. (instructor) refit all models; needs cmdstanr + CmdStan
Rscript R/precompute_fits.R

# 2. render
quarto render day1/slides.qmd      # slides do not need CmdStan
quarto render day1/exercise.qmd    # instructor version, solutions in collapsed boxes

# participant version without solutions (render, then rename)
quarto render day1/exercise.qmd -M solutions:false
mv day1/exercise.html day1/exercise-student.html

# skip all sampling and use the stored results
AFEC_USE_PRECOMPUTED=TRUE quarto render day1/exercise.qmd
```

The draft was validated with R 4.5.3, CmdStan 2.38.0, cmdstanr, posterior, bayesplot 1.15.0, ggplot2 4.0.3 and Quarto 1.9.37 in the `mattocci/cmdstan-zsh:4.5.3` container (see `fits/sessionInfo.txt`).

## Optional local R environment

The full project library and `renv.lock` are synchronized for macOS arm64 with
R 4.6.1 and renv 1.3.0. All packages from the earlier lockfile are retained, with
dependency versions updated for R 4.6. `devtools` (used by `exercise.qmd`) and its
dependencies are also included. `renv/settings.json` uses snapshot type `all` so
future snapshots retain the complete project library.

```bash
Rscript -e 'renv::restore(prompt = FALSE); renv::status()'
AFEC_USE_PRECOMPUTED=TRUE quarto render day1/exercise.qmd
```

Validation: `arf` 0.4.4 starts without missing-package or R-version warnings,
`renv::status()` reports a consistent state, and the Day 1 exercise renders with
stored results using Quarto 1.10.18. The cached `fstcore` binary was replaced with
the CRAN macOS binary after an OpenMP loading failure. The Stan package repository
now uses the [officially recommended R-universe URL](https://mc-stan.org/cmdstanr/).

This local check does not refit course models or revalidate the earlier Docker
environment after dependency updates. The container results described above
record the environment originally used to produce the stored fits.

## AFEC 2026 classroom Docker image

The root `Dockerfile` now targets `rocker/tidyverse:4.6.1` on Linux amd64,
with CmdStan 2.38.0 and an offline, isolated workspace per participant.
See [docker/README.md](docker/README.md) for the design, build/start commands,
validation checklist and outstanding risks. This is separate from the legacy
VS Code / Apptainer workflow; no Compose configuration is provided yet.
The image has **not been built or run** during this change, as requested.
