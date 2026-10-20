# 2026-10-20 handoff: Day 3 regression and adaptive course pacing

## Goal

Restore the bridge from intercept-only survival to hierarchical regression,
then make the handout manageable and reassess all three 90-minute sessions.
The latest instruction is to advance the next day's core material when the
class finishes early, rather than treat each day's boundary as fixed.

## Current state and decisions

- Communicate with the instructor in Japanese; teaching materials stay English.
  Keep time estimates in the instructor guide, not participant slides/handouts.
- Day 3 retains the mother-tree comparison and truth figures before the
  intercept-only code walkthrough, followed by a count check and regression.
  Preserve this sequence; do not repeat comparison plots as an exercise.
- Current mother data use `generate_dummy_simple(n_sp = 8, sig = 0.2, seed = 42)`.
  The truth plot highlights **Tree A**, uses arrows and axes 0.2–0.5, and no longer
  uses the old Tree H / “rounded” framing. Same-date earlier pooling logs describe
  obsolete values/layouts: current source is authoritative.
- The mother-tree handout retains full model/analysis code. The predictive slide
  is “Can the model reproduce the observed counts?”; distinguish this check from
  MCMC diagnostics and distinguish count intervals from probability intervals.
- Regression progression: shared slope with varying intercepts; varying slopes
  with partial pooling and residual intercept–slope correlation; species trait
  predicting both intercept and slope means. Substitution gives `x + u + x:u`.
  A trait-dependent slope alone does not generate the `u` main effect.
- One seeded CNDD data set: 12 species, 118 quadrats, unequal sampling effort;
  `x = (density - 20) / 10`, `u` = wood density standardized across species.
  Lecture abundance and handout wood density occupy the same group-predictor role.
  These are simulated examples, not estimates from the mother-tree data or papers.
- Three new saved Stan fits are available. Their sources, inputs and priors are
  matched and checked. The primary participant workflow needs no new inference.
- The initial expansion was too long. Final revision reduced regression prose
  from 2579 to 1127 words (code excluded); the QMD went from 1128 to 863 lines.
  Main figures are now fitted curves for A/L across three models and a trait–slope
  comparison. Full simulation/plotting source remains in four folded code blocks.
  Additional diagnostics, regression PPC and brms fitting are folded optional
  references. No undisclosed course-specific functions replace the code.

## Pacing: latest agreed operating rule

Estimates are instructor judgments, not rehearsal measurements. They assume
English, roughly 30 ecologists with limited GLM experience, prepared fits, and
fatigue after daytime practical work. Full routes exclude appendices/live fits
but include both Day 3 handout analyses.

| Day | Full route estimate | Selected content | Questions / buffer |
|---|---|---|---|
| 1 | 85–110 min | About 75 min | 15 min |
| 2 | 95–125 min | About 75 min | 15 min |
| 3 | 120–160 min | About 80 min | 10 min |

- Full coverage requires about 300–395 minutes versus 270 available. Advancing
  material helps redistribute work; it does not make everything compulsory.
- Day 3 core: mother-tree pooling, selected analysis code, probability/count
  interpretation and checking, then all three regression structures including
  the trait interaction. A second full CNDD code walkthrough is an extension.
  Protect roughly the last half-hour for regression, synthesis and questions.
- After Day 1, if 10–15 minutes remain beyond closing questions, teach Day 2's
  CNDD/data/binomial/link introduction. Stop after “A straight line and a
  probability curve”; resume Day 2 at “Our model: seedling survival” after recall.
- After Day 2, if 12–18 minutes remain, introduce Day 3's mother-tree counts,
  complete/separate estimation and shared prior. Stop after “Information sharing
  through a prior”; resume at “How much can mother trees differ?” after recall.
- Complete core understanding and discussion first; individual early finishers
  do not set the class pace. Advance a complete concept block, not optional extras.
  Record the last completed title/handout section and unresolved question; do not
  reteach the whole completed block the next day. Keep a viable no-advance route.

## Files and generated artifacts

- `day3/exercise.qmd` / `.html`: complete mother model and shortened regression.
- `day3/slides.qmd` / `.html`, `day3/results.qmd`: model-reading flow and references.
- `stan/cndd_hierarchical.stan`: three binomial hierarchical structures via K/T.
- `R/precompute_day3_regression.R`: fits only the three new models, evaluating the
  exact handout simulation/data-list chunks; `R/precompute_fits.R` includes it.
- `docker/check-fits.R`, `R/check_classroom_materials.R`: new fit/data/source guards
  and checks of model structure and predictions. README documents regeneration.
- `R/course_visuals.R`: mother predictive simulation seed order corrected so the
  requested seed takes effect after deterministic data generation.
- `classroom/instructor.md` / `.html`: authoritative timing estimates, priorities,
  advance/resume boundaries. `classroom/restructure-proposal.md` points to these
  rules as superseding older fixed timing tables.
- Generated participant QMD/HTML, data exports and ZIP were refreshed after the
  handout revision. The final pacing edit affects instructor documents only.
- New ignored fits: `fits/day3_cndd_{intercepts,slopes,traits}.rds`; session info in
  `fits/day3-cndd-sessionInfo.txt`. Distribute `dist/afec-classroom-materials.zip`;
  cloning alone omits saved fits. Existing unrelated changes remain uncommitted.

## Validation and execution

- Existing instructor Docker image `mattocci/cmdstan-zsh:4.5.3`, CmdStan 2.38.0,
  generated the three CNDD fits: seeds 20261027–20261029, 4 chains, 1000 warmup +
  1000 retained draws per chain, adapt_delta 0.98. Only these models were refitted.
  Maximum R-hat below 1.007; minimum bulk ESS 933; no retained divergences or treedepth
  hits; minimum E-BFMI 0.67. See the CNDD validation log for warmup messages.
- Local R 4.6.1, posterior 1.7.0, Quarto 1.10.19.
- After shortening: `Rscript R/generate_student_sources.R day3`,
  `Rscript R/check_classroom_materials.R`, and
  `Rscript R/build_classroom_materials.R` passed. Days 1/2/3 have 3/8/25 executable
  participant chunks; all ten fits checked, with the existing bad-fit exemption.
- A fresh ZIP extraction executed all 25 Day 3 chunks and verified input matching,
  model expansion, joint-draw prediction and changed-data rejection. HTML checked
  for folded code and absence of instructor solutions; figures inspected in Chrome.
- Pacing update: `quarto render classroom/instructor.md`, arithmetic of the three
  90-minute allowances, HTML content checks and Chrome visual QA passed.
  `git diff --check` passed. No commit or push.
- Detailed evidence: `logs/2026-10-20-day3-cndd-regression-validation.txt` and
  `logs/2026-10-20-day3-shortening-validation.txt`. Their earlier 26-chunk count
  describes the pre-shortening version; the current count is 25.

## Remaining work and best next action

No requested material edits remain. Actual pacing, teaching language, classroom
computing/login/connectivity and participant capacity still need confirmation or
observation. Optional brms/glmer live fits were not validated in this session;
use the tested saved Stan route. No Codex configuration was edited here.

Best next action: teach/rehearse the selected Day 1 route, record the actual
stopping point and outstanding questions, then adjust the next session from that
boundary. Do not expand Day 3 again, refit unchanged models, rerun the legacy
`targets` pipeline, or assume that early advancement is guaranteed.
