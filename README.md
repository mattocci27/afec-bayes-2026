# AFEC-X 2026: Bayesian Statistics for Ecology

**Masatoshi Katabuchi · XTBG, CAS**\
**21–23 October 2026 · 19:00–20:30 China time (UTC+8)**

Three 90-minute sessions for ecology graduate students and researchers beginning
Bayesian statistics. The aim is to understand Bayesian thinking, interpret
uncertainty and build a foundation for further learning.

## Course materials

**Website:** <https://mattocci27.github.io/afec-bayes-2026/>\
**Participant download:** [All materials, code, data and prepared results (ZIP)](https://mattocci27.github.io/afec-bayes-2026/downloads/afec-classroom-materials.zip)

| Session | Topic | Source materials |
|---|---|---|
| Day 1 | Prior, likelihood and posterior; sample size and uncertainty | [day1/](day1/) |
| Day 2 | Regression, MCMC, survival predictions and model checking | [day2/](day2/) |
| Day 3 | Hierarchical models and partial pooling | [day3/](day3/) |

Core and optional content are labelled. Each day uses an ecological example and
one core exercise. Read the supplied figures or run the supplied R code;
independent R or Stan programming is not required.

Download and extract the participant ZIP for offline use. Open
`dayN/slides.html`, `dayN/exercise-student.html` or `dayN/results.html` in a browser.
The ZIP includes the prepared posterior draws; cloning this repository does not.

For the first session, distribute a Day 1-only package while later materials are
still being revised:

```bash
make day1-zip
```

This creates `dist/afec-day1-materials.zip`, with a `START-HERE.html` entry page,
Day 1 slides and their resources, the participant exercise (HTML/QMD/R), and
prepared results. Extract the complete ZIP anywhere and keep its folder structure.
HTML viewing does not depend on R's working directory. Slide math assets are
bundled for offline reading; building the package first downloads a pinned KaTeX
release from npm into `dist/.cache/`. Day 1's exercise R code needs only tidyverse
and reads no project files. Days 2–3 and instructor-only documents are excluded.

**Setup:** [Readiness check](classroom/readiness.qmd) ·
[R packages and optional local fitting](classroom/PACKAGES.md)

Use the prepared R environment during class. Installing CmdStan, a C++ toolchain
or Docker on participants' computers is not required.

## Working with this repository

- Edit `dayN/slides.qmd` and `dayN/exercise.qmd`; the latter is the instructor source.
  Participant sources are generated with solutions removed.
- Shared R code is in `R/`, Stan models in `stan/`, and saved draws in `fits/`.
- [Instructor guide](classroom/instructor.md) ·
  [Course design](classroom/restructure-proposal.md) ·
  [Classroom Docker environment](docker/README.md) · [Work logs](logs/)

```bash
make day1       # Render one day's materials using existing fits (or day2 / day3).
make materials  # Render all days and refresh dist/afec-classroom-materials.zip.
python3 scripts/build_pages.py --output /path/to/empty-directory
```

Publish the staged website to the `gh-pages` branch. Website staging uses existing
HTML and the participant ZIP. Daily builds do not refresh that ZIP. Model refitting
is only needed when the model, data or sampling settings change; see
`R/precompute_fits.R`. `_targets.R` is reserved for legacy animation generation.

## References and licence

- [Bayesian Data Analysis, third edition](https://www.stat.columbia.edu/~gelman/book/)
- [Stan User's Guide](https://mc-stan.org/docs/stan-users-guide/index.html)
- Earlier workshop sources are retained in `main.qmd`, `exercise.qmd` and
  `archive/teaching-before-cndd/`.

[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
Third-party materials retain their original attribution and licence.
