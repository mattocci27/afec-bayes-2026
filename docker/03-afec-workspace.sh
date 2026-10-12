#!/usr/bin/with-contenv bash
set -euo pipefail

# Runs after Rocker sets the student UID/GID; /init and rserver stay unchanged.
workspace=/home/rstudio/workspace
course="$workspace/afec-bayes-2026"
template=/opt/afec/template
mkdir -p "$workspace"
chown rstudio:rstudio "$workspace"
if [[ -L "$course" ]]; then
  echo "AFEC: existing workspace course must be a real directory" >&2
  exit 1
elif [[ ! -e "$course" ]]; then
  # Copy into the same volume, then atomically publish the complete course.
  stage=$(mktemp -d "$workspace/.afec-init.XXXXXXXX")
  cp -a "$template/." "$stage/"
  chmod -R u+rwX "$stage"
  chown -R rstudio:rstudio "$stage"
  mv -T "$stage" "$course"
elif [[ ! -d "$course" ]]; then
  echo "AFEC: existing workspace course must be a real directory" >&2
  exit 1
fi
# Never recopy, replace, chmod or recursively chown an existing student course.
# Keep non-persistent IDE state under HOME, outside the mounted workspace.
mkdir -p /home/rstudio/.config/rstudio
if [[ ! -e /home/rstudio/.config/rstudio/rstudio-prefs.json ]]; then
  printf '%s\n' '{"initial_working_directory":"/home/rstudio/workspace/afec-bayes-2026","restore_last_project":false}' \
    > /home/rstudio/.config/rstudio/rstudio-prefs.json
  chown -R rstudio:rstudio /home/rstudio/.config/rstudio
fi
