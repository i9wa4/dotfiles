#!/usr/bin/env bash
set -euo pipefail

GHQ_BASE="${HOME}"/ghq/github.com
COMMON="./config.common.toml"
OUTPUT="./config.toml"

cd "$(dirname "$0")"

# Copy common settings
cp -f "${COMMON}" "${OUTPUT}"

# Add project-specific settings
find "${GHQ_BASE}" -maxdepth 3 -type d -name ".git" 2>/dev/null \
  | sed 's|\.git$||' \
  | sort \
  | while read -r repo; do
    [[ -z ${repo} ]] && continue
    echo "
[projects.\"${repo}\"]
trust_level = \"trusted\""
  done >>"${OUTPUT}"

echo "Generated: ${OUTPUT}"
