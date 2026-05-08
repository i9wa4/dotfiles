#!/usr/bin/env bash
# Checks that skill description fits within the 138-char catalog display threshold.
# Usage: validate-skill-description-length.sh <skill-root>|--staged
# Toggle: SKILL_DESC_LENGTH_STRICT=1 -> exit 1 on violations (block mode)
#         default: print warnings and exit 0 (warn-only mode)

set -eu

MAX_LEN=138
STRICT="${SKILL_DESC_LENGTH_STRICT:-0}"

if [ "$#" -ne 1 ]; then
  echo "usage: validate-skill-description-length.sh <skill-root>|--staged" >&2
  exit 64
fi

skill_list=$(mktemp)
staged_list=
trap 'rm -f "$skill_list"; if [ -n "${staged_list:-}" ]; then rm -f "$staged_list"; fi' EXIT HUP INT TERM

if [ "$1" = "--staged" ]; then
  staged_list=$(mktemp)
  git diff --cached --name-only --diff-filter=ACM >"$staged_list"
  while IFS= read -r path; do
    if [ "${path##*/}" != "SKILL.md" ]; then
      continue
    fi
    if [ ! -f "$path" ]; then
      continue
    fi
    printf '%s\n' "$path" >>"$skill_list"
  done <"$staged_list"
else
  root=$1
  find -L "$root" -name SKILL.md -print >"$skill_list"
fi

violations=0

while IFS= read -r skill; do
  desc_len=$(awk '
    BEGIN {
      state = "need_open"
      desc = ""
      done = 0
    }
    done { next }
    state == "need_open" {
      if ($0 == "---") { state = "frontmatter" }
      next
    }
    state == "frontmatter" {
      if ($0 == "---") { done = 1; next }
      if ($0 ~ /^description:[[:space:]]*[>|]/) {
        state = "block"
        next
      }
      if ($0 ~ /^description:[[:space:]]/) {
        line = $0
        sub(/^description:[[:space:]]+/, "", line)
        desc = line
        done = 1
        next
      }
      next
    }
    state == "block" {
      if ($0 ~ /^[[:space:]]/) {
        line = $0
        sub(/^[[:space:]]+/, "", line)
        if (desc != "") desc = desc " "
        desc = desc line
        next
      }
      done = 1
      next
    }
    END { print length(desc) }
  ' "$skill")
  if [ -n "$desc_len" ] && [ "$desc_len" -gt "$MAX_LEN" ]; then
    violations=$((violations + 1))
    if [ "$STRICT" = "1" ]; then
      printf 'FAIL: %s: description %d chars exceeds %d-char limit\n' "$skill" "$desc_len" "$MAX_LEN" >&2
    else
      printf 'WARN: %s: description %d chars exceeds %d-char catalog threshold (set SKILL_DESC_LENGTH_STRICT=1 to block)\n' "$skill" "$desc_len" "$MAX_LEN"
    fi
  fi
done <"$skill_list"

if [ "$violations" -gt 0 ] && [ "$STRICT" = "1" ]; then
  exit 1
fi
exit 0
