# 2026-10-02 handoff: restructuring into three 90-minute sessions

## Goal

Reorganize the 2025 workshop materials (`main.qmd`, `exercise.qmd`) into a
three-session course (90 min x 3) for about 30 participants working in a
preconfigured browser-based R environment. First draft of
`day{1,2,3}/slides.qmd` and `day{1,2,3}/exercise.qmd`. Priority order for
this pass: course structure, pedagogical progression, exercises,
computational feasibility, then visual polish.

## Current state

- All six files exist and render. `main.qmd`, `exercise.qmd`, `setup.Rmd`,
  and `_targets.R` are unchanged.
- Exercises render both with live sampling and with stored results only
  (`AFEC_USE_PRECOMPUTED=TRUE`); the participant version (`-M
  solutions:false`) hides all solutions.
- Numbers quoted in the solutions were checked against the rendered output.
- Slides were checked for overflow with headless-Chrome screenshots of every
  slide and fixed. Visual design is otherwise untouched.
- Nothing is committed. All new files are untracked; only `README.md` is a
  modified tracked file.

## Course arc

| | Day 1 | Day 2 | Day 3 |
| --- | --- | --- | --- |
| Theme | From likelihood to posterior | Regression and model checking | Hierarchical models |
| Models | `binomial.stan` | `linear.stan`, `logit_reg.stan`, `linear_bad.stan` | `logistic.stan`, `vint.stan`, `vslope.stan` |
| Exercises | 1A prior x likelihood in R (12 min); 1B first Stan model (15 min) | 2A allometry regression (20 min); 2B diagnose a broken fit + logistic regression (15 min) | 3A eight mother trees, three pooling strategies (20 min); 3B species differences in allometry (20 min) |

Two examples run through all three days: seedling survival (binomial ->
density dependence -> mother trees) and tree allometry (pooled regression on
Day 2 -> species-level models on Day 3). The Day 2 residual-by-species plot
is the bridge into Day 3.

Each `slides.qmd` starts with a comment block giving learning outcomes, a
minute-by-minute plan, and what to cut if time runs short.

## Decisions already made

- **Hierarchical motivation on Day 1 (instructor request, same day).** Two
  slides right after the course map: the Comita cover/quote and the NDD
  verbal-model slide from `main.qmd`. Question only, no model code and no
  mother-tree table, so Day 3's predict-first exercise is not spoiled.
  "Today's question" became "the smallest version" and states the staircase
  Day 1 -> 2 -> 3. Day 2's Comita slide became a short callback; Day 3's
  allometry and "Looking ahead" slides say explicitly that allometry is the
  same structure as the NDD question.
- **Priors passed as data** (`a`, `b` in `binomial.stan`; `beta_sd` in
  `linear.stan`) so participants change priors without recompiling.
  Compilation, not sampling, is the bottleneck with 30 people.
- **`fit_or_load()`** (`R/course_utils.R`) wraps cmdstanr, falls back to
  `fits/<name>.rds` when sampling fails, and warns when the supplied data
  differ from the data of the stored fit. Defaults: 4 chains x 1000 draws,
  `parallel_chains = 1`.
- **Slides never run Stan.** They read `fits/*.rds`, produced by
  `R/precompute_fits.R`.
- **Posterior predictions are simulated in R from the draws**, not in
  `generated quantities`, to keep the Stan files minimal and the step
  visible.
- **New simulated data** in `R/course_data.R` with fixed seeds. Allometry:
  10 species with 3 to 40 trees, DBH centred at 40 cm, seed 5 (chosen so the
  wood-density effect on the exponent is clear while the effect on the
  intercept stays uncertain). NDD quadrats: seed 11. Mother trees: the
  existing `generate_dummy_simple(n_sp = 8, sig = 0.2, seed = 500)`.
- **brms is optional and `eval=FALSE` everywhere.** It was not available in
  the validation environment and compiles on every call.
- **Solutions** live in `::: {.content-visible when-meta="solutions"}`
  blocks; one source gives instructor and participant versions.
- Removed from the core: Gibbs sampling, the basic probability slide. Moved
  to appendices: HMC mechanics, MCMC comparison table, Stan interfaces, eight
  schools, spatial autocorrelation, Poisson, brms versions.

## Findings in the existing materials

Corrected in the new materials; the original files are untouched.

- `exercise.qmd`: the group-level predictor matrix `u` is all ones, so wood
  density never enters the model. Fixed in `vslope_stan_data()`.
- `main.qmd` states priors N(0, 2.5) and Half-Cauchy(0, 1) for the partial
  pooling model; `stan/logistic.stan` uses N(0, 5) and Half-N(0, 1). The Day
  3 slides follow the code.
- "Why scale matters" figure: line drawn with slope 1000, labelled 100.
  Sigma figure: title says 10, value is 3.
- `stan/mv_logistic.stan` does not compile (generated quantities refers to
  undeclared `phi`, `xi`, `psi`). Used for display only.
- Mother-tree data: RMSE against the truth is 0.098 (no pooling), 0.057
  (partial pooling), 0.050 (complete pooling). Partial pooling clearly beats
  separate estimates but not complete pooling, because the true variation
  among trees is small. Exercise 3A discusses this directly.
- `lme4::lmer()` on the new allometry data gives a singular fit (correlation
  exactly 1) with a wood-density effect close to the Stan estimate. The Day 3
  tools slide says so.
- `CLAUDE.md` contains `@AGNETS.md` (typo). `.gitignore` leaves `Dockerfile`
  and `LICENSE` untracked.

## Files

New:

- `day1/`, `day2/`, `day3/`: `slides.qmd`, `exercise.qmd` (plus rendered
  HTML)
- `stan/binomial.stan`, `stan/linear.stan`, `stan/linear_bad.stan`
  (deliberately non-identified, diagnostics exercise only),
  `stan/logit_reg.stan`
- `R/course_data.R`, `R/course_utils.R`, `R/slides_setup.R`,
  `R/precompute_fits.R`
- `fits/*.rds` (7 fits, 3.6 MB) and `fits/sessionInfo.txt`
- `.here` (empty; project-root marker for `here::here()`)

Modified: `README.md` (new section on the 2026 structure and commands).

Side effect: the git-ignored binary `stan/logistic` (x86-64) was rebuilt as
aarch64 Linux during validation.

## Validation environment

Host R lacks the needed packages and the renv library is not restored.
Validation used a throwaway container from `mattocci/cmdstan-zsh:4.5.3`
(R 4.5.3, CmdStan 2.38.0, Quarto 1.9.37) with a library of symlinks into the
`~/renv` cache passed as `R_LIBS`. brms, ggforce, gganimate, entropart, and
tidybayes are not in that cache; the new materials do not need them.

Measured in that container (10 cores): all seven models compile and sample
in about 45 s; sampling alone is about 1 s per model, 7 s for `vslope`.

```bash
Rscript R/precompute_fits.R
quarto render day1/slides.qmd
quarto render day1/exercise.qmd
quarto render day1/exercise.qmd -M solutions:false   # then rename the output
```

`-o exercise-student.html` breaks `embed-resources` in Quarto 1.9; render and
rename instead.

## Do not redo

- The content allocation and the hierarchical-motivation placement are
  settled.
- Do not rerun `R/precompute_fits.R` unless a Stan file, a data function, or
  the sampling defaults change. If it is rerun, re-check the numbers written
  into the exercise solutions.
- Do not change the data seeds without re-checking the solution text.

## Unresolved

- Whether 90 minutes is enough for each day is untested. Day 1 gained about
  3 minutes from the new motivation slides.
- Day 1 promises the multi-species NDD question; Day 3 practises the same
  structure on allometry and only shows the NDD model. A multi-species NDD
  data set and exercise would close the loop but is more work.
- Participant environment: not built. Needs precompiled executables and a
  load test with 30 simultaneous users.
- brms code is unrun. Decide whether brms is taught at all.
- No example of a fit that actually diverges (TODO in Day 3).
- Assumptions still to confirm with the organisers: prior knowledge,
  English, no Stan writing from scratch, no homework.
- 14 `TODO` comments in the six files: title-slide dates and course name,
  repository URL, the McMahon 1973 reference details, small code font on the
  Stan slides, others.

## Best next action

Talk through Day 1 with a timer. It carries the most lecture material and
the new motivation slides, so it shows first whether the plan fits in 90
minutes and what has to move to the appendix.
