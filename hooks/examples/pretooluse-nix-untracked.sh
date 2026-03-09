#!/usr/bin/env bash

# PreToolUse hook: warn if untracked files exist before nix build/flake check.
#
# Nix flakes only see git-tracked files. Running nix build with untracked
# files causes silent build failures.
#
# Install: reference this script in ~/.claude/settings.json (see .json sibling)
# Behavior: exit 2 (block) if nix build/flake check + untracked files detected

input=$(cat)
cmd=$(printf '%s' "$input" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('command', ''))" 2>/dev/null)

if printf '%s' "$cmd" | grep -qE 'nix (build|flake check)'; then
  untracked=$(git status --short 2>/dev/null | grep '^?' | awk '{print $2}')
  if [ -n "$untracked" ]; then
    printf 'BLOCKED: Untracked files detected. Stage them first:\n'
    printf '  git add <files>\n\n'
    printf 'Untracked:\n'
    printf '%s\n' "$untracked"
    exit 2
  fi
fi
