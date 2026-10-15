# 2026-10-15 handoff: restore intuitive examples and reconsider course difficulty

Follows `2026-10-14-slide-revisions.md`.

## Goal and instructor feedback

Restore familiar Day 1 explanations and reassess the three-day course for
ecologists without extensive statistics training. The instructor felt the
restructuring had largely lost the original course's accessible spirit.

The original `main.qmd` explicitly notes that coding exercises are not the focus.
The current course requires too many simultaneous skills: terminology, posterior
calculations, Stan structure, diagnostics and multiple model types. The existing
plans allocate 30 minutes to Day 1 exercises and 52 minutes to Day 3 exercises
and debriefs, alongside substantial new explanations.

## Completed source changes

`day1/slides.qmd`:

- Restored the complete `fip_1`–`fip_6` image sequence near Bayes' theorem,
  with speaker notes explaining forward and inverse conditioning.
- Moved the two PCR examples from the appendix into the main presentation.
  Retained the supplied 2% positive rate, 0.05% prevalence and 95% sensitivity;
  notes clarify that the marginal positive rate is an input to the calculation.
- Moved the two coin-toss comparison slides before Exercise 1A.
- Changed the illustrative small coin sample to 3/5, compared with 60/100,
  so the observed proportion stays fixed at 0.6. Both use Beta(51,51).
- Explicitly labelled the prior as strong and the posterior peaks as MAP.
  Posteriors are Beta(54,53) and Beta(111,91); MAPs are approximately 0.505
  and 0.55. Replaced the incorrect claim that 100 tosses dominate this prior.
- Updated the session-plan comment to classify the restored examples as short
  lecture demonstrations. Exercises have not yet been shortened.

## Review document, not an approved redesign

Added `classroom/restructure-proposal.md` in Japanese at the instructor's request:
write out the proposed flow in Markdown so the instructor can judge it first.

The proposal follows:

**Ecological/familiar question → prediction → figure → necessary mathematics
→ ecological interpretation.**

- Day 1: intuitive Bayesian updating, one short figure-comparison exercise,
  and an instructor demonstration of Stan/results.
- Day 2: one allometry analysis, reading predictions and checking the model;
  logistic regression and detailed diagnostic tasks become optional candidates.
- Day 3: understand partial pooling through mother trees, then connect to
  species allometry, wood density and NDD as research examples.

Each day has a proposed 90-minute schedule with discussion and a buffer.
The document specifies exercise purposes, starter-code plans, expected
observations, content to retain/move, and decisions for the instructor.
R experience, language, homework and classroom environment remain assumptions.

**The instructor has not approved this proposal. Do not implement the broad
redesign, change exercise requirements or describe the proposal as adopted.**

## Validation and execution limits

- Base R calculations confirmed both coin posterior parameters, MAPs, MLEs and
  posterior means. Whitespace checks on the edited QMD passed.
- All three proposed schedules were checked for continuity and a 90-minute total.
- Normal Quarto rendering failed: the project renv library reported broken
  cache links and missing `knitr`/`rmarkdown`; cache-lock creation was also denied.
- A temporary library assembled from available cached R 4.6 packages produced
  a segmentation fault while loading `rmarkdown`. Do not repeat that fallback
  as though these binaries form a working environment.
- A subsequent `--no-execute` attempt still required the unavailable R packages
  and failed. No successful full render or layout inspection was completed.
- No packages were installed, models refitted, images built or containers started
  during this session. Generated Day 1 HTML was not updated by these source edits.

## Working tree and files

At logging time HEAD is `fff4496` (`update slides`). This session changed
`day1/slides.qmd` and added `classroom/restructure-proposal.md`, plus this log.

Pre-existing work remains in `.Rprofile`, `README.md`, `day1/exercise.html`,
`day1/slides.html`, and untracked `.RData`/`.Rhistory`. Preserve it; do not
attribute those files to the changes above. No commit or push was performed.
Older logs are historical snapshots; consult current documentation for Docker
validation history rather than repeating their earlier not-built statements.

## Best next action

Wait for the instructor's judgment on `classroom/restructure-proposal.md` and
incorporate their decisions. Preserve the restored intuitive examples. Once the
direction is agreed, align slides, exercises, instructor guidance and participant
materials, then render and inspect them in a working environment.

Do not repeat the restores, expand required statistical content, refit models,
or repair the R environment merely to regenerate this handoff.
