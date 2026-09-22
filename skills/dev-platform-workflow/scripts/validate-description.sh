#!/usr/bin/env bash
# Verifies the parsed catalog description remains the public trigger contract.
set -euo pipefail

skill_path="${1:-skills/dev-platform-workflow/SKILL.md}"
description=$(ruby -ryaml -e '
  document = YAML.safe_load(File.read(ARGV.fetch(0)), aliases: true)
  puts document.fetch("description")
' "$skill_path")

case "$description" in
"USE FOR:"*) ;;
*)
  echo "FAIL: parsed description must begin with USE FOR:" >&2
  exit 1
  ;;
esac

case "$description" in
*"trigger grader"* | *"final enumerated phrase"*)
  echo "FAIL: parsed description contains maintenance-only trigger text" >&2
  exit 1
  ;;
esac

echo "parsed description: OK"
