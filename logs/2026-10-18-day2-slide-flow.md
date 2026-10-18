# 2026-10-18 handoff: Day 2 slide flow and posterior curves

## Goal

Make the Day 2 sequence after the model recap understandable to learners: model →
posterior samples → calculation checks → survival curves → exercise → future
counts → model checking. Keep English teaching materials concise.

## Decisions and reasoning

- Introduce the full binomial/logit model with equations before code. Move the
  completed Stan code, full diagnostics and posterior predictive equations to
  optional reference slides. Independent Stan programming is not required.
- Introduce MCMC on Day 2 through actual paired alpha/beta draws and several
  chains. The orange path shows 25 consecutive post-warmup draws from one chain,
  not initialization, warmup or optimization. Do not teach algorithm derivations
  in the core sequence.
- Explain trace axes and chain colours before presenting a compact table of
  R-hat, bulk/tail ESS and divergences. No single diagnostic establishes reliability;
  full diagnostics remain in the appendix and result sheet.
- Bridge coefficients to probabilities explicitly: each paired draw yields a
  curve; all stored draws give pointwise 90% intervals. The four illustrative
  curves do not define the band, and coefficient medians are not substituted
  independently to construct it.
- Show numerical low/high-density comparisons after participants do the exercise.
  Then introduce survivor counts for two groups of 20 seedlings, followed by
  posterior predictive checking at each observed quadrat's original density and n.
- Individual work is the default; nearby discussion is optional.

## Latest figure decision: slides 14 and 23

Slide 14 shows four possible curves for the SAME fitted survival relationship.
Slide 23 previews DIFFERENT species using a conceptual simulation, not a species
fit to today's data. Colouring both sets of lines by identity obscured this distinction.

The instructor explicitly wants multiple curves retained on slide 14. Its final
version keeps all four actual paired draws and their coefficient table, with ALL
curves grey (`grey40`) and no table-row colour coding. Caption:
“Four possible curves for the same survival relationship.” Slide 23 keeps its
species colours. Do not replace slide 14 with a single curve: that approach was
superseded by the instructor's clarification.

## Current state and changed files

Uncommitted teaching-material changes at this handoff:

- `day2/slides.qmd`, `day2/slides.html`: revised main sequence, notes, appendix,
  references and slide 14 figure styling.
- `classroom/instructor.md`, `classroom/instructor.html`: matching teaching flow,
  timings and explanation of grey posterior curves versus coloured species curves.

Generated figure assets and ignored `dist/afec-classroom-materials.zip` are updated.
No new model inference, package installation, commit or push was performed.
The Day 2 exercise itself was not rewritten during these slide revisions.
Earlier objective/axis-label edits are already in the baseline; preserve them.
Day 1 exercise simplification is documented in the previous log; do not redo it.

## Validation

Local environment previously checked: R 4.6.1, Quarto 1.10.19. Latest commands:

```sh
quarto render day2/slides.qmd
quarto render classroom/instructor.md
Rscript R/build_classroom_materials.R --package-only
git diff --check
```

- Both renders and packaging succeeded. The Day 2 render executed all 41 chunks
  using the existing saved fit and model/data guards, with no refitting.
- Inspected the rendered plot images, including the final four-grey-line figure
  and species preview. Previously inspected the MCMC cloud/path, fitted band,
  future-count and predictive-check plots during the flow revision.
- Verified ZIP copies of `day2/slides.html` and the updated `paired-curves-1.png`
  match local files byte-for-byte. `git diff --check` passed.
- Kept unrelated generated HTML whitespace changes out of the diff. Rendering
  uses approved escalation for cache writes where required.
- Full-page browser review remains unavailable in this environment; image and
  generated-HTML inspection do not establish complete projected-slide layout QA.

## Remaining issues and next steps

- Best next action: instructor walkthrough of the revised Day 2 main sequence,
  especially the MCMC introduction, curve/band bridge and transition into checking.
  Confirm the 25–40 minute segment is comfortable at the audience's pace.
- The Day 2 exercise may still contain older, more verbose operating/pair-work
  instructions. Review for consistency if exercise editing is requested; the
  current request authorized slide revisions.
- A fresh prepared browser-based participant account still needs classroom
  validation for connectivity, dependencies and saved-result plotting. Local
  renders do not establish participant-environment readiness.
- Preserve core interpretation and model checks if time is short; shorten MCMC
  mechanics and species preview. Keep detailed code and diagnostics optional.
