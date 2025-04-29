#!/usr/bin/env bash
# This script annotates what it can, using 'buildkite-agent annotate'.
#
# NOTE: This script is intended to be run inside a Buildkite pipeline.

# Funcs.
die() { echo "$1" >&2; exit "${2:-1}"; }
usage() { echo "Usage: $0 <path-to-file>"; exit 64; }

# Check bash version.
[[ "${BASH_VERSION:0:1}" -lt 4 ]] \
  && die "Bash version 4+ required!"

# Check root.
[[ -d .git ]] \
  || die "'$0' must be run from the root directory."

# Check deps.
deps=(buildkite-agent)
for dep in "${deps[@]}"; do
  hash "$dep" 2>/dev/null || missing+=("$dep")
done
if [[ "${#missing[*]}" -gt 0 ]]; then
  [[ "${#missing[*]}" -gt 1 ]] && s="s"
  die "Missing dep${s}: ${missing[*]}"
fi

# Check file.
file="$1"
[[ -z "$file" ]] && usage
[[ -f "$file" ]] \
  || die "$file dosn't exist or is not readable!"

# Vars.
heading=$(basename "$file" .${file##*.}) # Removes path + extension.
heading="${heading^}"                    # Uppercases first character.

# Annotate file.
read -r -d '' msg <<- EOF
<h4>${heading}:</h4>
$(cat $file)
EOF
buildkite-agent annotate "$msg" --style "info" --context "$heading" \
  || die "Failed to annotate $file"

