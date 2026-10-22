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
and a habit of checking models: a foundation for further independent learning.
Use natural questions during the lecture to follow understanding; no additional
written questions, assessment criteria or detailed lesson timetable are required.
Planning assumptions are English instruction,
no required homework, one instructor and approximately 30 participants. Use one
short comparison activity per day, with discussion optional. Running supplied
code and reading supplied figures are equally valid ways to participate. R
problems should not prevent participants from addressing the same question.
Confirm the teaching language and computing environment before class.

## Learning outcomes and connections across the three days

| Day | Explanation to check at the end | Core activity |
|---|---|---|
| 1 | Identify prior, likelihood and posterior in figures; explain changes caused by sample size or the prior | Read the seedling update calculation, change sample size and compare figures |
| 2 | Read a regression table, computational diagnostics, traces and a survival curve; distinguish sampling checks from a predictive check | Read regression results and briefly inspect one supplied PPC figure |
| 3 | Identify information sharing in model code and extend intercept-only survival to regression | Read the mother-tree model after the lecture comparison |

Connect a single survival probability to change with density, then to differences
among mother trees and species. The mother-tree lecture and code-reading activity use different data
from Day 2 and have no density predictor. The lecture's species-level CNDD curves
are conceptual; the handout also supplies a fitted simulated species example.
Allometry introduces a research example with a different observation model.

## Revised pacing and advancing across days

Each session is limited to 90 minutes, including discussion, questions and buffer.
Use the core route below; the complete reference material is not a script to
narrate in full. Code execution and new fitting are optional throughout.

| Day | Core in class | Optional reference |
|---|---|---|
| 1 | Likelihood, Bayes, prior/posterior, the seedling sample-size comparison and posterior interpretation | Extra calculations, changing the prior, Stan code and sampler algorithms |
| 2 | Binomial regression, coefficient interpretation, sampling checks, survival curves and one existing PPC figure | New fitting, repeated tables, sampler details, predictive simulation code and further prediction examples |
| 3 | Mother-tree pooling and model reading, its count check, and the three regression structures including the interaction | A complete second fitted-analysis walkthrough, new fitting, allometry and covariance implementation |

Day 3's essential extension is the three regression structures and why a trait
changes the expected slope. Preserve the interaction explanation. The CNDD
saved-fit coefficient table and two fitted figures can support that explanation;
reading the entire second analysis code is an extension, not a second required
exercise. Use selected figures and model/formula lines. Shorten repeated code
explanation before dropping the regression connection or questions.

### Advance completed teaching blocks, not the daily workload

Complete the day's core and leave room for questions. If the class is ready and
a complete next concept fits, it can be introduced early. Otherwise finish with
discussion. Individual early finishers do not determine the pace for the class.

Record the last completed slide title and any handout section actually discussed.
At the next meeting, retrieve that idea briefly and resume from the recorded
point; do not repeat the completed block in full or keep the recovered time as
another recap. Deck titles and file locations need not match the day taught.
Do not change the model data or require participants to run new inference.

If no advance happens, all three days must still have a viable core route. If a
core block overruns, carry unfinished material forward and use the next day's
shortening choices. An unresolved core question takes priority over advancement;
the second CNDD analysis and existing appendices are the first material to defer.

Record the completed title/section and where to resume, using the actual class pace.

## Day 1: teaching sequence

Solutions, detailed explanations and Stan/brms demonstrations are collected in
the [Day 1 instructor notes](../day1/instructor-notes.html).

| Content and instructor prompts | Participant activity |
|---|---|
| Final connection check, research motivation, two survivors among five seedlings | Predict survival probability and uncertainty |
| Normal figures and the seedling likelihood: hold data fixed and vary the parameter | Describe differences between likelihood curves |
| Conditional probability, all six fip figures and Bayes | Predict what changes when reasoning from outcomes to conditions |
| Priors, posteriors and coin tosses: 3/5 versus 60/100, both with proportion 0.6 and the same strong prior | Identify which posterior moves closer to the data |
| One activity: comparison, explanation and sharing | Compare 2/5 and 20/50; predict, run and explain their posterior widths |
| Day 1 recap and connection to Day 2 | Review the posterior and uncertainty; preview the density-dependence question |
| Questions and buffer | Ask questions and reflect |

Day 1 uses lightweight direct calculations; Days 2–3 can use supplied draws.
The figures alone provide a route through the same questions on every day.
If R is difficult on Day 1, compare 2/5 and 20/50 in the result sheet.
Share a few participants' results immediately after the activity, then proceed
directly to the recap. Posterior draws, their summaries and MCMC belong together
on Day 2; the Day 1 slides end with the recap and references.

The coin slides illustrate the influence of a strong prior. The activity holds
a uniform prior fixed while participants compare the assigned 2/5 and 20/50
surveys. During the activity, check that participants have predicted the widths
and changed only y and N for the second survey. If plots do not appear, use `day1/results.html`.
Lecture figures show continuous densities; activity figures show probability
at grid points. Briefly say, “Compare widths, not heights.” Before class, test
copying the code to a new chunk and displaying both plots in a participant copy.

The likelihood segment compares Normal
means of 0 and 2. Hold the three observations and SD=1 fixed, ask for a
prediction, compare sums of `dnorm(..., log=TRUE)`, then show the likelihood
curve. Running this code is optional; keep the supplied comparison activity.

Distinguish posterior mean, MAP and MLE. Briefly identify the posterior peak as
the MAP without requiring calculations. Beta(51,51) is deliberately strong and
still influences the posterior after 100 observations. PCR proportions are
hypothetical teaching values.

**If running late:** shorten optional R comparisons. Preserve the activity
explanation and questions. No Stan demonstration is required. Stan code, chain/iteration
tables, posterior probability calculations, MLE differentiation, derivation of
the Beta update, and MH/HMC are optional reference material.

## Day 2: Linear regression and MCMC — teaching sequence

| Content and instructor prompts | Participant activity |
|---|---|
| From Day 1 to CNDD: “What happens to survival at higher density?” | Predict the direction of the relationship |
| The same binomial model, logit and probability curves, and prior scale | Identify observations, unknown coefficients, priors and likelihood |
| Approximate the posterior by simulation; healthy and failed traces; from paired draws to curves and a ribbon | Explain how one coefficient pair produces one curve |
| Explain R code in the style of the root exercise.qmd | Follow code and output: traces, numerical diagnostics, coefficient table, survival probabilities and regression plot |
| Briefly show the existing density-pattern PPC figure | Compare observed proportions with replicated data; no additional exercise |
| Questions about the walkthrough and buffer for different working speeds | Revisit code and interpretation as needed |
| Brief preview of tomorrow, questions and buffer | If core understanding is secure and a full block fits, advance the mother-tree introduction using the rule above; no additional worksheet |

As in the root `exercise.qmd`, guide participants through code and output in
order. Do not add student-facing time limits, Questions sections, response
blanks, separate assignments or an answer-checking session. Show processing
with standard functions rather than `source()` or course-specific plot helpers.
`read_csv()` and `readRDS()` load data and supplied results; `summarise_draws()`
shows means, SDs, 95% credible intervals, R-hat and bulk/tail ESS. The supplied
result file is a list of draws and diagnostics, not an object on which to call
CmdStan's `$summary()` or brms's `summary()` directly. The instructor should
understand this distinction; students need not memorize the object formats.

After inspecting traces and numerical diagnostics, explain the coefficient table
in this order: rows (alpha and beta), mean, SD, interval. The mean is a posterior mean, not an MLE or MAP. SD describes posterior
uncertainty, not Monte Carlo error. Beta is a coefficient on the logit scale,
not a probability or a percentage reduction. Connect its sign and credible
interval to the direction and uncertainty of the final regression curve.

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
`day2/results.html`. Both fitting sections, brms and Stan, are in the optional
appendix after the core walkthrough in the student handout. Demonstrate either fit if the
prepared environment and class pace permit. Run only one of the brms, Stan or
prepared-result loading chunks; the core traces, diagnostics, coefficient table
and plots then use that result. Do not use stored diagnostics to assess a new fit.
Fitting chunks have `eval=FALSE`, so rendering the HTML does not run inference.
Do not require students to install CmdStan, a C++ toolchain or Docker.

Explain tables, traces and the regression plot alongside their code in the
handout. Repeated slides are optional reference; do not return for a separate
answer-checking session. After the walkthrough, show only the existing slide
"Does the density pattern look compatible?" as a brief PPC example. Its intervals
describe replicated proportions at the observed densities and seedling counts,
including binomial variation. Agreement does not prove the model correct.
Predictive simulation details and predictions for 20 new seedlings remain optional.
Keep this to reading the figure; no code walkthrough or additional exercise is needed.

“Your research question” has also been removed; do not retain the same extra
assignment in the handout. The species-difference illustration is a brief
preview of tomorrow, without new inference. Resolve questions and differences
in working speed first; advance a complete mother-tree block only when the
conditions above are met.

**If running late:** shorten the species preview and details of MCMC mechanics.
Preserve reading traces, diagnostics, the coefficient table, regression plot and
the single PPC figure.

## Day 3: Hierarchical models

Explain the mother-tree counts, complete pooling, separate estimation and the
shared prior. Keep the three-model and Tree A truth comparisons in the lecture,
then open the handout. Do not ask for predictions of results already displayed.
All comparison summaries use seed 42; use the generated tables rather than
hard-coded observed proportions. The truth plot uses axes 0.2–0.5, with Tree G
outside that window and still available in the full result table.

### Read a complete analysis

Follow the same format as Day 2: ecological model, packages/data, full Stan
program, data list, compilation/sampling, posterior draws, summaries, numerical
diagnostics, traces and posterior predictive checks. The fitting code is visible
but not run when rendering. Participants may read the code or use the prepared
result; no new inference or independent Stan programming is required. Do not
use project-defined helpers without displaying their source.

The full workflow stays in the handout for reuse. In class, focus on the new
shared prior, the likelihood, inverse-logit transformation and interpretation
of prepared summaries. Point out the fitting route without narrating every
argument, and recall diagnostics from Day 2 rather than teaching them again.

The full model has mu ~ Normal(0,5) and sigma ~ HalfNormal(0,1). The pair
`z_tilde ~ std_normal()` / `z = mu + sigma * z_tilde` implements a shared Normal
prior on the tree intercepts. Explain this representation without requiring
funnel geometry or matrix derivations. It is not always more efficient than a
centered parameterization. The shared scale is a between-tree SD on the logit
scale, not the variation in observed counts.

Readers can point to the likelihood, shared prior and inverse-logit probability
transformation. The code transforms each intercept draw before summarizing
probabilities and shows all tree estimates as a table, without repeating the
lecture's comparison plots. Live-result and prepared-result branches supply
their own matching draws and diagnostics; use only one branch.

### Check observations separately from computation

The slide "Can the model reproduce the observed counts?" belongs at the end of
the mother-tree walkthrough, before returning to regression. The handout shows
how to generate counts from posterior p_j at the observed n_j, then construct
the same predictive plot with standard R functions. Its orange intervals are
for replicated counts, not probability credible intervals. The figure does
not diagnose MCMC exploration; read numerical diagnostics and traces separately.
Consider computation, observed patterns and the ecological argument for grouping
together. Agreement in one check does not prove the model adequate.

### Return to regression

Add density with a common slope, allow slopes to vary, then let species abundance
predict the expected slope. Connect each equation to selected Stan lines.
The lecture's species curves are conceptual illustrations. The handout uses one
simulated CNDD data set (12 species, unequal quadrat counts) and three matching
saved fits. Follow the three equations and formulas and explain the interaction.
Use selected fitted curves or the trait–slope figure to support the explanation.
Reading Model 3's coefficient table and the full second analysis is an extension
when pace permits, not a second required exercise. Participants need not write
a model or run new inference.
Full simulation and plotting code is available in folded code blocks. Extra
diagnostics, the regression predictive check and new fitting are optional;
the mother-tree analysis already introduces the model-checking workflow.

The lecture uses abundance; the fitted example uses wood density as an alternative
species-level predictor. Both are u_j in the same hierarchy. In Model 3 the trait
predicts both the intercept and slope means, so substitution gives x + u + x:u.
Slope partial pooling is toward a trait-dependent mean. The saved fits and brms
formulas allow residual intercept–slope correlation; the lecture's short Stan
examples assume conditionally independent group distributions. The optional brms
and lme4 fitting code is not executed in the main workflow.

Allometry/wood density, new-group prediction and covariance/Cholesky/LKJ details
are optional reference. The incomplete mv_logistic.stan is not used. Do not
copy the old allometry group-predictor data verbatim: any implemented predictor
must actually appear in the input data. The preserved root exercise.qmd sections
4–7 supply further examples, not additional required activities.

The lecture comparison uses Beta(1,1) probability priors for complete/separate
models and hierarchical Normal logit priors for partial pooling. Explain that
prior formulations also differ. Sharing does not guarantee improvement for
every tree. There is no required homework or participant toolchain installation.

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
Ask for predictions before showing results where the activity calls for them;
Day 3 instead reads the full analysis code after the lecture results. Instructor solutions belong only
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
