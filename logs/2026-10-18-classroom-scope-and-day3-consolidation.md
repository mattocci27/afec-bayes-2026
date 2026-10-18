# 2026-10-18 handoff: classroom scope and Day 3 consolidation

Follows `2026-10-18-day3-layout-and-group-priors.md`.
This log supersedes its separate slides 11–12, display fraction on slide 6,
and outstanding ZIP update. Earlier logs are retained.

## Goal

Make the three evening sessions realistic for participants starting the daytime
R/statistics workshop, provide a student-readable package guide, and improve
Day 3's wording and diagrams without refitting models.

## Findings and agreed teaching scope

- Reviewed page 4 of `1 AFEC-X 2026_schedule 261015.pdf`. The schedule lists
  statistics preparation/R debugging on **20 October, 17:10–18:00**;
  daytime R/statistics on **21–26 October, 09:00–12:00 and 14:00–18:00**;
  Bayesian sessions on **21–23 October, 19:00–20:30**.
- Bayesian teaching therefore starts on the first day of the daytime workshop,
  after seven teaching hours. The PDF does not specify its daily syllabus or
  establish participants' prior R skills. Do not assume GLM mastery or fluent R use.
- Prioritise Bayesian thinking, ecological interpretation, uncertainty and the
  purpose of model checking. Every core task can be completed with supplied figures;
  running complete R code is an equally valid optional route. No homework.
- Day 1: compare uncertainty for two surveys with the same survival proportion.
  The result-sheet route uses **4/10 and 20/50**; the starter code uses 2/5.
- Day 2: a **15-minute** core task: predict 2 minutes, read/compare 6, write 2,
  debrief 5. Load the matching stored CNDD fit. Prediction/model-check figures
  are instructor-led discussion. Detailed diagnostics are reference material;
  the instructor still checks them fully.
- Day 3: compare mother-tree estimates and explain the use of data from other
  groups, then connect to species-specific regression.
- The initially added mandatory Day 2 brms inference route was removed after
  reading the schedule. Do not restore the 30-minute fitting exercise or its
  `run_inference` flag. The complete brms example is now an **optional**
  `eval=FALSE` chunk, using a separate `brms_result` object. A prepared instructor
  demonstration may take up to three minutes; do not wait for compilation in class.

## Student setup and distribution

- Added English `classroom/PACKAGES.md`. Figure-reading needs no R packages.
  Optional local core-code execution uses **tidyverse, posterior, bayesplot,
  patchwork, here, knitr**; Day 1 code needs tidyverse.
- brms/cmdstanr and CmdStan/C++ setup are separate optional material. Students
  are not required to install these or run inference preflight. Quarto/rmarkdown
  are optional authoring tools. No student renv operation is required.
- `classroom/readiness.qmd` now centres on opening HTML offline; the browser-R
  check is optional. Instructor setup remains separate from student requirements.
- The participant ZIP includes the guide via `R/classroom_materials.R`. Its project
  uses precomputed results and does not activate the instructor repository's renv.

## Final Day 3 slide changes

- **Slide 6:** replaced the display fraction with ordinary text:
  `Survival proportion = survivors / seedlings.` Counts and question are preserved.
- **Slides 8–10:** left/right widths **68%/32%**. Removed fixed image height 340;
  diagrams use full column width with automatic height, preserving aspect ratio.
- Replaced all occurrences of “while sharing information” in the slide source
  with concrete wording about each group's own data and data from other groups.
  Related progression/objectives/questions were aligned. The technical term
  information sharing remains where it is useful and already explained.
- **Old slides 11–12 are now one main slide, number 11**, titled
  **“How much can mother trees differ?”**, with **65%/35%** columns:
  - Left: three existing illustrative curve panels for sigma **0.1, 1, 3**.
  - Right: **Half-Normal(0,1)** prior density `2 * dnorm(sigma, 0, 1)`;
    dashed lines and points mark the same three sigma values.
  - Brief text states that sigma describes differences among trees and is
    estimated from data with a prior. It is not fixed at 1.
- The half-Normal/half-Cauchy/wide-half-Normal comparison moved to an **uncounted
  optional reference** slide. The main deck now has **25 counted slides**.
- Preserve the hypothetical labels: left curves have fixed logit centre 0,
  the same standardized group centres, and illustrative within-curve logit SD 0.2.
  They use the Jacobian and peak scaling from the previous pass. They are not
  fitted posteriors, and relative-density areas are not probabilities.
- Actual saved model remains mu ~ Normal(0,5), sigma ~ half-Normal(0,1).
  No data, Stan models, saved fits, or original `main.qmd` were changed here.

## Files changed in this session

- `day1/exercise.qmd`, `day3/exercise.qmd`: figure-reading route and prerequisites.
- `day2/exercise.qmd`: simplified core, instructor checking/prediction discussion,
  optional brms example; `day2/slides.qmd`: aligned prompts/timing.
- `day1/slides.qmd`: corrected prerequisite assumptions in planning notes.
- `day3/slides.qmd`: layout, wording and combined sigma slide with inline prior plot.
  Existing shared plot helpers were reused.
- `classroom/PACKAGES.md`, `classroom/readiness.qmd`, `classroom/instructor.md`,
  `classroom/restructure-proposal.md`, `README.md`, `docker/START-HERE.md`,
  `docker/README.md`, `R/classroom_materials.R`.
- Rebuilt relevant HTML, generated student sources, plot assets and
  `dist/afec-classroom-materials.zip` (many generated files are ignored).
- Earlier uncommitted changes, including shared R helper changes, remain present.
  Do not attribute the entire working-tree diff to this session. A staged change
  in `docker/README.md` was observed and left as-is. No commit or push was made.

## Validation

Environment used: **R 4.6.1**, **Quarto 1.10.19**.

```sh
RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript R/check_classroom_materials.R
RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript R/build_classroom_materials.R
RENV_CONFIG_SANDBOX_ENABLED=FALSE quarto render day3/slides.qmd
RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript R/build_classroom_materials.R --package-only
git diff --check
```

- Full material build and integration check passed after scope simplification:
  three completed core exercises, matching student sources, data/source guards,
  seven saved fits; the intentionally bad fit remains explicitly exempt.
- Later Day 3 changes were rendered and packaged again. New prior code executed
  during rendering; no inference or dependency installation was performed.
- Inspected actual Chrome views for slides 6, 8–10, revised objectives, and the
  final combined slide 11. Removed an overflowing right-column sentence and
  increased the left plot's right margin so the 1.00 tick is visible.
- No connected browser provider was listed, but native Chrome via `cua.getApp`
  worked. **Click Reload** before reviewing revised local HTML: changing only
  its hash can retain the old document and stale images. Direct file opening
  displayed the reviewed final slides successfully in this session.
- Confirmed optional-prior placement and byte equality between ZIP and current
  Day 3 HTML plus both combined-slide figures and the optional-prior figure.
  Earlier packaging validation also checked the guide, generated handouts,
  solution removal and all 2,612 manifest checksums. Final whitespace check passed.

## Remaining work and best next action

1. Walk through Day 3 slide 10 → combined 11 → prediction/exercise on a projector.
   Make the distinction between a sigma value and a prior over sigma explicit;
   keep alternative-prior comparisons out of the core explanation.
2. Validate a fresh participant copy/account for the basic figures and optional
   supplied-code route. Classroom connectivity/capacity remains unverified;
   figure reading is the complete route when R access fails.
3. Optional **Day 2 brms** compilation/sampling is not validated in this session.
   Local brms cache entries were missing, CmdStan was unconfigured and Docker
   unavailable during the environment check. Prepare a result before showing it,
   or omit the optional demonstration. Do not make environment repair a student task.
4. Classroom Docker image was not rebuilt. Updated ZIP/HTML does not establish
   that an existing deployed image/workspace has the latest materials.
5. Some older speaker notes still mention fixed pairs/partners; the current
   teaching policy is individual work with optional nearby discussion. Align those
   operational remnants if editing them next, without rewriting the whole course.

Do not redo the scope reversal, reinstate R/GLM prerequisites, split the sigma
explanation into two mandatory slides, or refit models for these layout changes.
