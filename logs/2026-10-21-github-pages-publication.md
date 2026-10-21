# AFEC-X 2026: merge, GitHub Pages and README

2026-10-21

## Goal

Merge the current course from `dev` into `main`, publish the participant
materials on GitHub Pages, and replace the long legacy README with a concise
introduction to AFEC-X 2026.

## Current state

- Live site: <https://mattocci27.github.io/afec-bayes-2026/>.
- Pages publishes from `gh-pages`, `/ (root)`, with `.nojekyll`.
- `dev` was fast-forward merged into `main` at `14086c0`; both branches were
  pushed. Subsequent website/README changes are on `main`.
- At handoff, `main` and `origin/main` are at `87a4a99`; `dev` and `origin/dev`
  remain at `14086c0`.
- Published files are at `b452a92` on `gh-pages`. The ignored `_site/` directory
  is a separate local Git checkout tracking that branch.
- GitHub's earlier “Confirm access” interruption is resolved. Pages settings
  were saved and the site was verified live; no authentication step remains.

## Decisions and files changed

- Use the existing repository and a separate publication branch. The user
  accepted public repository access, including instructor sources and logs.
- Added `classroom/site-index.html`: a short English landing page linking to
  each day's slides, participant exercise and prepared results, plus readiness
  information and the participant ZIP.
- Added `scripts/build_pages.py`: stages website files from the existing
  participant ZIP and the landing page. It checks required pages and that
  packaged slides match the current HTML. It requires an empty output directory.
- Added `_site/` to `.gitignore`.
- Replaced the old 2025 README introduction and accumulated validation history
  with a short AFEC-X 2026 README: dates, learning aim, materials, setup links,
  basic build commands, instructor documentation and licence.
- Removed `1 AFEC-X 2026_schedule 261015.pdf` from `main` at the user's request
  and pushed that deletion. The publication branch does not contain this PDF.
- No teaching models, data or inference settings changed; no refitting ran.

## Validation

- Checked common secret patterns in tracked history and reviewed credential
  file handling; no matching API keys or private keys were found. This was a
  focused check, not a complete security audit.
- The staged website had no missing local HTML resource/link targets.
- Inspected the landing page locally and the published Day 2 PPC slide in a
  browser; its figure and text displayed correctly.
- Verified HTTP 200 responses for the landing page, all nine daily material
  pages, readiness, the PPC image and the participant ZIP. The ZIP's served
  content length matched the local archive.
- Source whitespace checks passed. `main` and the local publication checkout
  were clean before writing this log.

## Updating the website

Pushing changes to `main` does **not** update the website automatically.
The current manual workflow is:

1. Edit the course source on `main`.
2. Run `make materials` using existing fits to refresh HTML and the participant
   ZIP. Daily builds alone do not refresh the ZIP.
3. Run `python3 scripts/build_pages.py --output /path/to/empty-directory`.
4. Update the existing `gh-pages` branch with the staged files and push it.
   GitHub then deploys that branch automatically.

The staging script does not commit, push or configure GitHub Pages. Do not
replace `gh-pages` with a new orphan history for routine updates.

## Remaining issues and next steps

- No further work is required for the initial publication.
- Automatic deployment from `main` was discussed but was not requested or
  implemented. If requested later, decide how Actions obtains the gitignored
  `fits/*.rds` and produces current HTML/ZIP before adding a workflow.
- The schedule PDF remains in older commits and in the existing `dev` branch.
  Only the current `main` copy was deleted; no history rewrite was requested.
- Bring the website/README changes back into `dev` before continuing development
  there, so future edits retain the publication workflow and PDF deletion.
