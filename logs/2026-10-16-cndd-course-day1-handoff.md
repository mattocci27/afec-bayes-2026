# 2026-10-16 handoff: agreed CNDD course and Day 1 refinements

Follows `2026-10-15-accessible-course-proposal.md`. The instructor subsequently
approved the redesign; the earlier log's instruction to wait for approval is
superseded. Current HEAD is `56f1b35` (`update slides`).

## Goal and agreed direction

Align slides, exercises, instructor guidance and participant materials for three
90-minute sessions with the accessible approach of `main.qmd`: ecological questions,
figures, interpretation and research connections. Independent Stan implementation
is optional. Teaching materials remain English; instructor guidance is Japanese.

- **Day 1:** retain Normal likelihood, seedlings, fip, PCR and coins. One required
  prior/data comparison exercise, 12 minutes including explanation.
- **Day 2:** CNDD is the main analysis. Introduce prior scale with the familiar
  Normal regression figure from `main.qmd`, about 3 minutes within the existing
  explanation block; return to CNDD and distinguish probability and logit scales.
  One 15-minute probability-comparison exercise. Detailed prior curves are optional.
- **Day 3:** understand partial pooling through mother trees, with one 15-minute
  exercise. Species CNDD and wood density/allometry are instructor demonstrations.
- Core work uses exact updating or supplied fits. Participants do not need to
  install CmdStan, a C++ toolchain or Docker. No required homework is assumed.

## Completed alignment and validation

The agreed course, shared figures, solution-free handouts, result sheets, instructor
schedule and participant ZIP were built. Earlier detailed sources are preserved in
`archive/teaching-before-cndd/`. See `classroom/restructure-proposal.md` and
`logs/2026-10-16-cndd-materials-validation.txt` for the full scope.

Local validation covered 28 runnable participant chunks, seven stored-fit data/model
checks, diagnostics, all course renders and a fresh participant ZIP extraction.
The ZIP's 2,604 manifest entries and local resource dependencies were checked.
Representative slide layouts were reviewed in the browser and corrected. The legacy
bad fit remains outside healthy-fit thresholds and core teaching. These checks
predate the final Day 1 refinements; the affected Day 1 materials were checked again
as described below.

## Latest Day 1 changes

### Objectives

The instructor approved exactly these two outcomes:

- Explain likelihood, prior and posterior using a figure.
- Predict how changing data or the prior changes the posterior.

Removed the objective about matching data/unknowns/assumptions to Stan. Stan/brms
remain a demonstration, rather than a required Day 1 learning outcome.

### Equivalent brms demonstration

Added `The same model in brms` within the existing Stan demonstration in
`day1/exercise.qmd`, with a model-mapping table, complete code and posterior plot.

- Data remain 2 survivors out of 5; prior remains directly `p ~ Beta(1,1)`.
- Use `y | trials(N) ~ 0 + Intercept`, binomial identity link, and a Beta prior on
  class `b` bounded to [0,1]. Thus `b_Intercept` is p. Default logit/Normal priors
  would not reproduce this prior on p.
- All three new chunks are `eval=FALSE`. Optional instructor execution compiles
  and samples a new model. Existing saved Stan draws are explicitly identified
  as a separate fallback, not relabelled as brms output.
- Executed four chains locally: mean 0.42497 versus exact 0.42857; 90% interval
  [0.15858, 0.72127] versus exact [0.15316, 0.72866]. R-hat rounds to 1.00,
  bulk/tail ESS 1,798/2,069, zero divergences, maximum treedepth 3, minimum
  E-BFMI 1.03. R 4.6.1, brms 2.23.0, CmdStan 2.37.0.

Details and reproduction guidance: `logs/2026-10-16-day1-brms-validation.txt`.
No existing course fits or Stan source files were changed.

### Restore the explicit Normal likelihood calculation

Restored `main.qmd`'s three-term `dnorm(..., log=TRUE)` sum in the main slides.
The sequence is now **figure/prediction → compare means 0 and 2 in R → likelihood
curve**. Observations (-1.5, 0, 1.5) and SD=1 stay fixed. Results are hidden until
clicked; the likelihood curve appears afterwards, so it does not reveal the answer
before the prediction.

Executed both calculations: log-likelihoods -5.006816 and -11.006816. Notes explain
independence, density versus probability, and why a larger log-likelihood is better.
The approximately 3-minute pair prediction/comparison stays within the existing
15-minute likelihood block. Code execution is optional; the one required exercise
remains at minutes 58–70. Updated the instructor schedule accordingly.

Rendered the slides and instructor guide; inspected all three changed slide layouts
and fragment reveals in the browser. Refreshed the ZIP and verified its Day 1 HTML
matches the current output. `git diff --check` passed. See
`logs/2026-10-16-day1-likelihood-validation.txt`.

## Current files and build workflow

Uncommitted tracked changes at handoff:

- `day1/slides.qmd`, `day1/slides.html`.
- `day1/exercise.qmd`, `day1/exercise.html`.
- `classroom/instructor.md`, `classroom/instructor.html`.

Also added the two Day 1 validation TXT files and this handoff. Generated participant
QMD/HTML and `dist/afec-classroom-materials.zip` are current but ignored by Git.
`exercise.qmd` is the editable instructor source; `exercise-student.qmd` is generated
with solution sections physically removed. Edit the instructor source and regenerate.
Original `main.qmd` and root `exercise.qmd` remain unchanged.

```bash
# Full rebuild with existing course fits; no course-model inference.
Rscript R/build_classroom_materials.R

# After targeted renders, refresh the package without rerendering every document.
Rscript R/build_classroom_materials.R --package-only
```

Quarto 1.10.19 works locally with normal cache write permissions. Sandbox rendering
could not open its Sass database; approved normal-permission renders succeeded.
The local renv startup reports an out-of-sync project; no dependency restore or
installation was performed. Do not use targets to build the course materials.
No git commit or push was performed by the agent.

## Timing and publication discussions

- Written schedules total 90 minutes per day. Content-based estimates were Day 1
  95–105, Day 2 95–105, Day 3 90–100 minutes; these are not rehearsal measurements.
- Suggested adjustments: Day 1 Stan demo 10→5 minutes; Day 2 results/diagnostics/
  prediction 15→20 and ecological discussion/preview 10→5; Day 3 wood density as
  a 5-minute adjustment slot. **These reallocations have not been implemented.**
- Recommended a public course landing page with slides, participant exercises and
  ZIP links. Suggested publishing from the course repository and linking from the
  main website, avoiding repeated parent-repository updates. Submodules are optional;
  their parent commit reference would need updating for each new course revision.
  No hosting choice was confirmed and no website/deployment configuration was added.

## Remaining work and best next action

1. Rehearse the Day 1 likelihood block and the dense Day 2 results block against
   the 15-minute allocations before adopting timing cuts. Preserve the agreed two
   objectives, intuitive examples and single required exercise each day.
2. Choose the public site URL/hosting workflow, then prepare a landing page and
   publish selected participant materials. Keep the offline ZIP available.
3. Separately accept the classroom environment: fresh browser RStudio accounts,
   connectivity, 30-user capacity and a timed teaching rehearsal. The previously
   built classroom image predates the revised materials; existing participant
   volumes are not updated merely by editing this repository.
4. Confirm remaining organiser assumptions: teaching language, prior R/GLM practice
   and the browser environment. Current English/no-homework choices are assumptions.

Do not redo the broad course rewrite, restore the removed Stan objective, add
required implementation work, or refit the seven course models merely to rebuild
these materials. Saved fits lack generation-time Stan source digests; data/model
matching alone does not prove exact historical source identity.
