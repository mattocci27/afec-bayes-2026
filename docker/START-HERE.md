# AFEC 2026 classroom workspace

Open `afec-bayes-2026.Rproj`. Your editable files are under this directory and
are preserved in your own volume. Do not install packages or restore renv.

- Read `day1/slides.html`, `day2/slides.html`, `day3/slides.html` in RStudio's browser preview.
- Open `dayN/exercise-student.qmd` in the editor. Required code is complete. Predict
  before running indicated chunks. There is one core exercise each day. Work in pairs
  and swap the person running code and the person interpreting the figure.
- `dayN/exercise-student.html` is the local reading copy; `dayN/results.html`
  contains supplied tables/figures if RStudio is unavailable.
- Complete `classroom/readiness.html` before Day 1. Download the participant ZIP
  beforehand so these HTMLs remain accessible when the server/network fails.
- Packages, CmdStan 2.38.0 and matching compiled models are already in the image.
- The seeded example data are also exported under `data/`; posterior draws and
  diagnostics are under `fits/`. No internet download is needed for the core course.

## Stored results versus new inference

All core exercises use exact calculations or **stored results**. A posterior-predictive
simulation uses existing draws to generate possible observations, without fitting
another model. Day 1 compares prior/data figures, Day 2 compares CNDD probabilities,
and Day 3 compares mother-tree estimates. Demonstrations and extensions are labelled.

The saved results apply to their recorded data, model and priors. Check `fit$source`.
Required comparisons hold the relevant inputs fixed. No core task requires live
inference, compilation or editing Stan. The archived earlier exercises and the
intentionally problematic fit are not required classroom tasks.

Changing model data or priors can require new inference. Changing a Stan source
invalidates the image's compiled executable. Wait for the instructor before either.
Keep all such work outside the core classroom route. Do not run `_targets.R`.

Slides use local math and figures in `slides_files/`. Exercise and result HTMLs
embed their resources. Keep the ZIP directory structure for resources and document links. External reference links are optional
reading. Dates: 21–23 October 2026, 19:00–20:30 China time (UTC+8).

Extract revised materials into a new directory. Keep old workspaces and notes;
image upgrades do not replace existing participant files.
