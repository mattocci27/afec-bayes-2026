# Day 3-2 validation

2026-10-23. Instructor-side validation; participant mastery and classroom
readiness are not established by these checks.

## Completed

- Inspected all 30 pages of the previous PDF, PPTX slides/notes and full R script
  before writing the coverage assessment, then the teaching materials.
- Built with `RENV_CONFIG_SANDBOX_ENABLED=FALSE make day3-2`.
  Slides, instructor exercise, generated student exercise, instructor notes and
  the optional report rendered successfully. All evaluated R chunks executed.
- Independently executed all displayed, non-evaluated R example blocks from
  the slides in the participant Project directory; no errors.
- Ran `Rscript --vanilla scripts/check_day3_2.R` on the final archive. It extracts
  to a different directory whose name contains spaces, executes the supplied
  script from the Project root, checks data.frame/column classes, 8 x 4
  dimensions, head() returning six rows, two distinct missing observations,
  histogram counts 0/3/3/1, and unchanged input data. It also changes the working
  directory to R/ and confirms the documented relative-path failure there.
- Final script runtime in that check was 0.007 seconds. This is execution time,
  not measured learner completion time. The 15-minute practical allocates
  3/4/3/3 minutes to its four sections and 2 minutes to recap/questions.
- The archive allowlist has exactly eight files: Rproj, README/data dictionary,
  CSV, script, report QMD/HTML, slides HTML and solution-free exercise HTML.
  Instructor exercise answers, notes, assessment and local workspace files are
  absent. The builder rejects missing/stale HTML and checks packaged HTML/CSS
  links and display resources; no remote display dependencies were found.
- Visually inspected all 16 slide layouts in Chrome (15 counted slides plus one
  optional slide), including directory tree, path table and actual str()/head()
  output. Improved code contrast locally without changing the course theme.
- Opened the final ZIP's extracted student HTML via file:// outside the repository;
  inspected location instructions, object/column outputs and the complete plot.
  No clipping, missing figures or instructor answer section appeared.
- Checked Makefile dry-run, source whitespace, Python syntax and package
  input tracking. The small CSV is explicitly unignored locally under day3-2/.

## Environment and limits

R 4.6.1, Quarto 1.10.19. Rendering used the project's existing R environment
(knitr 1.52); the independent --vanilla runtime exposes knitr 1.51, but the core
script and relocation check use only base R. No packages were installed or
updated. The existing renv out-of-sync notice remains.

The first sandboxed build ran the R chunks but failed to open Quarto's Sass
cache database. Authorized execution outside the sandbox completed rendering.
No source data, model, saved fit or earlier session materials were refitted or
rebuilt. Existing Day 3/instructor-guide changes were left in place.

Native RStudio was not available through the app inventory, so opening the Rproj,
Source/Console interaction and the Render button in an actual fresh RStudio
account remain untested. Browser RStudio login/upload/extraction and simultaneous
30-person access were not tested. No Windows test, physical network-disconnection
test or timed participant rehearsal was performed. The check of embedded local
resources is not a substitute for those classroom checks.

The materials are separate from the all-days ZIP and public website. No commit,
push, deployment or original nina-file edit was performed. The instructor still
selects the separate 30-minute lecture; this session does not extend the earlier
90-minute Day 3 lecture into a longer class.
