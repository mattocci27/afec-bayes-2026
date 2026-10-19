# 2026-10-19 handoff: Day 2 model, MCMC and diagnostic flow

## Goal

Make the transition from the ecological model to Bayesian inference and MCMC
understandable, show an actual failed run, and keep the model/parameter slides
readable. The project root is `afec-bayes-2026`; teaching content remains English.

This records the final decisions from this session. It supersedes earlier slide
numbers and the mandatory numerical-diagnostic table in the 18 October Day 2
flow log. The incremental validation record is retained in
`2026-10-19-day2-failed-mcmc.txt`.

## Final teaching sequence and decisions

The main deck has **27 counted slides**; optional reference slides are uncounted.

- **10 — Our model: seedling survival:** observed n_i, s_i, x_i on the left;
  prominent binomial and logit equations on the right. A short sentence explains
  that, with observations fixed, this model defines the **likelihood** for alpha
  and beta. The binomial model and logit relation together define that likelihood;
  the link alone is not a likelihood. Retain the survival-density takeaway.
- **11 — What are we estimating?:** prominent unknown alpha/beta, then aligned
  **Prior — Before seeing data** and **Posterior — After seeing data** columns.
  Separate Normal(0, 2.5^2) prior equations, an independence sentence, and a subtle
  **Data / arrow / via the likelihood** bridge lead to the joint posterior.
  Takeaway: “We use simulation to approximate the posterior.” Only alpha/beta
  are orange; other text is dark. No coloured cards or boxes.
- **12 — Approximate the posterior using simulation:** a two-minute conceptual
  MH illustration using the existing main-deck GIFs. Explain proposals, retaining
  the current value on rejection, and visit frequencies approximating posterior
  probabilities after adequate exploration. This is the bridge from the inference
  goal to the sampling method, not an optimization lesson.
- **13 — For CNDD, each draw is a coefficient pair:** actual saved joint draws;
  the orange path joins 25 consecutive post-warmup draws from one chain. Each
  draw contains both coefficients. Check exploration before interpreting them.
- **14–16:** enlarged normal traces, actual failed traces, then investigate,
  revise, refit and recheck before interpretation. The failed example is a
  separate Normal log-height regression, explicitly not a failed CNDD run.
- **17:** four paired draws and four grey survival curves. Table labels are
  **1–4**, followed by vertical ellipses in all columns. Table/curves now use the
  **first four saved draws**, not draws selected at spaced beta quantiles. They
  need not cover the posterior range. Keep all four curves grey: they describe
  uncertainty in one relationship, unlike the later coloured species preview.
- **18–19:** 100 sampled curves, then the band calculated from all stored draws.
  Current intervals are 95% pointwise intervals; the earlier 90% log is outdated.
- **20:** core density-comparison exercise. Numerical R-hat/ESS/divergence/
  treedepth comparisons remain in **Optional reference**, for later explanation
  or questions, not in the first MCMC-to-curve sequence or a required new task.

The visible likelihood connection is intentional: Day 1 already introduced
Prior + Likelihood -> Posterior. “Data” alone hid how the model enters updating.
The final changes restore that connection without adding more equations/slides.

## Statistical and asset findings

- The failed fit has redundant intercepts alpha1 + alpha2 with independent
  Normal(0,1000) priors (SD 1000). Data identify their sum, not the individual
  intercepts. Proper broad priors do not make this particular run reliable.
  Stored diagnostics: maximum R-hat about **2.54**, minimum bulk/tail ESS about
  **4.81 / 12.4**, **0 divergences**, **3693 treedepth hits**. Zero divergences
  therefore cannot be treated as sufficient. No repaired refit is claimed.
- The existing `mh_post.gif` plots **log unnormalised target density**, despite
  its original “Posterior” axis label. The visible caption and instructor notes
  clarify this. It is not a histogram. `R/mh.R` uses seed 123, 200 steps/chain,
  starts 0.2/0.8 and +/-0.01 grid proposals; the target is proportional to
  p^110 (1-p)^90, a grid approximation to Beta(111,91). It is separate from CNDD
  and Day 1 data. Stan uses HMC/NUTS, not this random-walk proposal.
- Slide 11 uses **variance notation** Normal(0, 2.5^2), as requested. The saved
  Stan model still uses `normal(0, 2.5)` with **SD 2.5**. No prior changed.
  Independence is a prior assumption, not a posterior-independence claim.

## Files changed

- `day2/slides.qmd`: sequence, two model/inference slides, MH introduction,
  failure example, larger trace labels (24–26 pt), draw numbering/ellipsis,
  optional diagnostics, instructor notes and reference link.
- `day2/slides.html`: regenerated final deck; preserve the Quarto source as the
  edit target. New styling is scoped to the relevant slide IDs.
- `R/course_visuals.R`: `course_fit("day2_allo_bad")` now verifies the stored
  model name and matching seeded allometry data before returning the result.
- `logs/2026-10-19-day2-failed-mcmc.txt`: incremental validation notes.
- This Markdown handoff. Generated figure assets were refreshed by rendering.

No course-model refits, Stan/data changes, dependency installation, participant
exercise edits, commit or push. Existing MH GIFs were reused without targets.

## Validation

Local versions: **R 4.6.1**, **Quarto 1.10.19**, posterior 1.7.0, bayesplot 1.16.0.
Stored results were generated with CmdStan 2.38.0.

```sh
RENV_CONFIG_SANDBOX_ENABLED=FALSE quarto render day2/slides.qmd
RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript R/check_classroom_materials.R
git diff --check
```

- Final render and whitespace checks passed. Quarto required approved access to
  its cache outside the workspace. No dependencies were changed.
- The integration check earlier in this session passed **26 runnable participant
  chunks** and all seven stored-fit checks, including the deliberate-failure
  exemption. Later edits changed only slide text/layout and draw display.
- Verified failed-fit seeded data, current slide order, 27 counted slides, local
  GIF references and mathematical markup.
- Native Arc UI was available even though browser-connector inventory was empty.
  **Final slides 10 and 11 were visually inspected at presentation size**:
  equations, annotations, aligned headings, arrow labels and takeaways fit.
  Earlier full-browser-unavailable notes do not apply to these final two slides.
  Trace images were also inspected; the entire deck was not re-audited in-browser.
- Before/after HTML section comparisons for the final likelihood edit confirmed
  **only slides 10 and 11 changed**, with every other slide section identical.

## Unresolved issues and next steps

1. Best next action: instructor walkthrough of slides 10–19. Preserve the core
   exercise start at 40 minutes; the model/MCMC/trace/curve sequence still occupies
   the 25–40 minute segment. Notes allocate about two minutes to MH and two to
   failed-chain comparison; shorten recap/path mechanics if needed.
2. Do not restore the discarded vertical slide-11 layout, independence overscript,
   multiple accent colours, A–D labels, spaced-quantile draw selection, or the
   numerical diagnostic table in the first explanation. These choices were
   explicitly superseded by instructor feedback.
3. `classroom/instructor.md` and the participant ZIP were **not rebuilt or updated
   in this session**. Review schedule alignment and rebuild distribution materials
   when preparing the next release; previous ZIP-validation logs do not establish
   that the ZIP contains these latest slides.
4. renv still reports the pre-existing out-of-sync project state. Prepared student
   browser accounts, classroom deployment/load and optional live inference remain
   separate validation work. No student CmdStan/C++/Docker installation is required.
5. The working tree remains uncommitted. Preserve the existing modified files and
   incremental log; do not redo model fitting or run `targets::tar_make()` merely
   to render these slides.
