# 2026-10-18 handoff: course objectives, 95% intervals and Day 3 restoration

Follows `2026-10-18-day2-slide-flow.md`. Supersedes that log's 90% intervals
and its old slide numbers. Existing logs are unchanged.

## Goal

Make the course's broad goals and concrete learning outcomes visible, clarify
posterior uncertainty versus group differences, and restore the concrete
motivation for the Day 3 mother-tree model from `main.qmd`.

## Decisions and current state

### Objectives across the three days

Each objectives slide now has one broad purpose followed by observable outcomes:

- Day 1: **Understanding Bayesian thinking** — prior/likelihood/posterior and
  how data/prior affect estimates and uncertainty.
- Day 2: **Understanding Bayesian regression** — density-to-survival model,
  probability-scale interpretation with uncertainty, sampling and model checks.
- Day 3: **Understanding Bayesian hierarchical models** — groups differing while
  sharing information, changes in estimates/uncertainty, extension to species
  regression relationships.

Do not replace these with a vocabulary list or force identical small-goal headings
across all days. Day 3 also has an early “Today's progression” slide: first eight
mother-tree probabilities without a density effect, then species-specific regression.
Do not call the first model categorically “not regression”; it is a simpler
hierarchical model focused on information sharing.

### 95% intervals throughout current course materials

The instructor explicitly requested ALL slides, not just the Day 2 ribbon.

- Shared summaries, regression ribbons, probability comparisons, mother-tree
  estimates, allometry intervals and posterior predictive intervals now use
  2.5th/97.5th percentiles and 95% labels.
- Updated corresponding exercises, solutions, result-sheet calculations,
  instructor notes and current planning prose to avoid contradictions.
- Day 1 slides already used 95%; its instructor-only optional numerical summaries
  were brought into agreement. `summarise_update()` now returns `q2_5` and `q97_5`
  instead of `q5` and `q95`; no other consumers of the old names were found.
- Keep credible intervals for probabilities distinct from predictive intervals
  for replicated observations. The four illustrative beta-rank selections at
  10th–90th percentiles are not uncertainty intervals and were intentionally unchanged.

### Day 2 curves and model checking

- Curve progression is now **four grey curves → 100 thin translucent grey curves
  → all-draw posterior median and 95% pointwise ribbon**.
- The added 100-curve slide samples actual paired draws without replacement,
  seed `20261024`. The 100 lines are illustrative; the ribbon uses ALL stored draws.
- Day 2 slide 16's fitted-curve plot explicitly states:
  “Each point represents one quadrat.” Points are observed proportions, sized by
  seedling count, not species.
- The SD histogram was confusing without an SD introduction. Moved it to optional
  reference. The main predictive-check plot now asks whether the density pattern
  is reproduced and whether observations are consistently high/low in part of
  the density range, then proceeds directly to real-forest conditions.
- Optional SD slide explains one observed SD versus repeated simulated SDs;
  subtitle: “Black line: observed SD. Orange: SDs from simulated data sets.”
- Preserve the distinction between sampling diagnostics and checking observed
  patterns. Similar predictive data do not prove a model correct.

### Day 3: restore the concrete mother-tree introduction

Read `main.qmd`, its existing `main.html` tables and embedded plots before editing.
The old version motivates information sharing with numerical calculations; the
previous Day 3 introduced model names/equations before establishing the problem.

Current Day 3 sequence:

1. Eight mother trees: calculate the pooled observed proportion using visible
   `sum(trees$suv) / sum(trees$n)`; result rounds to **0.284**.
2. Display mother-specific counts and observed proportions, ranging **0.19–0.50**.
3. Plot those proportions with a dashed pooled-proportion reference; ask about
   real differences versus sampling variation and whether trees can share information.
4. Introduce complete, separate and partial pooling, then group variation.
5. Predict which estimates move, do the existing exercise, compare estimates and
   discuss movement. Detailed Stan code moved to optional reference.
6. After the exercise, show the restored simulation-truth comparison, then connect
   to species CNDD and hierarchical regression. Truth comparison can be omitted
   if the debrief runs short.

Removed the hypothetical 0/2 and 2/2 question, which does not describe the table.
The generating setup matches the old example; current data and saved fits are
retained. No targets pipeline was run and `main.qmd/main.html` were not edited.

Important distinctions to preserve:

- Introductory observed proportions are MLEs; the existing model-comparison
  plots use posterior means and 95% intervals.
- The truth plot compares observed proportions with current partial-pooling
  posterior means, not old cached `p_bayes` values.
- `p_true` in `make_tree_data()` is rounded to two decimals. The truth plot is a
  visual illustration, not an exact estimation-error calculation.
- The true-versus-estimated plot uses equal axes and a dashed 1:1 reference.
  Orange estimates can move away from truth for some trees; no universal improvement claim.
- Complete/separate models retain Beta(1,1) priors; partial pooling retains the
  saved Stan model's Normal(0,5) group-centre and half-Normal(0,1) group-SD priors.
  Do not copy the old slides' different hyperpriors into the current explanation.

## Files changed

Current uncommitted teaching changes span:

- `R/course_visuals.R`: 95% summary/plot interval calculations and labels.
- `R/course_utils.R`: exact Beta-summary percentiles and column names.
- `day1/slides.qmd/html`: objectives; `day1/instructor-notes.qmd/html`: optional summaries.
- `day2/slides.qmd/html`: objectives, 100 curves, quadrat caption, predictive-check flow.
- `day2/exercise.qmd/html`, `day2/results.qmd`: 95% intervals and explanations.
- `day3/slides.qmd/html`: objectives, progression, restored introduction, truth plot,
  95% labels and optional Stan code.
- `day3/exercise.qmd/html`: 95% wording.
- `classroom/instructor.md/html`: aligned flow, timings and interval descriptions.
- `classroom/restructure-proposal.md`: 95% wording in the existing exercise design.

Generated participant sources/HTML, figure assets, exports and
`dist/afec-classroom-materials.zip` are updated as appropriate; many are ignored.
An untracked `.DS_Store` is unrelated and was left untouched.
No new inference, dependency installation, git commit or push was performed.

## Validation

Previously checked local environment: R 4.6.1, Quarto 1.10.19.

```sh
Rscript R/build_classroom_materials.R
Rscript R/check_classroom_materials.R
quarto render day1/slides.qmd
quarto render day2/slides.qmd
quarto render day3/slides.qmd
quarto render classroom/instructor.md
Rscript R/build_classroom_materials.R --package-only
git diff --check
```

- Full build and integration checker passed after the 95% conversion. Checked
  generated participant sources, safe execution, saved-fit/data guards and diagnostics.
- A temporary `/tmp/afec-interval95-check.R` independently checked actual plot data
  against 2.5th/97.5th quantiles for CNDD ribbons/comparisons, predictive intervals,
  shared summaries and the exact Beta summary. It passed after comparing numeric
  values without quantile-name attributes. This script is not a repository test.
- Checked rendered Day 1–3 text for remaining 90% interval labels; none remained.
  Ignore CSS percentages when auditing HTML.
- Subsequent objectives and Day 2/3 edits were rendered individually; the latest
  Day 3 render executed all 33 chunks successfully with existing saved results.
- Inspected affected plot PNGs, including the restored observed-proportion and
  true-versus-estimated plots. Shortened/wrapped axes after inspection. The truth
  plot explicitly uses a white device background for legible exported graphics.
- Verified Day 3 slide order and optional-code placement, and verified current ZIP
  slide/figure bytes match local outputs. Final `git diff --check` passed.
- Use approved escalation for R/Quarto cache writes when sandbox execution fails.
  Do not replace working local tooling or introduce Docker for these edits.

## Remaining issues and next steps

- Best next action: instructor walkthrough of Day 3's restored numeric introduction
  and transition to the hierarchy, then the post-exercise truth comparison.
  Keep the truth comparison brief or omit it to protect the species-regression bridge.
- Full-page browser/projector layout review remains outstanding; current validation
  used rendered HTML inspection and plot images, not a live browser presentation.
- Fresh classroom browser-R account validation remains outstanding.
- Day 2/3 exercises and some Day 3 notes still contain older pair-work/operational
  prose; they were not broadly rewritten in this pass. Day 2's SD demonstration
  also remains in exercise/reference material while its slide moved to the appendix.
  Align these if instructor requests exercise cleanup; do not restore SD to the main slides.
- Preserve concise teaching text, the three broad objectives, 95% intervals,
  grey posterior curves versus coloured species curves, and concrete calculations
  before model terminology. Do not redo the already completed Day 1 simplification.
