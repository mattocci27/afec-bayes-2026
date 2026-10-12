#!/usr/bin/with-contenv bash
set -euo pipefail
# Before Rocker's 02_userconf, to avoid generating/logging a random password.
[[ "${ROOT:-FALSE}" == FALSE && "${DISABLE_AUTH:-FALSE}" == FALSE ]] || {
  echo "AFEC: require ROOT=FALSE and DISABLE_AUTH=FALSE" >&2; exit 1;
}
[[ "${DEFAULT_USER:-rstudio}" == rstudio && "${RUNROOTLESS:-false}" != true ]] || {
  echo "AFEC: keep the default rstudio account and root /init startup" >&2; exit 1;
}
[[ -n "${PASSWORD:-}" ]] || {
  echo "AFEC: supply a unique PASSWORD at runtime (never in the image)" >&2; exit 1;
}
