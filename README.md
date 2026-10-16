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
participants. The agreed plan prioritises Bayesian thinking, figure interpretation
and connections to ecological research at the level of `main.qmd`. Participants run
complete supplied R code, with one core exercise per day. Stan editing is optional.
The design assumes English, some R execution experience, daytime GLM practice,
15 pairs and no homework. Confirm the remaining assumptions and browser setup with
the organisers. See [the agreed design](classroom/restructure-proposal.md) and
[the instructor schedule](classroom/instructor.md).

The 2025 workshop materials (`main.qmd`, `exercise.qmd`) are kept unchanged as source material.
The restructured course lives in:

| | Slides | Exercises | Theme |
|---|---|---|---|
| Day 1 | `day1/slides.qmd` | `day1/exercise.qmd` | Bayesian foundations through familiar examples and a prior/data figure comparison |
| Day 2 | `day2/slides.qmd` | `day2/exercise.qmd` | CNDD: survival probabilities, prediction and model checking |
| Day 3 | `day3/slides.qmd` | `day3/exercise.qmd` | Mother-tree partial pooling and instructor demonstrations of ecological applications |

Shared resources:

- `stan/`: Stan models (new for 2026: `binomial.stan`, `linear.stan`, `linear_bad.stan`, `logit_reg.stan`)
- `R/course_data.R`: seeded simulated data; `R/course_utils.R`: stored-fit helpers;
  `R/course_visuals.R`: shared figures and strict data/model matching; `R/slides_setup.R`: slide setup
- `R/precompute_fits.R`: fits every course model once and stores the results in `fits/`
- `fits/`: seven stored posterior draw/diagnostic files. Core exercises explicitly
  load the matching fit; changing inputs requires new inference.
- `dayN/results.qmd`: tables, diagnostic figures and predictions for offline discussion.
- `classroom/readiness.qmd`: 10-minute pre-course browser/R/plotting/offline check.
- `R/build_classroom_materials.R`: generates solution-free participant QMDs,
  instructor/participant HTML, result sheets, instructor schedule, data exports and a participant ZIP.
- `archive/teaching-before-cndd/`: earlier detailed teaching sources, preserved for instructor reference and excluded from the participant ZIP.

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

### Direct Quarto renders

From this project directory, `make day1`, `make day2`, or `make day3` renders
the day's slides and instructor exercise to `dayN/slides.html` and
`dayN/exercise.html`. `make slides` renders all three slide decks, and `make`
(or `make help`) lists the targets. From another directory, you can use
`make -C` with the project path, for example `make -C /path/to/afec-bayes-2026 day1`.

These renders execute the chunks needed for figures and summaries. The slides
read their saved fits from `fits/`; core exercise inference tasks load supplied
fits, while other core chunks do summaries or lightweight simulation. Optional
changed-input Stan chunks remain disabled. These Make targets never
run `R/precompute_fits.R` and do not build the solution-free classroom package
(the separate `R/build_classroom_materials.R` workflow above does that).

Participants open `exercise-student.qmd` and run the indicated completed chunks.
Solutions are physically removed from this source. `exercise.qmd`/`exercise.html`
are instructor versions. Distribute the ZIP before class and have students check
exercise/result HTMLs offline. The ZIP includes the shared figure code, all seven
fits and seeded CSV/RDS data; cloning alone does not supply gitignored fits.

Core work uses exact updating or supplied posterior draws. CNDD predictions and
checks generate observations from existing draws without refitting. Day 2 holds
the fit fixed while comparing density -1 and +1 SD. Day 3 uses separate mother-tree
data, then connects to species CNDD with conceptual simulations and to wood density
with the existing simulated-allometry fit. Optional calculations are labelled.
Participants do not need to install CmdStan, a C++ toolchain or Docker.

The revised course uses derivatives of the existing theme (`assets/course.scss`
and `assets/course.css`), retaining the palette and slide dimensions while avoiding
remote font imports. Slides use local KaTeX and figure resources in `slides_files/`, preserving the
chalkboard plugin. Exercise and result HTMLs embed their resources for offline use.
The original `main.qmd` theme remains the source reference.

The draft was validated with R 4.5.3, CmdStan 2.38.0, cmdstanr, posterior, bayesplot 1.15.0, ggplot2 4.0.3 and Quarto 1.9.37 in the `mattocci/cmdstan-zsh:4.5.3` container (see `fits/sessionInfo.txt`).

## Optional local R environment

The full project library and `renv.lock` are synchronized for macOS arm64 with
R 4.6.1 and renv 1.3.0. All packages from the earlier lockfile are retained, with
dependency versions updated for R 4.6. `devtools` (used by `exercise.qmd`) and its
dependencies are also included. `renv/settings.json` uses snapshot type `all` so
future snapshots retain the complete project library.

The project uses renv's default user cache (on macOS,
`~/Library/Caches/org.R-project.R/R/renv`). Set `RENV_PATHS_CACHE` before starting
R if a custom cache is needed; its directory must be writable by your user.
Restart R after changing cache configuration.

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


### Agreed CNDD course alignment: 2026-10-16

The current slides, exercises, instructor schedule and participant package follow
`classroom/restructure-proposal.md`: one core exercise each day, CNDD on Day 2,
and mother trees followed by research demonstrations on Day 3. The Day 2 prior-scale
introduction uses the familiar Normal-regression illustration from `main.qmd`.

Local validation used R 4.6.1 and Quarto 1.10.19: all 28 runnable participant chunks,
seven stored-fit data/diagnostic checks, a complete render, and a fresh ZIP extraction
passed. The archive has 2,604 checked manifest entries, solution-free participant
sources, and local resources for its rendered pages. Representative slide figures,
equations and code were inspected in the browser and their layout issues corrected.
See [validation details](logs/2026-10-16-cndd-materials-validation.txt).

The local renv startup reports an out-of-sync project. No dependencies were changed
or models refitted. A new classroom image, fresh browser RStudio account and 30-user
load remain separate acceptance work; local package validation does not establish
the classroom server's readiness.
