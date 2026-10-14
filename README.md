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

AFEC-X 2026: **21–23 October, 19:00–20:30 China time (UTC+8)**, about 30
participants. The plan assumes R/tidyverse and `lm()`/`glm()` experience,
English, supplied Stan code, 15 pairs and no homework. Confirm these assumptions
with the organisers. Core tasks analyse supplied fits; live inference is an
instructor-coordinated extension. Each 90-minute plan includes debriefs,
questions and a delay buffer. See [classroom/instructor.md](classroom/instructor.md).

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
- `fits/`: seven stored posterior draw/diagnostic files. Core exercises explicitly
  load the matching fit; changing inputs requires new inference.
- `dayN/results.qmd`: tables, diagnostic figures and predictions for offline discussion.
- `classroom/readiness.qmd`: 10-minute pre-course browser/R/plotting/offline check.
- `R/build_classroom_materials.R`: generates solution-free participant QMDs,
  instructor/participant HTML, result sheets, data exports and a participant ZIP.

```bash
# Only after model/data/sampling changes: refit all models in instructor environment.
# Do not refit merely to rebuild handouts.
Rscript R/precompute_fits.R

# Normal build: use existing fits; no CmdStan compilation/sampling.
Rscript R/build_classroom_materials.R
# Output: dayN/exercise-student.qmd and .html, dayN/results.html,
# classroom/readiness.html, data/, dist/afec-classroom-materials.zip.
# Resume packaging after a successful render (rejects missing/stale HTML):
Rscript R/build_classroom_materials.R --package-only
# Verify filled participant tasks and stored-fit diagnostics without new inference:
Rscript R/check_classroom_materials.R
```

Participants open `exercise-student.qmd` and run indicated chunks. Solutions
are physically removed from this source. `exercise.qmd`/`exercise.html` are
instructor versions. Distribute the ZIP through your existing course channel
before class and have students check exercise/result HTMLs offline. The ZIP
includes all seven fits and seeded CSV/RDS data; cloning alone does not supply
gitignored fits. Optional changed-input Stan chunks are `eval=FALSE`, with
explicit live flags. Day 1 has an exact Beta alternative; Days 2/3 label their
historical approximate comparisons and do not supply changed-input draws.

The draft was validated with R 4.5.3, CmdStan 2.38.0, cmdstanr, posterior, bayesplot 1.15.0, ggplot2 4.0.3 and Quarto 1.9.37 in the `mattocci/cmdstan-zsh:4.5.3` container (see `fits/sessionInfo.txt`).

## Optional local R environment

The full project library and `renv.lock` are synchronized for macOS arm64 with
R 4.6.1 and renv 1.3.0. All packages from the earlier lockfile are retained, with
dependency versions updated for R 4.6. `devtools` (used by `exercise.qmd`) and its
dependencies are also included. `renv/settings.json` uses snapshot type `all` so
future snapshots retain the complete project library.

```bash
Rscript -e 'renv::restore(prompt = FALSE); renv::status()'
Rscript R/build_classroom_materials.R
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
validation checklist and outstanding risks. `docker-compose.yml` defines
`student01`–`student30` with separate passwords, workspaces and host ports.
Use `bash docker/create-student-env.sh` to prepare private runtime credentials;
see the Docker README before starting services. This is separate from the legacy
VS Code / Apptainer workflow.
The image was built and validated on Linux amd64 on 2026-10-12 after the seven
required fits were supplied. Non-root package/model checks, short sampling,
plotting, the RStudio sign-in endpoint, and workspace persistence across restart
and recreation passed. Browser login and visual inspection remain unverified.
See [docker/README.md](docker/README.md) for image details and execution logs.

The 2026-10-12 built image predates the revised teaching materials. A future
image build includes the new handouts. Existing student volumes are not
automatically overwritten: extract the revised ZIP to a new course directory,
or deliberately migrate backed-up workspaces. Editing materials does not
redeploy the server, enable HTTPS or validate 30-user load.

The revised handouts were generated and checked locally on 2026-10-13:
44 runnable/filled exercise chunks, seven fit/data/diagnostic checks, and a
fresh participant ZIP extraction passed. Full browser layout and the revised
Docker image remain unverified. See [validation record](logs/2026-10-13-classroom-materials.md).
