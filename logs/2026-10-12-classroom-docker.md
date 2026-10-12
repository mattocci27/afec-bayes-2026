# 2026-10-12 handoff: classroom Docker image for 30 participants

## Goal

Prepare one `rocker/tidyverse:4.6.1` image with CmdStan 2.38.0, locked R
packages, course materials, data, precompiled models and stored fits for
30 independent RStudio Server containers on Ubuntu Intel
(i9-13900K, 128 GB RAM). Classroom execution should not need internet access.
Compose, authentication distribution and resource limits are follow-up work.

## Current state

- Dockerfile, allowlist `.dockerignore`, build/init scripts and documentation
  are written. Both README files are in English, as requested.
- **The user explicitly stopped image building. No image build or container
  startup validation was performed.** Build/run commands in the documentation
  are future instructions, not completed validation.
- Local static/unit checks passed. Real Linux execution remains unverified.
- Changes are uncommitted. Dockerfile was previously ignored by `.gitignore`;
  an exception now makes it visible to Git. No commit or push was performed.

## Findings

- `renv.lock` already records R 4.6.1 and 270 packages; no lockfile change was
  needed. The selected course dependency closure contains 156 packages.
- The old Dockerfile used a custom R 4.5 base and ended with `USER rstudio`.
  The local `.Rprofile` contains host-specific proxies, renv activation and
  all-core settings; it is preserved locally but excluded from the image.
- The current Day 1–3 course needs neither the legacy targets/GIF pipeline
  nor emo/devtools/clustermq. Existing figures/GIFs are included directly.
- Fourteen Stan sources exist. Build scripts compile thirteen; the legacy
  `mv_logistic.stan` has undefined generated-quantity variables and is excluded
  without inventing a replacement model. The deliberate `linear_bad` fit stays
  available for teaching diagnostics, not routine live sampling.
- All seven existing RDS files match current seeded data, recorded model names,
  CmdStan 2.38.0 and expected draw structure. They were generated under R 4.5.3
  and contain no source digest; exact generation-time Stan identity is unproved.
  RDS files remain gitignored and must be supplied separately after cloning.

## Decisions and reasoning

- Install the selected locked versions at build time into `/opt/afec/library`,
  using build-only renv 1.3.0 without pak, cache symlinks or sandboxing. Include
  tidyverse, posterior, bayesplot, patchwork, here, knitr, rmarkdown, kableExtra,
  cmdstanr, brms, lme4 and loo, plus required dependencies. Fail rather than
  silently upgrade incompatible Linux packages.
- CmdStan lives at `/opt/cmdstan/cmdstan-2.38.0`; executable/MD5 records live
  at `/opt/afec/models`. `course_model()` loads matching binaries with
  `compile=FALSE`. Edited Stan code cannot use stale binaries or stored results.
- Default to stored fits. In classroom mode, changed data/priors cause an error
  rather than a misleading default-data answer. Comparison tasks need explicit
  `use_precomputed=FALSE, fallback=FALSE` under instructor coordination.
  Statistical formulas, seeds, chain counts and iterations are unchanged.
- Use one parallel chain/thread and single-thread BLAS/OpenMP/RcppParallel
  defaults. These are not hard limits; Compose must enforce cgroup limits.
  Prefer small-group live fitting until capacity is measured.
- Retain Rocker's root `/init` startup and non-root student sessions;
  require `ROOT=FALSE`, authentication and a runtime password. Persist only
  `/home/rstudio/workspace`, not the full home directory.
- Publish the first starter copy atomically; never recopy an existing student
  course. Reject symlinks. Keep UID/GID stable. Image upgrades need deliberate
  workspace migration or a new volume, not automatic overwrite.
- During a future build, bundle MathJax/Stan logo/local Lato and remove remote
  font imports in image-derived materials only. Render slides from stored fits.
  Do not render exercise solutions from default fits when they change inputs;
  participants open QMDs and execute selected chunks.

## Files changed

- `Dockerfile`, `.dockerignore`, `.gitignore`, root `README.md`.
- `R/course_utils.R`: compiled-model lookup, thread default and classroom guards;
  existing non-classroom warning/fallback behavior remains available.
- `docker/package-plan.R`, `install-packages.R`, `build-course.R`,
  `check-fits.R`, `Rprofile.site`: image preparation/configuration.
- `docker/00-afec-guard.sh`, `03-afec-workspace.sh`: runtime initialization.
- `docker/verify.R`: future non-root image smoke test.
- `docker/test-static.R`: local checks without image builds/downloads/installs.
- `docker/README.md`, `START-HERE.md`: operations and participant guidance.

## Validation

Passed locally:

```bash
RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript docker/test-static.R
bash -n docker/00-afec-guard.sh
bash -n docker/03-afec-workspace.sh
git diff --check
```

Checks cover R parsing, the 156-package closure, seven RDS/data comparisons,
changed-data/stale-source rejection, authentication guards, Dockerfile invariants
and COPY source existence, and English README content. Workspace initialization
and preservation passed a filesystem simulation with chown/GNU-mv stubs;
this does not prove real volume permissions or restart persistence.

## Unresolved and next steps

- Unverified: base-image availability, apt/locked-package Linux compatibility,
  RStudio startup/login, compilation, executable shared libraries, non-root
  sampling/plotting, volume restart/recreation and offline browser display.
  The future build's `verify.R` hook has not run; its short sample would test
  execution only, not convergence. No 30-user load test was requested/performed.
- Draft exercise timing estimates are not shared-server measurements. Provisional
  limits of 1 CPU and 2–3 GiB per container need measurement; OOM remains possible.
  brms compilation is optional, not part of the precompiled core route.
- Base tags, apt repositories and the logo URL are mutable. Freeze the validated
  completed image digest; stronger source/base/apt pinning remains follow-up.
- Recheck stored-fit provenance and statistical diagnostics before teaching.
  Do not refit models or regenerate GIFs just to repeat already completed checks.
- Prepare Compose for 30 isolated volumes/accounts/ports, HTTPS or campus VPN,
  credential distribution, monitoring, backups and a classroom rehearsal.

## Best next action

Respect the current **do-not-build** instruction. Review `docker/README.md` and
the implementation first. After explicit authorization to build, validate one
fresh container on the target Ubuntu amd64 server, including outbound-blocked
execution and persistence, before preparing the 30-container deployment.
