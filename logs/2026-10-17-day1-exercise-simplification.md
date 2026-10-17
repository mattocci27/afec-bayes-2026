# 2026-10-17 handoff: simplify the Day 1 participant exercise

Follows `2026-10-16-day1-visual-refinements.md`. Supersedes the older handoff's
placement of Day 1 solutions and Stan/brms demonstrations in `day1/exercise.qmd`.

## Goal

Make the first exercise approachable for participants with limited statistical
confidence. Keep the updating calculation visible and reduce instructions to
what participants need to do. Teaching materials remain English; instructor
communication is Japanese.

## Decisions and reasoning

- Remove repeated, precise timing labels from participant-facing slides and
  exercises for Days 1–3. Keep timing estimates in instructor notes/schedules.
- `plot_update()` is defined in `R/course_utils.R`, not `R/functions.R`.
  The old exercise did source it, but distributing that QMD alone omitted its
  dependencies. More importantly, hiding the entire update in a helper made
  the statistical calculation invisible to learners.
- Show `dbeta()`, `dbinom()`, `prior * likelihood` and normalisation directly.
  Tidyverse/ggplot2 are explicitly allowed. Do not reinstate a base-R-only
  constraint or hide the updating calculation inside `plot_update()`.
- The slides explain prior/data combinations using coins and a strong
  Beta(51,51) prior. The exercise transfers the binomial structure to seedlings,
  fixes a flat Beta(1,1) prior, and asks participants to edit the counts themselves.
  Repeating the lecturer's explanation of the same plots adds little value.
- Reduce participant prose: no operational preamble, purpose/computation table,
  long function explanations, role-switch instructions or duplicate reflection.
  Put short explanations in code comments and detailed guidance in instructor notes.

## Current state

`day1/exercise.qmd` is now 60 lines; the generated participant QMD is 55 lines.
It contains tidyverse setup, one complete calculation/plot for 2 survivors out of
5 seedlings, and four short questions:

1. Identify the prior, likelihood and posterior calculations.
2. Predict the posterior width for 40 survivors out of 100.
3. Change only y and N and rerun the chunk.
4. Explain what changes despite the identical observed proportion.

The grid and plot axes stay fixed. The plotted values are normalised probabilities
per grid point, not a continuous density. The approximated continuous posteriors
are Beta(3,4) and Beta(41,61); both observed proportions are 0.4, but posterior
means are not identical. More data narrow uncertainty about p under the same model.

`day1/instructor-notes.qmd` now holds the purpose, model assumptions, timing,
solutions, grid explanation, common misunderstandings, optional prior comparison,
Stan/brms demonstrations and optional numerical summaries. The original demo
code and references were preserved. It renders to `day1/instructor-notes.html`
and is excluded from the participant ZIP. The instructor exercise and schedule
link to it; the participant source has no instructor link or external R-file dependency.

## Files changed

Current uncommitted changes at this handoff:

- `day1/exercise.qmd`, `day1/exercise.html`: shortened exercise and instructor-only link.
- New `day1/instructor-notes.qmd`, `day1/instructor-notes.html`: separate instructor material.
- `R/classroom_materials.R`: normal builds also render the Day 1 instructor notes;
  the existing explicit participant packaging list excludes them.
- `Makefile`: `make day1` also renders the instructor notes.
- `classroom/instructor.md`, `classroom/instructor.html`: link to the detailed notes.
- `README.md`: document the new location and build behavior.

Generated/ignored participant QMD/HTML and `dist/afec-classroom-materials.zip`
are updated. Earlier changes in this session also replaced Day 1 black-box plotting
with explicit calculations, aligned the result sheet, and removed participant timing
labels across Days 1–3. Those earlier changes are already present in the current
baseline and should not be redone. No commit or push was performed by the agent.

## Validation

Local R 4.6.1 and Quarto 1.10.19. Reproduction commands from the project root:

```sh
Rscript R/build_classroom_materials.R
Rscript R/check_classroom_materials.R
git diff --check
```

- Full build succeeded, including the new instructor notes, all course HTMLs and ZIP.
  Uses existing fits; no new Stan inference was run.
- Existing integration checks passed: participant sources match their generator,
  the edited Day 1 counts match the exact Beta calculation on the grid and produce
  smaller posterior variance, and stored-fit guards/diagnostics pass their checks.
  The deliberately bad teaching fit retains its existing exemption.
- Inspected the rendered participant HTML: four questions, one embedded figure,
  and no instructor prose, optional section or reflection. Viewed the embedded
  plot and checked its labels and rendering.
- Verified ZIP Day 1 participant QMD matches the current generated source exactly;
  no `instructor-notes` files are included.
- `git diff --check` passed. Removed temporary Rplots.pdf and reverted unrelated
  slide-HTML whitespace-only changes generated by the full build.
- Sandboxed rendering failed on R/Quarto cache writes; the approved build command
  succeeded with escalation. No environment dependencies were installed.

## Remaining issues and next steps

- Full-page browser visual review was unavailable: the computer-use tool reported
  no available browsers. HTML rendering and embedded-figure inspection succeeded.
- The fresh browser-based participant account/environment still needs classroom
  validation, including tidyverse availability, connectivity and running the edited
  counts. Local execution does not establish classroom readiness.
- Brms compilation/sampling was not repeated; these chunks remain instructor-only
  and `eval=FALSE`. Earlier brms validation is recorded in the previous handoff.
- Best next action: have the instructor read the short participant HTML as a learner,
  then test it in a fresh prepared classroom account. Preserve the concise four-question
  flow and avoid adding operational or statistical caveats back into participant prose.
