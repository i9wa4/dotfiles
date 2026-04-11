#!/usr/bin/env bash

set -eu

if [ "$#" -ne 1 ]; then
  echo "usage: validate-skill-frontmatter.sh <skill-root>|--staged" >&2
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

while IFS= read -r skill; do
  awk '
    BEGIN {
      state = "need_open"
      failed = 0
      in_code_fence = 0
      seen_name = 0
      seen_description = 0
      late_name = 0
      late_description = 0
      late_description_block = 0
    }
    state == "need_open" {
      if ($0 != "---") {
        failed = 1
        printf "%s: first line must be ---\n", FILENAME > "/dev/stderr"
        exit 1
      }
      state = "frontmatter"
      next
    }
    state == "frontmatter" {
      if ($0 == "---") {
        if (!seen_name) {
          failed = 1
          printf "%s: frontmatter missing name:\n", FILENAME > "/dev/stderr"
          exit 1
        }
        if (!seen_description) {
          failed = 1
          printf "%s: frontmatter missing description:\n", FILENAME > "/dev/stderr"
          exit 1
        }
        state = "body"
        next
      }
      if ($0 ~ /^name:[[:space:]]/) {
        seen_name = 1
      }
      if ($0 ~ /^description:/) {
        seen_description = 1
      }
      next
    }
    state == "body" {
      if ($0 ~ /^```/ || $0 ~ /^~~~/) {
        in_code_fence = !in_code_fence
        next
      }
      if (in_code_fence) {
        next
      }
      if ($0 == "---") {
        state = "late_frontmatter"
        late_name = 0
        late_description = 0
        late_description_block = 0
        next
      }
      next
    }
    state == "late_frontmatter" {
      if (late_description_block) {
        if ($0 == "" || $0 ~ /^[ \t]/) {
          next
        }
        late_description_block = 0
      }
      if ($0 ~ /^```/ || $0 ~ /^~~~/) {
        in_code_fence = 1
        state = "body"
        next
      }
      if ($0 == "---") {
        if (late_name && late_description) {
          failed = 1
          printf "%s: duplicate frontmatter block detected\n", FILENAME > "/dev/stderr"
          exit 1
        }
        state = "body"
        next
      }
      if ($0 == "") {
        next
      }
      if ($0 ~ /^name:[[:space:]]/) {
        late_name = 1
        next
      }
      if ($0 ~ /^description:[[:space:]]*[>|]/) {
        late_description = 1
        late_description_block = 1
        next
      }
      if ($0 ~ /^description:/) {
        late_description = 1
        next
      }
      if ($0 ~ /^[A-Za-z0-9_-]+:[[:space:]]*/) {
        next
      }
      state = "body"
      next
    }
    END {
      if (!failed && state == "frontmatter") {
        printf "%s: frontmatter not closed\n", FILENAME > "/dev/stderr"
        exit 1
      }
      if (!failed && state == "late_frontmatter" && late_name && late_description) {
        printf "%s: duplicate frontmatter block detected\n", FILENAME > "/dev/stderr"
        exit 1
      }
    }
  ' "$skill"
done <"$skill_list"
