#!/usr/bin/env bash
# codex-stop-save.sh - Lightweight handoff saver for Codex CLI
#
# Hook: Stop
#
# Codex CLI does not currently expose a PreCompact-style hook, so Stop is used
# to save a resumable handoff snapshot at the end of each turn.
set -o errexit
set -o nounset
set -o pipefail
set -o posix

INPUT_JSON=$(cat)
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SESSION_ENV_DIR="${CODEX_HOME}/session-env"

mkdir -p "$SESSION_ENV_DIR"

HOOK_CWD=$(printf '%s' "$INPUT_JSON" | jq -r '.cwd // empty' 2>/dev/null) || true
HOOK_SESSION_ID=$(printf '%s' "$INPUT_JSON" | jq -r '.session_id // empty' 2>/dev/null) || true
TRANSCRIPT_PATH=$(printf '%s' "$INPUT_JSON" | jq -r '.transcript_path // empty' 2>/dev/null) || true
LAST_ASSISTANT_MESSAGE=$(printf '%s' "$INPUT_JSON" | jq -r '.last_assistant_message // empty' 2>/dev/null) || true

if [ -z "$HOOK_CWD" ]; then
  HOOK_CWD="$PWD"
fi

PROJECT_KEY="$(printf '%s' "$HOOK_CWD" | sed -E 's/[^[:alnum:]]+/-/g; s/-+$//')"
LATEST_STATE_FILE="${SESSION_ENV_DIR}/handoff-${PROJECT_KEY}-latest.md"
SESSION_STATE_FILE=""

if [ -n "$HOOK_SESSION_ID" ]; then
  SESSION_STATE_FILE="${SESSION_ENV_DIR}/handoff-${PROJECT_KEY}-${HOOK_SESSION_ID}.md"
fi

if [ -d "$HOOK_CWD" ]; then
  cd "$HOOK_CWD"
fi

GIT_STATUS="$(git --no-optional-locks status --short 2>/dev/null || echo "(not a git repo)")"
RECENT_COMMITS="$(git log --oneline -5 2>/dev/null || echo "(no commits)")"
CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || echo "(detached HEAD or not git)")"

TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

{
  echo "# Codex Session Handoff"
  echo ""
  echo "Timestamp: $(date +%Y-%m-%dT%H:%M:%S%z)"
  echo ""
  echo "Session ID: ${HOOK_SESSION_ID:-unknown}"
  echo ""
  echo "Working Directory: $HOOK_CWD"
  echo ""
  echo "Transcript: ${TRANSCRIPT_PATH:-not found}"
  echo ""
  echo "## Latest Assistant Message"
  echo ""
  if [ -n "$LAST_ASSISTANT_MESSAGE" ]; then
    printf '%s\n' "$LAST_ASSISTANT_MESSAGE"
  else
    echo "No assistant summary captured."
  fi
  echo ""
  echo "## Next Action"
  echo ""
  echo "Resume from the latest assistant message and git state below."
  echo ""
  echo "## Git Status"
  echo ""
  echo '```'
  printf '%s\n' "$GIT_STATUS"
  echo '```'
  echo ""
  echo "## Recent Commits"
  echo ""
  echo '```'
  printf '%s\n' "$RECENT_COMMITS"
  echo '```'
  echo ""
  echo "## Current Branch"
  echo ""
  echo '```'
  printf '%s\n' "$CURRENT_BRANCH"
  echo '```'
} >"$TMP_FILE"

cp "$TMP_FILE" "$LATEST_STATE_FILE"
if [ -n "$SESSION_STATE_FILE" ]; then
  cp "$TMP_FILE" "$SESSION_STATE_FILE"
fi

printf '{}\n'
