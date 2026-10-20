# AFEC Bayesian Statistics 2026: course scope and Day 3 revision

2026-10-20

## Goal

Align the three beginner sessions with the course goal: understand Bayesian
thinking and build a foundation for continued learning, rather than expect
independent model construction after three days.

## Decisions and changes

- Standardized univariate Normal notation to Normal(mean, SD). Day 2's prior
  scale examples now label the same distributions consistently; no prior or
  fitted model changed.
- Moved one existing Day 2 density-pattern posterior predictive-check figure
  into the core lecture after the regression walkthrough. No code or exercise
  was added for it; predictive simulation details remain optional.
- Marked core and optional content in each day's slides and exercises and
  shortened the instructor guide to a core/optional overview within each
  90-minute session. Understanding can be checked through natural discussion;
  no written question set, answer key or rubric was added.
- Reframed Day 3 slide 22, “Ecological reasons to share information,” around
  biological comparability, species traits explaining systematic group
  differences, and assumptions about group variation under partial pooling.
- Removed Day 3 slide 23, “Your own research,” after confirming the intended
  slide number with the instructor. Slide 22 already covers the ecological
  rationale, and the separate reflection prompt was unnecessary.
- Kept the existing ecological examples, saved posterior draws and model fits.
  No Stan, R analysis, data or fitted results were changed or refit.

## Files and deliverables

The course-scope revision updated `README.md`, `classroom/instructor.md`,
`classroom/restructure-proposal.md`, and the current Day 1–3 slide and exercise
sources and rendered HTML. The final Day 3 change is in `day3/slides.qmd` and
`day3/slides.html`. The solution-free participant archive is
`dist/afec-classroom-materials.zip`.

## Validation

- Full classroom-material build completed using existing fits; no new inference
  ran.
- After the Day 3 slide revisions, rendered `day3/slides.qmd` and refreshed the
  archive with `Rscript R/build_classroom_materials.R --package-only`.
- Checked the Day 2 PPC figure and daily core/optional labels in rendered
  materials. Visually checked the updated Day 3 slide 22 for text fit.
- Confirmed slide 23 is absent from the rendered Day 3 deck and that the
  participant ZIP contains the current Day 3 slides.
- `git diff --check` passed for the edited Markdown and Quarto sources.

## Remaining work

None for the agreed revision. The instructor can continue to use brief oral
questions during teaching; no separate assessment materials are planned.
