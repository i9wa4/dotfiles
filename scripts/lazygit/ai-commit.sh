#!/usr/bin/env bash

set -u

temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/lazygit-ai-commit.XXXXXX") || exit 1
editor=$temp_dir/editor
staged_diff=$temp_dir/staged-diff
ai_message=$temp_dir/ai-message
ai_stderr=$temp_dir/ai-stderr

cleanup() {
  rm -f -- "$editor" "$staged_diff" "$ai_message" "$ai_stderr"
  rmdir -- "$temp_dir"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

staged_tree=$(git write-tree) || exit 1
git diff --cached --no-ext-diff >"$staged_diff" || exit 1
if [ "$(git write-tree)" != "$staged_tree" ]; then
  printf '%s\n' 'Staged changes changed while preparing the AI prompt; no commit created.' >&2
  exit 1
fi
: >"$ai_message"

cat >"$editor" <<'AI_COMMIT_EDITOR'
#!/usr/bin/env bash
set -u

check_staged_tree() {
  current_tree=$(git write-tree) || exit 1
  if [ "$current_tree" != "$LAZYGIT_AI_COMMIT_TREE" ]; then
    printf '%s\n' 'Staged changes changed after AI generation; no commit created.' >&2
    exit 1
  fi
}

check_staged_tree
vim "$1" || exit $?
check_staged_tree
AI_COMMIT_EDITOR
chmod +x "$editor"

if command -v codex >/dev/null 2>&1; then
  prompt='Generate ONLY a one-line Git commit message following Conventional Commits format (type(scope): description). Types: feat, fix, docs, style, refactor, test, chore. Based strictly on the diff from stdin. Output ONLY the message, nothing else.'
  if codex exec --ephemeral --ignore-rules --sandbox read-only -c approval_policy='"never"' -c model_reasoning_effort='"low"' --color never --output-last-message "$ai_message" "$prompt" <"$staged_diff" >/dev/null 2>"$ai_stderr"; then
    message=$(head -n 1 "$ai_message")
    if printf '%s\n' "$message" | grep -Eq '^(feat|fix|docs|style|refactor|test|chore)(\([[:alnum:]_.-]+\))?: [^[:space:]].*$'; then
      printf '%s\n' "$message" >"$ai_message"
    else
      : >"$ai_message"
      printf '%s\n' 'AI commit message was empty or malformed; opening editor without a suggestion.' >&2
    fi
  else
    status=$?
    if [ "$status" -eq 130 ] || [ "$status" -eq 143 ]; then
      printf '%s\n' 'AI commit message generation was interrupted; no commit created.' >&2
      exit "$status"
    fi
    : >"$ai_message"
    printf '%s\n' 'AI commit message generation failed; opening editor without a suggestion.' >&2
    cat "$ai_stderr" >&2
  fi
else
  printf '%s\n' 'codex not found; opening editor without an AI suggestion.' >&2
fi

if [ "$(git write-tree)" != "$staged_tree" ]; then
  printf '%s\n' 'Staged changes changed during AI generation; no commit created.' >&2
  exit 1
fi

LAZYGIT_AI_COMMIT_TREE="$staged_tree" GIT_EDITOR="$editor" git commit --edit --file "$ai_message"
