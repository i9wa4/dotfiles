#!/usr/bin/env bash
# Reports whether checked-in Agent Skills are ready for release-all publishing.
# Usage:
#   validate-skill-release-readiness.sh [--strict] [classification-yaml]

set -eu

usage() {
  echo "usage: validate-skill-release-readiness.sh [--strict] [classification-yaml]" >&2
}

strict=0
classification=skills/classification.yaml

while [ "$#" -gt 0 ]; do
  case "$1" in
  --strict)
    strict=1
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
    classification=$1
    shift
    ;;
  esac
done

if [ ! -f "$classification" ]; then
  echo "FAIL: classification file not found: $classification" >&2
  exit 1
fi

release_all_target=$(awk '$1 == "release_all_target:" { print $2; exit }' "$classification")
selective_release_allowlist=$(awk '$1 == "selective_release_allowlist:" { print $2; exit }' "$classification")

if [ "$release_all_target" != "true" ]; then
  echo "FAIL: policy.release_all_target must be true" >&2
  exit 1
fi

if [ "$selective_release_allowlist" != "false" ]; then
  echo "FAIL: policy.selective_release_allowlist must be false" >&2
  exit 1
fi

rows=$(mktemp)
blockers=$(mktemp)
trap 'rm -f "$rows" "$blockers"' EXIT HUP INT TERM

awk '
  function value_after_colon(line) {
    sub(/^[^:]+:[[:space:]]*/, "", line)
    return line
  }

  function flush() {
    if (name == "") {
      return
    }
    printf "%s\t%s\t%s\t%s\t%s\n", name, path, publish, release_state, personal_content_action
  }

  BEGIN {
    in_skills = 0
    name = ""
    path = ""
    publish = ""
    release_state = ""
    personal_content_action = ""
  }

  /^skills:[[:space:]]*$/ {
    in_skills = 1
    next
  }

  in_skills && /^  - name:/ {
    flush()
    name = value_after_colon($0)
    path = ""
    publish = ""
    release_state = ""
    personal_content_action = ""
    next
  }

  in_skills && name != "" && /^    path:/ {
    path = value_after_colon($0)
    next
  }

  in_skills && name != "" && /^    publish:/ {
    publish = value_after_colon($0)
    next
  }

  in_skills && name != "" && /^    release_state:/ {
    release_state = value_after_colon($0)
    next
  }

  in_skills && name != "" && /^    personal_content_action:/ {
    personal_content_action = value_after_colon($0)
    next
  }

  END {
    flush()
  }
' "$classification" >"$rows"

if [ ! -s "$rows" ]; then
  echo "FAIL: no skills found in $classification" >&2
  exit 1
fi

total=0
publish_true=0
release_ready=0
tab=$(printf '\t')

while IFS="$tab" read -r name path publish release_state personal_content_action; do
  total=$((total + 1))

  case "$publish" in
  true)
    publish_true=$((publish_true + 1))
    if [ "$release_state" != "release_ready" ]; then
      printf '%s: publish=true requires release_state=release_ready, got %s\n' "$name" "${release_state:-missing}" >>"$blockers"
    fi
    if [ "$personal_content_action" != "scanned_release_ready" ]; then
      printf '%s: publish=true requires personal_content_action=scanned_release_ready, got %s\n' "$name" "${personal_content_action:-missing}" >>"$blockers"
    fi
    if [ -z "$path" ]; then
      printf '%s: publish=true requires path\n' "$name" >>"$blockers"
    elif [ ! -f "$path/SKILL.md" ]; then
      printf '%s: publish=true path is missing SKILL.md at %s/SKILL.md\n' "$name" "$path" >>"$blockers"
    fi
    if [ "$release_state" = "release_ready" ] && [ "$personal_content_action" = "scanned_release_ready" ]; then
      release_ready=$((release_ready + 1))
    fi
    ;;
  false)
    case "$release_state" in
    demoted_compatibility_trigger | removed_before_release | release_excluded) ;;
    *)
      printf '%s: publish=false must be demoted, removed, or release_excluded before release, got %s\n' "$name" "${release_state:-missing}" >>"$blockers"
      ;;
    esac
    ;;
  *)
    printf '%s: publish must be true or false, got %s\n' "$name" "${publish:-missing}" >>"$blockers"
    ;;
  esac
done <"$rows"

if [ -s "$blockers" ]; then
  echo "skill release readiness: BLOCKED"
  echo "skills tracked: $total"
  echo "publish=true skills: $publish_true"
  echo "release-ready publish=true skills: $release_ready"
  sed 's/^/- /' "$blockers" >&2
  if [ "$strict" -eq 1 ]; then
    exit 1
  fi
  exit 0
fi

echo "skill release readiness: OK"
echo "skills tracked: $total"
echo "publish=true skills: $publish_true"
echo "release-ready publish=true skills: $release_ready"
