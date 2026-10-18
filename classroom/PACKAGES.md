# AFEC 2026: packages and optional R setup

**You can complete every core exercise by reading the supplied figures and writing
your interpretation. No software installation or previous R/GLM experience is required.**
The course focuses on Bayesian thinking: what a model assumes, what its estimates
and uncertainty mean, and why we compare model-generated data with observations.

Day 1 compares uncertainty for two seedling surveys. Day 2 compares survival at
two densities and discusses model checking. Day 3 compares mother-tree estimates
with and without information sharing. Code is supplied for anyone who wants to run
these comparisons. No core task starts new Stan inference. There is no homework.

## Choose how to participate

- **Read figures:** download and extract the participant ZIP before class. Open
  `dayN/exercise-student.html` and `dayN/results.html`. No R packages are needed.
- **Run supplied code:** use the prepared browser RStudio environment. Packages
  are installed by the instructor; do not install packages or run
  `renv::restore()` during class. If code does not work, continue with the HTML.
- **Optional local R:** use an already-prepared machine and the packages below.
  Installation is outside class time and is not an assignment.

## Packages for optional local execution of the core code

| Package | Purpose |
|---|---|
| `tidyverse` | Data manipulation and plotting; sufficient for the Day 1 code |
| `posterior` | Work with supplied posterior draws |
| `bayesplot` | Trace plots shown in reference material |
| `patchwork` | Combine plots |
| `here` | Find files inside the extracted course project |
| `knitr` | Handout chunk settings and tables |

```r
install.packages(
  c("tidyverse", "posterior", "bayesplot", "patchwork", "here", "knitr"),
  repos = "https://cloud.r-project.org"
)
```

Dependencies are installed automatically. Extract the **participant ZIP** into a
new folder and open `afec-bayes-2026.Rproj`. Keep the folder structure. The ZIP
includes the required stored results; cloning the instructor repository alone
does not supply them. The participant project does not activate renv.

To check an already-prepared local environment:

```r
packages <- c("tidyverse", "posterior", "bayesplot", "patchwork", "here", "knitr")
data.frame(package=packages,
           installed=vapply(packages, requireNamespace, logical(1), quietly=TRUE))
```

Then try the Day 1 supplied code. If something fails, tell the instructor and use
the figures. You do not need `brms`, `cmdstanr`, `targets`, `devtools`, CmdStan,
a C++ toolchain or Docker for core work. No model compilation is required.

## Optional only: brms demonstration or later exploration

The instructor may show how `brms` specifies and fits the Day 2 model, using
`cmdstanr` as its backend. This is optional reference material, outside the core
exercise. You do not need to run it, and it is not homework. Skip this section
unless you already want to explore fitting models in a prepared environment.

For that optional code, the additional R packages are:

```r
install.packages("brms", repos = "https://cloud.r-project.org")
install.packages(
  "cmdstanr",
  repos = c("https://stan-dev.r-universe.dev", "https://cloud.r-project.org")
)
```

brms may install rstan as a dependency, but our optional example explicitly selects
`backend="cmdstanr"`. **These R packages alone do not prepare a new inference
environment.** CmdStan itself and a working C++ toolchain are also required.
Follow the [official CmdStanR setup instructions](https://mc-stan.org/cmdstanr/)
outside class, or use an instructor-prepared environment. Students are not required
to install these tools on their own computers.

The instructor must validate compilation, sampling, diagnostics and plotting
before demonstrating the optional example. There is no classroom runtime guarantee.
The optional chunk has `eval=FALSE` and does not run when rendering the handout.
Do not treat diagnostics from a stored fit as diagnostics for a new fit.

## Optional only: render your own HTML

Reading the supplied HTML and running individual chunks does not require rendering.
If you choose to create HTML yourself, also install the [Quarto application](https://quarto.org/docs/get-started/)
and the R package `rmarkdown`. These are authoring tools, not core requirements.
