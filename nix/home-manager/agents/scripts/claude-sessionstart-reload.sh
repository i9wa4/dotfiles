#!/usr/bin/env bash
# sessionstart-reload.sh - CLAUDE.md + handoff context reloader
#
# Force Claude to reload CLAUDE.md and the latest saved handoff summary after
# compaction/resume. Outputs combined content in additionalContext using jq for
# JSON escape.
#
# Hook: SessionStart
# Matcher: compact|resume|clear
#
# Input (stdin JSON):
#   { "hook_event_name": "SessionStart", "source": "compact|resume|clear", ... }
#
# Output:
#   JSON with hookSpecificOutput containing additionalContext
set -o errexit
set -o nounset
set -o pipefail
set -o posix

resolve_python_cmd() {
  if command -v python3 >/dev/null 2>&1; then
    printf '%s\n' python3
    return 0
  fi

  if command -v python >/dev/null 2>&1; then
    printf '%s\n' python
    return 0
  fi

  return 1
}

INPUT_JSON=$(cat)
PYTHON_CMD="$(resolve_python_cmd 2>/dev/null || true)"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CLAUDE_MD="${CLAUDE_HOME}/CLAUDE.md"
SESSION_ENV_DIR="${CLAUDE_HOME}/session-env"

HOOK_CONTEXT_JSON='{}'
if [ -n "$INPUT_JSON" ] && [ -n "$PYTHON_CMD" ]; then
  HOOK_CONTEXT_JSON=$(printf '%s' "$INPUT_JSON" | "$PYTHON_CMD" -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    data = {}
print(json.dumps({
    "cwd": data.get("cwd", ""),
    "session_id": data.get("session_id", data.get("sessionId", "")),
    "source": data.get("source", ""),
}))
' 2>/dev/null || echo '{}')
fi

HOOK_CWD="$(printf '%s' "$HOOK_CONTEXT_JSON" | jq -r '.cwd // empty')"
HOOK_SESSION_ID="$(printf '%s' "$HOOK_CONTEXT_JSON" | jq -r '.session_id // empty')"
HOOK_SOURCE="$(printf '%s' "$HOOK_CONTEXT_JSON" | jq -r '.source // empty')"

if [ -z "$HOOK_CWD" ]; then
  HOOK_CWD="$PWD"
fi

PROJECT_KEY="$(printf '%s' "$HOOK_CWD" | sed -E 's/[^[:alnum:]]+/-/g; s/-+$//')"
HANDOFF_FILE="${SESSION_ENV_DIR}/handoff-${PROJECT_KEY}-latest.md"
if [ -n "$HOOK_SESSION_ID" ] && [ -f "${SESSION_ENV_DIR}/handoff-${PROJECT_KEY}-${HOOK_SESSION_ID}.md" ]; then
  HANDOFF_FILE="${SESSION_ENV_DIR}/handoff-${PROJECT_KEY}-${HOOK_SESSION_ID}.md"
fi

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

if [ -f "$CLAUDE_MD" ]; then
  cat "$CLAUDE_MD" >"$TMP_FILE"
else
  printf '%s\n' 'CLAUDE.md not found' >"$TMP_FILE"
fi

if [ -f "$HANDOFF_FILE" ]; then
  {
    echo ""
    echo ""
    echo "# Saved Handoff Context"
    echo ""
    echo "SessionStart source: ${HOOK_SOURCE:-unknown}"
    echo ""
    cat "$HANDOFF_FILE"
  } >>"$TMP_FILE"
fi

CONTENT="$(jq -Rs . <"$TMP_FILE")"
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":$CONTENT}}"
