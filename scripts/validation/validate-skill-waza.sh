#!/usr/bin/env bash
# Validates changed skill directories with Waza readiness checks.
# Usage:
#   validate-skill-waza.sh <changed-path>...
#   validate-skill-waza.sh --staged

set -eu

if [ "$#" -eq 0 ]; then
  exit 0
fi

waza_bin="${WAZA_BIN:-waza}"
jq_bin="${JQ_BIN:-jq}"
skill_list=$(mktemp)
path_list=
if [ "${SKILL_WAZA_CHECK_LINKS:-1}" = "0" ]; then
  gate_filter='
    all(.skills[];
      (((.compliance.issues // []) | length) == 0)
      and (all((.specCompliance // [])[]; .passed == true))
      and (.tokenBudget.exceeded == false)
    )
  '
else
  gate_filter='
    all(.skills[];
      (((.compliance.issues // []) | length) == 0)
      and (all((.specCompliance // [])[]; .passed == true))
      and ((.links.passed == true) or ((.links.valid // -1) == (.links.total // -2)))
      and (.tokenBudget.exceeded == false)
    )
  '
fi
trap 'rm -f "$skill_list"; if [ -n "${path_list:-}" ]; then rm -f "$path_list"; fi' EXIT HUP INT TERM

append_skill_for_path() {
  path=$1
  rest=
  skill_name=
  skill_dir=

  path=${path#./}
  case "$path" in
  skills/*/*)
    rest=${path#skills/}
    skill_name=${rest%%/*}
    skill_dir="skills/${skill_name}"
    if [ -f "${skill_dir}/SKILL.md" ]; then
      printf '%s\n' "$skill_dir" >>"$skill_list"
    fi
    ;;
  esac
}

if [ "$1" = "--staged" ]; then
  if [ "$#" -ne 1 ]; then
    echo "usage: validate-skill-waza.sh --staged" >&2
    exit 64
  fi
  path_list=$(mktemp)
  git diff --cached --name-only --diff-filter=ACMR >"$path_list"
  while IFS= read -r path; do
    append_skill_for_path "$path"
  done <"$path_list"
else
  for path in "$@"; do
    append_skill_for_path "$path"
  done
fi

sort -u "$skill_list" -o "$skill_list"

if [ ! -s "$skill_list" ]; then
  exit 0
fi

while IFS= read -r skill_dir; do
  echo "waza check: ${skill_dir}"
  json=$("$waza_bin" --no-update-check check "$skill_dir" --format json)
  if ! printf '%s\n' "$json" | "$jq_bin" -e "$gate_filter" >/dev/null; then
    echo "FAIL: ${skill_dir}: Waza validation failed" >&2
    printf '%s\n' "$json" | "$jq_bin" -r '
      .skills[]
      | "  \(.name): ready=\(.ready) compliance=\(.compliance.level) failedSpec=\(([.specCompliance[]? | select(.passed != true) | .name] | join(","))) links=\(.links.valid)/\(.links.total) token=\(.tokenBudget.status)"
    ' >&2
    exit 1
  fi
done <"$skill_list"
