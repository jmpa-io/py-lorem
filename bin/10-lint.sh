#!/usr/bin/env bash
# This script lints whatever it can in this repository!

# Funcs.
die() { echo "$1" >&2; exit "${2:-1}"; }

# Check root.
[[ -d .git ]] \
  || die "'$0' must be run from the root directory."

# Check deps.
deps=(find docker)
for dep in "${deps[@]}"; do 
  hash "$dep" 2>/dev/null || missing+=("$dep")
done
if [[ "${#missing[*]}" -gt 0 ]]; then
  [[ "${#missing[*]}" -gt 1 ]] && s="s"
  die "Missing dep${s}: ${missing[*]}"
fi

# Setup error checking.
errors=0

# Lint Dockerfiles.
echo "~~~ :docker: Lint Dockerfiles."
find . -name Dockerfile | while read -r file; do
  docker run --rm -i hadolint/hadolint < "$file" \
    || ((errors++)) 
done

# Lint *.sh scripts.
echo "~~~ :terminal: Lint *.sh scripts."
find . -name '*.sh' -exec docker run --rm -it -v "$PWD:/mnt" koalaman/shellcheck:stable {} + \
  || ((errors++))

# Lint Python files.
echo "~~~ :python: Lint Python files."
docker run --rm -v "$PWD:/app" -w /app ghcr.io/astral-sh/ruff check \
  || ((errors++))

# Check any errors.
[[ "${errors}" -gt 0 ]] \
  && die "~~~ :warning: Found linting error(s); See above! :point_up::skin-tone-2:"

