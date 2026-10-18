# AFEC 2026 classroom workspace

Open `afec-bayes-2026.Rproj`. Your editable files are under this directory and
are preserved in your own volume. Do not install packages or restore renv.

- Read `day1/slides.html`, `day2/slides.html`, `day3/slides.html` in RStudio's browser preview.
- There is one short core exercise each day. You may open
  `dayN/exercise-student.qmd` and run supplied code, or read the HTML figures.
  Both routes complete the same questions. Work individually; discussion is optional.
- `dayN/exercise-student.html` is the local reading copy; `dayN/results.html`
  contains supplied tables/figures if RStudio is unavailable.
- Complete `classroom/readiness.html` before Day 1. Download the participant ZIP
  beforehand so these HTMLs remain accessible when the server/network fails.
- Packages, CmdStan 2.38.0 and matching compiled models are already in the image.
- The seeded example data are also exported under `data/`; posterior draws and
  diagnostics are under `fits/`. No internet download is needed for the core course.

## Stored results versus new inference

Core work uses exact R calculations (Day 1) or supplied posterior draws (Days 2–3).
No new inference, compilation or independent R/Stan programming is required.
You can complete every core task by reading the supplied figures and explaining
the comparison. R or GLM experience is not assumed. See
[packages and optional setup](classroom/PACKAGES.md).

Day 2 brms fitting is optional instructor reference or later exploration in a
prepared environment. Its chunk has `eval=FALSE`; it is not part of the core
exercise and is not homework. Do not install fitting tools during class.

Posterior predictive simulation generates observations from existing draws;
it does not fit another model. Hold data, model and priors fixed for the core
comparisons. Changing these requires new inference. Do not run `_targets.R`.

Slides use local math and figures in `slides_files/`. Exercise and result HTMLs
embed their resources. Keep the ZIP directory structure for resources and document links. External reference links are optional
reading. Dates: 21–23 October 2026, 19:00–20:30 China time (UTC+8).

Extract revised materials into a new directory. Keep old workspaces and notes;
image upgrades do not replace existing participant files.
