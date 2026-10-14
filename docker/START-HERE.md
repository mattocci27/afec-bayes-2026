# AFEC 2026 classroom workspace

Open `afec-bayes-2026.Rproj`. Your editable files are under this directory and
are preserved in your own volume. Do not install packages or restore renv.

- Read `day1/slides.html`, `day2/slides.html`, `day3/slides.html` in RStudio's browser preview.
- Open `dayN/exercise-student.qmd` in the editor. Fill `___` first and run indicated
  chunks. Work in pairs and swap driver/reader roles for the next exercise.
- `dayN/exercise-student.html` is the local reading copy; `dayN/results.html`
  contains supplied tables/figures if RStudio is unavailable.
- Complete `classroom/readiness.html` before Day 1. Download the participant ZIP
  beforehand so these HTMLs remain accessible when the server/network fails.
- Packages, CmdStan 2.38.0 and matching compiled models are already in the image.
- The seeded example data are also exported under `data/`; posterior draws and
  diagnostics are under `fits/`. No internet download is needed for the core course.

## Stored results versus new inference

All core exercises explicitly use **stored results**. Always check
`fit$source`. These results apply only to the default data and priors. The
intentionally problematic Day 2 fit is retained for the diagnostics exercise.

Optional tasks that change sample size, data or prior need **new inference**. Wait for
the instructor, then explicitly request it (the existing chain count and
iterations are retained; only one chain runs at a time):

```r
fit <- fit_or_load("day1_seedling", "stan/binomial.stan",
                  data = list(N = 5, y = 2, a = 2, b = 2),
                  use_precomputed = FALSE, fallback = FALSE,
                  parallel_chains = 1, threads_per_chain = 1)
fit$source
```

Stored fits with different data/prior are rejected. If live inference is
unavailable, use the exact Beta comparison on Day 1 or the labelled historical
comparison on Days 2/3. Changed-input Stan draws are not supplied; do not
present default results as estimates for your modifications.

The execution times printed in the draft QMDs are **not measurements for 30
users on this server**. Large models should use stored results. The instructor
will schedule live sampling in smaller groups until capacity is measured.

Changing a Stan source disables its precompiled executable until the instructor
rebuilds the image. `brms` examples are optional: they generate new Stan code
and require compilation, so are not part of the no-compilation classroom route.
Do not run the legacy `_targets.R` pipeline in class.

The image builds slides with local math/font/image resources. Static exercise
and result HTMLs embed their resources. External reference links are optional
reading. Dates: 21–23 October 2026, 19:00–20:30 China time (UTC+8).

Extract revised materials into a new directory. Keep old workspaces and notes;
image upgrades do not replace existing participant files.
