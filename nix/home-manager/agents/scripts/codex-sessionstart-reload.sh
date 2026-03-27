#!/usr/bin/env bash
# codex-sessionstart-reload.sh - Saved handoff reloader for Codex CLI
#
# Hook: SessionStart
# Matcher: startup|resume
#
# Outputs JSON with additionalContext when a saved handoff exists.
set -o errexit
set -o nounset
set -o pipefail
set -o posix

INPUT_JSON=$(cat)
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SESSION_ENV_DIR="${CODEX_HOME}/session-env"

HOOK_CWD=$(printf '%s' "$INPUT_JSON" | jq -r '.cwd // empty' 2>/dev/null) || true
HOOK_SESSION_ID=$(printf '%s' "$INPUT_JSON" | jq -r '.session_id // empty' 2>/dev/null) || true
HOOK_SOURCE=$(printf '%s' "$INPUT_JSON" | jq -r '.source // empty' 2>/dev/null) || true

if [ -z "$HOOK_CWD" ]; then
  HOOK_CWD="$PWD"
fi

PROJECT_KEY="$(printf '%s' "$HOOK_CWD" | sed -E 's/[^[:alnum:]]+/-/g; s/-+$//')"
HANDOFF_FILE="${SESSION_ENV_DIR}/handoff-${PROJECT_KEY}-latest.md"

if [ -n "$HOOK_SESSION_ID" ] && [ -f "${SESSION_ENV_DIR}/handoff-${PROJECT_KEY}-${HOOK_SESSION_ID}.md" ]; then
  HANDOFF_FILE="${SESSION_ENV_DIR}/handoff-${PROJECT_KEY}-${HOOK_SESSION_ID}.md"
fi

if [ ! -f "$HANDOFF_FILE" ]; then
  exit 0
fi

TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

{
  echo "# Saved Handoff Context"
  echo ""
  echo "SessionStart source: ${HOOK_SOURCE:-unknown}"
  echo ""
  cat "$HANDOFF_FILE"
} >"$TMP_FILE"

CONTENT=$(jq -Rs . <"$TMP_FILE")
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":$CONTENT}}"
