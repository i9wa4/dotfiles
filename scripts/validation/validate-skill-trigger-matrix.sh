#!/usr/bin/env bash
# Validates the Agent Skills trigger matrix added for consolidated skill checks.
# Usage:
#   validate-skill-trigger-matrix.sh [--strict-results] [matrix-json]

set -eu

usage() {
  echo "usage: validate-skill-trigger-matrix.sh [--strict-results] [matrix-json]" >&2
}

strict_results=0
matrix=skills/trigger-validation.json

while [ "$#" -gt 0 ]; do
  case "$1" in
  --strict-results)
    strict_results=1
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  --*)
    usage
    exit 64
    ;;
  *)
    matrix=$1
    shift
    ;;
  esac
done

if [ ! -f "$matrix" ]; then
  echo "FAIL: trigger matrix not found: $matrix" >&2
  exit 1
fi

if ! jq empty "$matrix" >/dev/null; then
  echo "FAIL: trigger matrix is not valid JSON: $matrix" >&2
  exit 1
fi

required_groups='agent-harness-engineering agent-skills-management github create-review-comment subagent-review plan-design data-platform diagramming programming technical-writing'

if ! jq -e '
  .schema_version == 1
  and .issue == 178
  and (.procedure_doc | type == "string")
  and (.target_groups | type == "array")
  and all(.target_groups[]; . as $group |
    (.target_group | type == "string")
    and (.target_skill | type == "string")
    and (.target_path | type == "string")
    and (.legacy_skills | type == "array")
    and (.trigger_cases | type == "array")
    and (.trigger_cases | length > 0)
    and any($group.trigger_cases[]; .kind == "target" and .expected_skill == $group.target_skill)
    and all($group.legacy_skills[]; . as $legacy |
      (.name | type == "string")
      and (.status | type == "string")
      and any($group.trigger_cases[]; .legacy_skill? == $legacy.name)
    )
    and all($group.trigger_cases[]; . as $case |
      (.id | type == "string")
      and (.kind | type == "string")
      and (.prompt | type == "string")
      and (.expected_skill | type == "string")
      and (.result | type == "string")
      and ((["pending", "pass", "fail", "blocked"] | index($case.result)) != null)
    )
  )
' "$matrix" >/dev/null; then
  echo "FAIL: trigger matrix schema validation failed: $matrix" >&2
  exit 1
fi

group_list=$(mktemp)
path_list=$(mktemp)
trap 'rm -f "$group_list" "$path_list"' EXIT HUP INT TERM

jq -r '.target_groups[].target_group' "$matrix" | sort >"$group_list"

for group in $required_groups; do
  count=$(grep -cx "$group" "$group_list" || true)
  if [ "$count" -ne 1 ]; then
    echo "FAIL: expected exactly one trigger matrix target group for $group" >&2
    exit 1
  fi
done

while IFS= read -r group; do
  case " $required_groups " in
  *" $group "*) ;;
  *)
    echo "FAIL: unexpected trigger matrix target group: $group" >&2
    exit 1
    ;;
  esac
done <"$group_list"

jq -r '.target_groups[] | [.target_skill, .target_path] | @tsv' "$matrix" >"$path_list"

while IFS="$(printf '\t')" read -r target_skill target_path; do
  if [ ! -f "$target_path" ]; then
    echo "FAIL: target skill path does not exist for $target_skill: $target_path" >&2
    exit 1
  fi

  frontmatter_name=$(
    awk '
      BEGIN { in_fm = 0 }
      NR == 1 && $0 == "---" { in_fm = 1; next }
      in_fm && $0 == "---" { exit }
      in_fm && $0 ~ /^name:[[:space:]]/ {
        sub(/^name:[[:space:]]*/, "", $0)
        print $0
        exit
      }
    ' "$target_path"
  )

  if [ "$frontmatter_name" != "$target_skill" ]; then
    echo "FAIL: $target_path frontmatter name '$frontmatter_name' does not match target '$target_skill'" >&2
    exit 1
  fi
done <"$path_list"

if [ "$strict_results" -eq 1 ]; then
  if ! jq -e '
    all(.target_groups[].trigger_cases[];
      .result == "pass"
      and (.observed_skill | type == "string")
      and (.observed_skill == .expected_skill)
      and (.checked_at | type == "string")
      and (.checked_at | length > 0)
      and (.validation_method | type == "string")
      and (.validation_method | length > 0)
    )
  ' "$matrix" >/dev/null; then
    echo "FAIL: strict trigger validation requires every case to pass with matching observed_skill, checked_at, and validation_method" >&2
    exit 1
  fi
fi

echo "skill trigger matrix: OK"
