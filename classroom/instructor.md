---
title: "AFEC-X 2026 Instructor Guide"
lang: en
format:
  html:
    theme: coderpro
    toc: true
    embed-resources: true
---

October 21–23, 19:00–20:30 China time: three 90-minute sessions for approximately
30 participants. The agreed priority is conceptual understanding, interpreting
figures and connecting the material to research, at a depth comparable to
`main.qmd`. Read the data, unknowns, assumptions and results alongside supplied
Stan code. Editing or implementing models is optional.

According to the October 15 timetable, October 20, 17:10–18:00 is reserved for
statistics preparation and checking R. Daytime sessions on October 21–26
(09:00–12:00 and 14:00–18:00) cover experimental design and statistics in R.
This course occupies the evenings of the first three days. The content of each
daytime session is unknown; do not assume experience running R or knowledge of
GLMs. Allow for fatigue after seven hours of practical work.

The learning goals are Bayesian reasoning, ecological interpretation, uncertainty
and a habit of checking models. Planning assumptions are English instruction,
no required homework, one instructor and approximately 30 participants. Use one
short comparison activity per day, with discussion optional. Running supplied
code and reading supplied figures are equally valid ways to participate. R
problems should not prevent participants from addressing the same question.
Confirm the teaching language and computing environment before class.

## Learning outcomes and connections across the three days

| Day | Explanation to check at the end | Core activity |
|---|---|---|
| 1 | Identify prior, likelihood and posterior in figures; explain changes caused by sample size or the prior | Read the seedling update calculation, change sample size and compare figures; 12 minutes |
| 2 | Read a regression table, computational diagnostics, traces and a survival curve; distinguish sampling checks from checking the ecological model | Read, diagnose and plot regression results with standard R functions; 20 minutes |
| 3 | Explain how partial pooling depends on information and differences among groups; identify groups in one's own research | Compare mother-tree estimates; 15 minutes |

Connect a single survival probability to change with density, then to differences
among mother trees and species. The mother-tree activity uses different data
from Day 2 and has no density predictor. Species-level CNDD on Day 3 is a
conceptual illustration. Allometry and wood density introduce a research example
with a different observation model.

## Day 1: 90-minute schedule

Solutions, detailed explanations and Stan/brms demonstrations are collected in
the [Day 1 instructor notes](../day1/instructor-notes.html).

| Elapsed time | Content and instructor prompts | Participant activity |
|---|---|---|
| 0–8 min | Final connection check, research motivation, two survivors among five seedlings | Predict survival probability and uncertainty |
| 8–23 min | Normal figures and the seedling likelihood: hold data fixed and vary the parameter | Describe differences between likelihood curves |
| 23–43 min | Conditional probability, all six fip figures, PCR and Bayes | Predict what changes when reasoning from outcomes to conditions |
| 43–58 min | Priors, posteriors and coin tosses: 3/5 versus 60/100, both with proportion 0.6 and the same strong prior | Identify which posterior moves closer to the data |
| 58–70 min | One activity: 8 minutes of work and 4 minutes of explanation and sharing | Choose small and large surveys with survival proportion 0.4; predict, run and explain their posterior widths; changing the prior is optional |
| 70–80 min | Show the same seedling posterior as a histogram of supplied draws, with a mean and 95% interval | Recognize draws as values of survival probability p; connect distribution location and width to the summaries |
| 80–85 min | Day 1 recap and connection to Day 2 | Review the posterior and uncertainty; preview the density-dependence question |
| 85–90 min | Questions and buffer | Ask questions and reflect |

Day 1 uses lightweight direct calculations; Days 2–3 can use supplied draws.
The figures alone provide a route through the same questions on every day.
If R is difficult on Day 1, compare 4/10 and 20/50 in the result sheet.
Share a few participants' results immediately after the activity. Follow with
the two short demonstrations of posterior draws and proceed directly to the
recap. Do not add a demonstration title slide or a separate return-to-exercise
debrief.

The coin slides illustrate the influence of a strong prior. The activity holds
a uniform prior fixed while participants read each update step and change the
numbers. Four minutes into the activity, check that participants have chosen
small and large surveys, that both proportions are 0.4, and that they have
predicted the widths. If plots do not appear, use `day1/results.html`.
Lecture figures show continuous densities; activity figures show probability
at grid points. Briefly say, “Compare widths, not heights.” Before class, test
copying the code to a new chunk and displaying both plots in a participant copy.

The 15-minute likelihood segment includes about three minutes comparing Normal
means of 0 and 2. Hold the three observations and SD=1 fixed, ask for a
prediction, compare sums of `dnorm(..., log=TRUE)`, then show the likelihood
curve. Running this code is optional; the single practical comparison activity
remains at 58–70 minutes.

Distinguish posterior mean, MAP and MLE. Briefly identify the posterior peak as
the MAP without requiring calculations. Beta(51,51) is deliberately strong and
still influences the posterior after 100 observations. PCR proportions are
hypothetical teaching values.

**If running late:** shorten the draw demonstration and explain the mean and
interval verbally. Preserve the activity explanation and questions. Keep only
two demonstration slides in the main sequence. Stan code, chain/iteration
tables, posterior probability calculations, MLE differentiation, derivation of
the Beta update, and MH/HMC are optional reference material.

## Day 2: Linear regression and MCMC — 90-minute schedule

| Elapsed time | Content and instructor prompts | Participant activity |
|---|---|---|
| 0–10 min | From Day 1 to CNDD: “What happens to survival at higher density?” | Predict the direction of the relationship |
| 10–25 min | The same binomial model, logit and probability curves, and prior scale | Identify observations, unknown coefficients, priors and likelihood |
| 25–40 min | Approximate the posterior by simulation; healthy and failed traces; from paired draws to curves and a ribbon | Explain how one coefficient pair produces one curve |
| 40–60 min | Explain R code in the style of the root exercise.qmd | Follow code and output: coefficient table, diagnostics, traces and regression plot |
| 60–70 min | Questions about the walkthrough and buffer for different working speeds | Revisit code and interpretation as needed; add no new lecture content |
| 70–90 min | Brief preview of tomorrow, questions and buffer | Ask about the walkthrough; no additional “Your research question” task |

As in the root `exercise.qmd`, guide participants through code and output in
order. Do not add student-facing time limits, Questions sections, response
blanks, separate assignments or an answer-checking session. Show processing
with standard functions rather than `source()` or course-specific plot helpers.
`read_csv()` and `readRDS()` load data and supplied results; `summarise_draws()`
shows means, SDs, 95% credible intervals, R-hat and bulk/tail ESS. The supplied
result file is a list of draws and diagnostics, not an object on which to call
CmdStan's `$summary()` or brms's `summary()` directly. The instructor should
understand this distinction; students need not memorize the object formats.

Explain the coefficient table in this order: rows (alpha and beta), mean, SD,
interval. The mean is a posterior mean, not an MLE or MAP. SD describes posterior
uncertainty, not Monte Carlo error. Beta is a coefficient on the logit scale,
not a probability or a percentage reduction. Interpret its sign provisionally,
then check diagnostics and traces before using the estimates. Connect that sign
to the direction of the final regression curve.

Use `mcmc_trace()` to inspect four chains for overlap, persistent separation and
drift. Read R-hat, ESS and divergence counts together. For four chains,
R-hat >1.01 or ESS <400 are reasons to investigate, not automatic classifications
or thresholds to memorize. The instructor should also inspect treedepth,
E-BFMI, lp__ and Monte Carlo precision for the quantities of interest. Do not
carry over the root handout's three-level E-BFMI rating or classifications based
on a single diagnostic.

For the regression plot, apply `plogis(alpha + beta * cons)` to every paired
draw. At each density, calculate the median and 2.5th/97.5th percentiles; draw
these with `geom_ribbon()`, `geom_line()` and `geom_point()`. Do not summarize
coefficients separately before transforming. The `alpha` argument controlling
plot transparency is different from the regression intercept alpha; changing
transparency changes neither estimates nor intervals. Connect the calculation
to the lecture progression from 10 grey curves to 1,000 curves to a ribbon
using all draws. Distinguish these from the conceptual species-coloured curves.

New inference and Stan editing are optional. If an R problem cannot be resolved
within two minutes, continue with the same tables, diagnostics and plots in
`day2/results.html`. Both fitting sections, brms and Stan, appear before Data
and posterior draws in the student handout. Demonstrate either fit if the
prepared environment and class pace permit. Run only one of the brms, Stan or
prepared-result loading chunks; all later tables, diagnostics, traces and plots
then use that result. Do not use stored diagnostics to assess a new fit.
Fitting chunks have `eval=FALSE`, so rendering the HTML does not run inference.
Do not require students to install CmdStan, a C++ toolchain or Docker.

Explain tables, traces and the regression plot alongside their code in the
handout. Repeated slides are optional reference; do not return for a separate
answer-checking session. The two PPC slides and predictions for 20 new seedlings
are optional, outside the main sequence. “Interpretation in a real forest” has
been removed; do not add a separate general ecology lecture. Retain only the
sentence explaining that sampling diagnostics check computation and do not
establish ecological model appropriateness. The PPC example is instructor
reference, not a required learning outcome.

“Your research question” has also been removed; do not retain the same extra
assignment in the handout. The species-difference illustration is a brief
preview of tomorrow, without new inference or equations. Twenty minutes is an
instructor planning allowance, not text for the student handout. Use remaining
time for questions and differences in working speed rather than extra content.

**If running late:** shorten the species preview and details of MCMC mechanics.
Preserve reading the coefficient table, diagnostics, traces and regression plot.

## Day 3: Hierarchical models — 90-minute schedule

| Elapsed time | Content and instructor prompts | Participant activity |
|---|---|---|
| 0–10 min | Revisit the survival curve, introduce separate mother-tree data and calculate overall survival | Consider what the pooled proportion 0.284 hides across eight mother trees |
| 10–25 min | Read mother-tree proportions from 0.19 to 0.50; introduce assumptions of one shared probability or fully separate probabilities | Distinguish real differences from sampling variation and consider sharing information |
| 25–40 min | Hierarchical priors and between-group SD; Stan code is optional reference | See shared information and group differences in figures |
| 40–55 min | One activity: 10 minutes of work and 5 minutes of explanation | Predict which mother-tree estimates will move and compare three estimation plots |
| 55–70 min | Species-level CNDD connection, 10 minutes; wood-density/allometry research example, 5 minutes | Read the individual-level and group-level questions |
| 70–80 min | Computational and mother-tree predictive checks; assumptions of similarity | Consider whether these groups can reasonably share information |
| 80–85 min | Connect the three days to participants' research | Identify one grouping structure and a difference of interest |
| 85–90 min | Questions and buffer | Ask questions and reflect |

Use the concrete introduction in `main.qmd`: overall proportion, mother-tree
proportions, then how much information to share. Do not insert the 0/2 and 2/2
questions, which are absent from the actual table. Introductory proportions are
MLEs, distinct from posterior means shown after the activity. Compare with true
values only in a short explanation after the activity; omit this if time is
short. The displayed true values are generating probabilities rounded to two
decimal places.

Five minutes into the activity, check the two mother trees participants chose
and their reasons. Points in the three plots are posterior means; intervals are
95%. Complete and separate models use Beta(1,1) priors on p, while partial
pooling uses a hierarchical Normal distribution on logit(p). Explain that this
comparison changes more than pooling alone under identical marginal priors.
The existing `stan/logistic.stan` uses Normal(0,5) for mu and half-Normal(0,1)
for sigma. Distinguish SD from variance. Do not claim all estimates move by the
same fraction toward overall observed survival, intervals always narrow, or
every mother tree improves. True values are known because the data are simulated;
they are unavailable for real observations.

Species-level CNDD is a conceptual simulation with the same seed as `main.qmd`,
not species-level inference from Day 2. The wood-density figure uses the existing
`day3_vslope` fit to simulated data. Distinguish research motivation, conceptual
figures and teaching-data estimates. `mv_logistic.stan` is incomplete reference
code that cannot compile; do not run it in class.

**If running late:** shorten research-model code and move allometry to the
supplied figures. Preserve the mother-tree explanation and connection to CNDD.
Predictions for new mother trees, Cholesky/LKJ and details of non-centering are
optional.

## Preparation, support and distribution

Several days before class, use `readiness.html` for a ten-minute check. Do not
require participants to install CmdStan, a C++ toolchain or Docker. Required
activities use lightweight calculations or supplied results and can also be
completed by reading figures. The student package guide is
[PACKAGES.md](PACKAGES.md). Separate basic local R packages from the optional
brms fitting environment; do not assign compilation or sampling as preparation.
Test basic plotting and loading supplied fits in a fresh participant account.
If demonstrating new brms or Stan inference, check compilation, sampling,
diagnostics, plotting and runtime in the instructor environment, and prepare
results in advance. Distinguish new inference from predictive simulation using
existing draws. The current plan has no required homework.

If connection or R problems cannot be resolved within two minutes, use local
`exercise-student.html` and `results.html` to continue with the same question.
Ask for predictions before showing results. Instructor solutions belong only
in `exercise.qmd/html`; solution code and prose are physically removed from
participant QMD files.

Run `Rscript R/build_classroom_materials.R` in the instructor environment to
build slides, instructor and participant handouts, result sheets, the readiness
check and this guide without refitting models. Distribute
`dist/afec-classroom-materials.zip` before class and check extraction and offline
viewing. Earlier detailed activities are retained in
`archive/teaching-before-cndd/`, outside current required work.

Check supplied fits against current seeded data and model names. Original fit
files lack the Stan source hash from generation, so exact identity between the
original and current source cannot be proved. If changing a model or its data,
refit, diagnose and update figures on the instructor side rather than reusing
a default fit.

Keep local instructor validation separate from acceptance testing in a fresh
classroom participant account. Venue connectivity, browser RStudio, load for
30 participants, a full rehearsal and measured pacing require classroom testing.
Live inference is optional; if used, measure server capacity and adjust the
session accordingly. Editing source does not update existing Docker images or
participant volumes. Extract the new ZIP into a new materials directory; plan
image updates and migration of existing participant work separately.
