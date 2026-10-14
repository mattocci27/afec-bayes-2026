# 2026-10-13: classroom feasibility revisions and handout validation

## Completed changes

- Revised the three 90-minute plans to include pair work, explanations/questions
  and delay buffers. All timing remains a design estimate, not a classroom measurement.
- Explicit stored-fit calls for all core computational tasks. Changed-input Stan
  refits are optional, disabled during rendering, and use explicit live/no-fallback flags.
- Day 3 new-mother-tree prediction is core. Sampling mechanics, advanced covariance,
  tool comparisons and extra models are extensions. Existing English materials remain English.
- `R/classroom_materials.R` generates participant QMDs with solution Divs physically
  removed, static exercise/result HTML, seeded CSV/RDS data and a participant ZIP.
- Added three offline result sheets, a ten-minute readiness check and the Japanese
  instructor runbook. Historical changed-input comparisons are labelled; no new fits invented.
- Updated README, START-HERE and future Docker build inputs. Existing images,
  student services, credentials and workspaces were not redeployed or overwritten.

## Execution and artifact checks

The execution host disconnected during the initial material build. On reconnect,
all three slide decks, three instructor exercises, three participant exercises,
three result sheets and readiness HTML already existed. Their timestamps matched
current sources. No old render process remained; the prior process session was
unavailable. The full build was not restarted. Packaging was resumed separately.

Primary commands (use the prepared R library):

```bash
Rscript R/build_classroom_materials.R
Rscript R/build_classroom_materials.R --package-only
Rscript R/check_classroom_materials.R
quarto render day1/slides.qmd
unzip -t dist/afec-classroom-materials.zip
git diff --check
```

Validation actually used R 4.6.1 on macOS and Quarto 1.10.19. The local project's
renv symlinks were unavailable; existing cache packages were selected for missing
packages while current global-library compiled packages took precedence. No packages
were installed. R-profile autoloading was bypassed only for the validation process;
the resulting library paths were inherited by Quarto. Quarto needed approved access
to its user cache. No project profile or dependency lock was changed.

Package versions: posterior 1.7.0, bayesplot 1.15.0, ggplot2 4.0.3, kableExtra 1.4.0,
here 1.0.2, knitr 1.51, rmarkdown 2.31. This is a local validation environment,
not a revalidation of the classroom image's complete locked Linux library.

Results:

- 44 runnable/filled participant and safe R chunks passed (Day 1: 13; Day 2: 15;
  Day 3: 16). A fixture enabled the classroom source/data guards; a wrapper rejected
  any attempted live inference. This fixture does not validate actual executables.
- All seven stored fits match current seeded data, model names, CmdStan 2.38.0 and
  4000-draw structure. Six ordinary fits pass R-hat <= 1.01, bulk/tail ESS > 400,
  zero divergence/treedepth hits and E-BFMI > 0.3. Lowest bulk ESS is about 923;
  lowest E-BFMI is 0.741. The intentionally bad fit retains R-hat about 2.54,
  bulk ESS about 4.8 and 3693 treedepth hits, despite zero divergences.
- Changed-data and stale-source rejection remained active. No Stan source, seed,
  sampling setting or stored fit was changed, and no live inference was run.
- All nine exercise/result HTML files and readiness HTML were parsed. Participant
  HTML has no solution callouts. Core script/style/image resources are embedded;
  no external script/image/stylesheet or remote CSS font import is required for
  the participant exercise/result/readiness pages. External reference links remain optional.
- Every local resource referenced by the slide HTML exists. Repository slide HTML
  still uses its original remote MathJax/logo/font configuration; future image builds
  supply local resources. The offline fallback is the self-contained exercise/result HTML.
- A fresh ZIP extraction passed all 2574 file digests, all seven fit/data checks and
  standalone stored-fit analysis with a correct fresh project root. It contains no
  instructor exercise source/HTML, renv lock or runtime credentials. ZIP integrity
  and `git diff --check` passed. The ZIP is approximately 55 MiB and is gitignored.
- Source parsing and revised Docker COPY/allowlist checks passed. No image build or
  server configuration change was performed.

The first diagnostic-check draft had a tibble column named `fit` shadowing its input
object; it was renamed and the complete check passed. A plot inspection found the
new Day 1 binomial title clipped. The title was shortened, only Day 1 slides were
rendered again, and the ZIP was rebuilt and checked.

Final ZIP SHA-256:
`2cc8e38b86b81591505c8ae990724b42f3626b79a3ba57c443878a3bf0ae38f2`.

## Remaining checks

Direct browser inspection of the local file was rejected by the browser URL
security policy (file protocol not allowed). No alternate browser route or raw
browser automation was used to bypass it. HTML structure/resources and representative
PNG figures were inspected, including the corrected Day 1 plot and the Day 3 pooling/
wood-density figures. Full browser layout, dynamic math execution, slide overflow
and disconnected-browser behavior remain unverified.

Also unverified: actual classroom browser login/network/HTTPS or VPN, updated
Docker-image rendering/runtime, 30-user load, and timed classroom rehearsal.
The classroom image built on 2026-10-12 predates these source changes. Existing
volumes preserve old materials; distribute the ZIP into a new directory or plan
a backed-up migration. Prior knowledge, English, TA availability and homework policy
still need organiser confirmation. Existing fits lack generation-time Stan-source digests.
