#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

policy_file="skills/dotfiles/references/resume-handoff.md"
skill_file="skills/dotfiles/SKILL.md"

# shellcheck disable=SC2016 # The literal command text is the policy assertion.
for required in \
  '1 task = 1 Gist = 1 Markdown file' \
  'agent-task:<repo>:<task>' \
  'secret/unlisted' \
  'not access-controlled private storage' \
  'gh auth status' \
  'public=false' \
  'shasum -a 256' \
  'gh gist list --secret' \
  'per-Gist confirmation' \
  'Do not use `gh gist delete --yes`'; do
  grep -Fq -- "$required" "$policy_file" || {
    echo "missing required agent-task Gist policy text: $required" >&2
    exit 1
  }
done

grep -Fq -- 'optional portable agent task-memo Gists' "$skill_file" || {
  echo "dotfiles skill does not expose portable agent task-memo Gists" >&2
  exit 1
}

if grep -En '^[[:space:]]*gh gist (create|edit|list|delete).*--public' "$policy_file"; then
  echo "agent-task Gist policy offers a public-mode command path" >&2
  exit 1
fi

echo "agent-task Gist policy validation passed"
