# 2026-10-20 handoff: session titles, English documents and setup guide

## Goal

Present each session by its statistical topic rather than its ecological example,
make current course documents available in English, and keep the advance package
instructions short and usable by Windows and Mac participants. Project root:
`afec-bayes-2026`. This follows `2026-10-20-day2-fitting-and-package-guide.md`;
its Day 2 workflow decisions still apply unless updated below.

## Current state and decisions

- **Day 2: Linear regression and MCMC.** CNDD/seedling survival is the worked
  binomial logistic regression example, not the name of the session. This title
  change does not replace the binomial/logit model or add a new analysis.
- **Day 3: Hierarchical models.** Mother trees and information sharing are the
  introductory example, followed by the existing ecological applications.
- Titles now agree across slide covers/browser titles, instructor and student
  exercises, and result sheets. Result-sheet titles end with “— Results.”
  README descriptions and instructor/proposal headings were aligned.
- `classroom/instructor.md` is fully English, titled **AFEC-X 2026 Instructor
  Guide**, with `lang: en`; its HTML was regenerated. The restructuring proposal
  is also fully English. Historical proposals remain distinguished from current
  decisions. Past logs and archived records were not translated.
- `classroom/PACKAGES.md` is an advance handout, not an in-class fallback guide.
  Keep it short, in English, with the October 21–23, 2026 night-session dates and
  “Created by Masatoshi Katabuchi.” Do not restore day-by-day package explanations.
- Package list: tidyverse, posterior, bayesplot, patchwork, here, knitr,
  rmarkdown, kableExtra, brms; cmdstanr has its separate repository command.
  `kableExtra` is required by slide generation. Quarto itself is separate software;
  the R package `quarto` is not required for RStudio/CLI rendering.
- The current setup introduction reads: “We may use precomputed model results
  during the sessions. To fit the models yourself, prepare the following tools
  beforehand:” Preserve this framing. Do not return to the awkward standalone
  sentence about reading supplied RDS files or an in-class “if it fails” message.
- Windows instructions: matching Rtools, restart RStudio, and folders without
  spaces; OneDrive paths may cause compilation problems. Mac instructions:
  Xcode Command Line Tools if absent (`xcode-select --install` in Terminal),
  with the R installer matching Apple Silicon/Intel architecture. Both systems
  need CmdStan for new fits, using `check_cmdstan_toolchain()` followed by
  one-time `install_cmdstan(cores=2)`. These are instructions only: nothing was
  installed on participants' machines.
- RStudio Server is not a requirement for completing the course. The instructor
  was advised to use local demonstrations, optional student code execution and
  supplied outputs when needed. No server was deployed or decommissioned here;
  the final classroom arrangement still needs to be settled.

## Important findings

All seven `fits/*.rds` files contain ordinary lists with draws, diagnostics,
data, source and metadata, rather than compiled model executables. `infoRDS()`
reports XDR format, serialization version 3, writer R 4.5.3 and minimum reader
R 3.5.0. This format is portable across ARM/x86 and Windows/macOS; package
requirements for the analysis are separate from that format-level minimum.
All seven files were read locally on Mac. No Windows-machine test was performed.
Reading the stored results does not require CmdStan or recompilation.

The repeated permission prompts came from requesting escalated Quarto runs for
cache writes outside the workspace. The user strongly objects to these prompts.
Do not interpret ordinary edits as requiring renewed user approval. Inspection
of this installed Mac Quarto found its Sass cache under the home Library/Caches
path, with no simple environment-variable override identified. The earlier
promise to move it with an environment variable was corrected; no persistent
cache fix was implemented. Never repurpose HOME. Keep any necessary escalation
limited to the actual blocked operation rather than surrounding file edits.

## Files changed

- `day2/slides.qmd`, `exercise.qmd`, `results.qmd` and generated HTML/student
  sources: new Day 2 title.
- `day3/slides.qmd`, `exercise.qmd`, `results.qmd` and generated HTML/student
  sources: new Day 3 title.
- `classroom/instructor.md` / `.html`: English translation and session headings.
- `classroom/restructure-proposal.md`: English translation and session headings.
- `README.md`: topic-based session descriptions.
- `classroom/PACKAGES.md`: packages, author/dates and concise OS-specific setup.
- `dist/afec-classroom-materials.zip`: repeatedly refreshed during these edits.

## Validation and build details

- Rendered `classroom/instructor.md`; checked English title, HTML language,
  local links and code fences. Arc displayed the English guide and tables.
  A scan of current documents found no Japanese outside excluded historical
  logs/archives and dependency/asset directories.
- Ran `make day2 day3` with `RENV_CONFIG_SANDBOX_ENABLED=FALSE`; subsequently
  regenerated the corrected Day 2 student source and rendered the instructor
  exercise. The Day 2 student HTML title was synchronized directly to avoid
  another escalated render for a title-only change. A later normal render from
  the source should reproduce it.
- Arc confirmed the Day 3 cover “Hierarchical models.” The Day 2 source/HTML
  title agreement was checked programmatically; no final Day 2 cover screenshot
  was obtained in this pass.
- Rebuilt with `RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript
  R/build_classroom_materials.R --package-only`; no inference or dependency
  installation was needed. Packaging normalizes HTML whitespace; restore only
  proven whitespace-only changes in otherwise untouched Day 1 slide output.
- The ten named R packages were locally available. `git diff --check` passed
  when saving this log. Prior live-fit validation is recorded in the previous
  log and was not repeated for these wording changes.
- No commit or push was made by the agent. Existing changes belong to the shared
  workspace; do not discard or reset them.

## Unresolved issues and next action

At log time, both days' student QMD/HTML and slide HTML match the participant
ZIP byte-for-byte. **The current PACKAGES.md differs from the ZIP**, following
a final wording edit to the introduction. Respect the current working file;
before distributing, run `--package-only` and verify its ZIP entry again.
This log-only step did not alter materials or the archive.

The best next action is that small packaging refresh, followed by checking a
fresh participant copy on at least one Windows machine. Windows toolchain setup,
actual classroom computing arrangements and simultaneous participant load remain
untested. Do not refit canonical course models or redesign the accepted Day 2
three-chunk workflow to address these documentation questions.

## Official references checked

- [Quarto with R](https://quarto.org/docs/computations/r.html#installation)
- [CmdStanR setup](https://mc-stan.org/cmdstanr/articles/cmdstanr.html#installing-cmdstan)
- [CmdStan toolchains](https://mc-stan.org/docs/cmdstan-guide/installation.html#c-toolchain)
- [Rtools](https://cran.r-project.org/bin/windows/Rtools/)
- [R for macOS](https://cran.r-project.org/bin/macosx/)
- [R serialization portability](https://stat.ethz.ch/R-manual/R-devel/library/base/html/save.html)
