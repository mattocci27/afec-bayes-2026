# AFEC 2026 classroom workspace

Open `afec-bayes-2026.Rproj`. Your editable files are under this directory and
are preserved in your own volume. Do not install packages or restore renv.

- Read `day1/slides.html`, `day2/slides.html`, `day3/slides.html` in RStudio's browser preview.
- Open `dayN/exercise.qmd` in the editor and run the indicated chunks, not the entire document.
- Packages, CmdStan 2.38.0 and matching compiled models are already in the image.
- The seeded example data are also exported under `data/`; posterior draws and
  diagnostics are under `fits/`. No internet download is needed for the core course.

## Stored results versus new inference

The classroom default is **stored results**, not live sampling. Always check
`fit$source`. These results apply only to the default data and priors. The
intentionally problematic Day 2 fit is retained for the diagnostics exercise.

Tasks that change sample size, data or prior need **new inference**. Wait for
the instructor, then explicitly request it (the existing chain count and
iterations are retained; only one chain runs at a time):

```r
fit <- fit_or_load("day1_seedling", "stan/binomial.stan",
                  data = list(N = 5, y = 2, a = 2, b = 2),
                  use_precomputed = FALSE, fallback = FALSE,
                  parallel_chains = 1, threads_per_chain = 1)
fit$source
```

Stored fits with different data/prior are rejected, not presented as your new
answer. If live inference is unavailable, discuss your prediction and the
default results; do not claim that stored results reflect your modifications.

The execution times printed in the draft QMDs are **not measurements for 30
users on this server**. Large models should use stored results. The instructor
will schedule live sampling in smaller groups until capacity is measured.

Changing a Stan source disables its precompiled executable until the instructor
rebuilds the image. `brms` examples are optional: they generate new Stan code
and require compilation, so are not part of the no-compilation classroom route.
Do not run the legacy `_targets.R` pipeline in class.

Slides use local math/font/image resources. External reference links are
optional reading and may not be reachable during the workshop. Exercise HTML
is not pre-rendered: worked solutions change data/prior and cannot honestly be
rendered using only default stored results.
