#!/usr/bin/env bash
# Host-side helper: generate credentials without starting Docker.
# Usage: bash docker/create-student-env.sh [dedicated-credentials-directory]
set -euo pipefail
umask 077
command -v openssl >/dev/null || {
  echo "openssl is required to generate random passwords" >&2; exit 1;
}
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
credentials_dir=${1:-"$script_dir/../.afec-credentials"}
[[ ! -L "$credentials_dir" ]] || {
  echo "Credentials directory must not be a symlink" >&2; exit 1;
}
mkdir -p "$credentials_dir"
credentials_dir=$(cd -- "$credentials_dir" && pwd)
[[ "$credentials_dir" != / && "$credentials_dir" != "$script_dir/.." && "$credentials_dir" != "$(cd -- "$script_dir/.." && pwd)" ]] || {
  echo "Use a dedicated credentials directory" >&2; exit 1;
}
chmod 700 "$credentials_dir"
created=0
kept=0
for ((i=1; i<=30; i++)); do
  printf -v student_id 'student%02d' "$i"
  file="$credentials_dir/$student_id.env"
  [[ ! -L "$file" ]] || {
    echo "Refusing a symlink: $file" >&2; exit 1;
  }
  if [[ -e "$file" ]]; then
    [[ -f "$file" ]] || { echo "Expected a credential file: $file" >&2; exit 1; }
    chmod 600 "$file"
    kept=$((kept + 1))
    continue
  fi
  student_password=$(openssl rand -hex 24)
  # noclobber also protects a file created concurrently after the existence check.
  (set -o noclobber; printf 'PASSWORD=%s\n' "$student_password" > "$file")
  unset student_password
  created=$((created + 1))
done
printf 'Credentials: %s\nCreated %d files; kept %d existing files.\n' "$credentials_dir" "$created" "$kept"
printf 'Passwords were not printed. Keep these files private and distribute individually.\n'
