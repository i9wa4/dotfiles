#!/usr/bin/env bash
set -euo pipefail

home=${HOME:?}

to_home_relative() {
  case "$1" in
  "$home"/*) printf '%c/%s' '~' "${1#"$home"/}" ;;
  *) printf '%s' "$1" ;;
  esac
}

escape_table_cell() {
  sed \
    -e 's/[[:space:]][[:space:]]*/ /g' \
    -e 's/^ //' \
    -e 's/ $//' \
    -e 's/|/\\|/g'
}

read_frontmatter() {
  awk '
    BEGIN {
      in_fm = 0
      capture_description = 0
      name = ""
      description = ""
    }
    NR == 1 && $0 == "---" {
      in_fm = 1
      next
    }
    in_fm && $0 == "---" {
      exit
    }
    !in_fm {
      next
    }
    /^name:[[:space:]]*/ {
      name = $0
      sub(/^name:[[:space:]]*/, "", name)
      gsub(/^"|"$/, "", name)
      capture_description = 0
      next
    }
    /^description:[[:space:]]*[>|][[:space:]]*$/ {
      capture_description = 1
      next
    }
    /^description:[[:space:]]*/ {
      description = $0
      sub(/^description:[[:space:]]*/, "", description)
      gsub(/^"|"$/, "", description)
      capture_description = 0
      next
    }
    capture_description && /^[[:space:]]+/ {
      line = $0
      sub(/^[[:space:]]+/, "", line)
      description = description (description == "" ? "" : " ") line
      next
    }
    capture_description {
      capture_description = 0
    }
    END {
      print name "\t" description
    }
  ' "$1"
}

emit_root() {
  local runtime=$1
  local root=$2

  [ -d "$root" ] || return 0

  find -L "$root" -mindepth 2 -maxdepth 2 -name SKILL.md -print |
    sort |
    while IFS= read -r skill_file; do
      IFS=$'\t' read -r name description < <(read_frontmatter "$skill_file")
      if [ -z "$name" ]; then
        name=$(basename "$(dirname "$skill_file")")
      fi
      if [ -z "$description" ]; then
        description="No description found in frontmatter."
      fi

      skill_path=$(to_home_relative "$skill_file")
      printf "| %s | \`%s\` | \`%s\` | %s |\n" \
        "$runtime" \
        "$(printf '%s' "$name" | escape_table_cell)" \
        "$(printf '%s' "$skill_path" | escape_table_cell)" \
        "$(printf '%s' "$description" | escape_table_cell)"
    done
}

cat <<'EOF'
# Agent Skill Index

Generated from installed user-level skill trees.

| Runtime | Skill | SKILL.md Path | Description |
| ------- | ----- | ------------- | ----------- |
EOF

emit_root "Codex CLI" "$home/.codex/skills"
emit_root "Claude Code" "$home/.claude/skills"
