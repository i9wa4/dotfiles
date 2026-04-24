#!/usr/bin/env bash
# precompact-save.sh - Context snapshot saver
#
# Saves a structured handoff snapshot before auto-compact triggers.
# Preserves task state, active artifacts, and git working state for
# post-compact resumption.
#
# Hook: PreCompact
# Matcher: (none)
#
# Input (stdin JSON):
#   { "hook_event_name": "PreCompact", "trigger": "manual|auto", ... }
#
# Output:
#   File saved via mkmd
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
SESSION_ENV_DIR="${CLAUDE_HOME}/session-env"

mkdir -p "$SESSION_ENV_DIR"

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
    "trigger": data.get("trigger", ""),
}))
' 2>/dev/null || echo '{}')
fi

HOOK_CWD="$(printf '%s' "$HOOK_CONTEXT_JSON" | jq -r '.cwd // empty')"
HOOK_SESSION_ID="$(printf '%s' "$HOOK_CONTEXT_JSON" | jq -r '.session_id // empty')"
HOOK_TRIGGER="$(printf '%s' "$HOOK_CONTEXT_JSON" | jq -r '.trigger // empty')"

if [ -z "$HOOK_CWD" ]; then
  HOOK_CWD="$PWD"
fi

PROJECT_KEY="$(printf '%s' "$HOOK_CWD" | sed -E 's/[^[:alnum:]]+/-/g; s/-+$//')"
PROJECT_TRANSCRIPTS_DIR="${CLAUDE_HOME}/projects/${PROJECT_KEY}"
SESSION_LOG=""

if [ -n "$HOOK_SESSION_ID" ] && [ -f "${PROJECT_TRANSCRIPTS_DIR}/${HOOK_SESSION_ID}.jsonl" ]; then
  SESSION_LOG="${PROJECT_TRANSCRIPTS_DIR}/${HOOK_SESSION_ID}.jsonl"
elif [ -d "$PROJECT_TRANSCRIPTS_DIR" ] && [ -n "$PYTHON_CMD" ]; then
  SESSION_LOG="$(PROJECT_TRANSCRIPTS_DIR="$PROJECT_TRANSCRIPTS_DIR" "$PYTHON_CMD" -c '
from pathlib import Path
import os

paths = sorted(
    Path(os.environ["PROJECT_TRANSCRIPTS_DIR"]).glob("*.jsonl"),
    key=lambda path: path.stat().st_mtime,
    reverse=True,
)
print(paths[0] if paths else "")
' 2>/dev/null || true)"
elif [ -d "$PROJECT_TRANSCRIPTS_DIR" ]; then
  SESSION_LOG="$(find "$PROJECT_TRANSCRIPTS_DIR" -type f -name '*.jsonl' 2>/dev/null | head -1 || true)"
fi

SESSION_STATE_JSON='{"objective":"No recent objective captured.","next_action":"Resume from the objective and active paths below.","blockers":"None recorded.","verification":"Use the verification snapshot below.","recent_artifacts":[]}'
if [ -n "$PYTHON_CMD" ] && [ -n "$SESSION_LOG" ] && [ -f "$SESSION_LOG" ]; then
  SESSION_STATE_JSON="$(SESSION_LOG="$SESSION_LOG" MKMD_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/mkmd" HOOK_CWD="$HOOK_CWD" "$PYTHON_CMD" -c '
import json
import os
import re
from pathlib import Path

session_log = Path(os.environ["SESSION_LOG"])
mkmd_dir = Path(os.environ["MKMD_DIR"])
hook_cwd = Path(os.environ["HOOK_CWD"])

assistant_texts = []
tool_results = []
latest_user_text = ""

def flatten_user_content(content):
    texts = []
    results = []
    if isinstance(content, str):
        texts.append(content)
    elif isinstance(content, list):
        for item in content:
            if not isinstance(item, dict):
                continue
            item_type = item.get("type")
            if item_type == "text":
                texts.append(item.get("text", ""))
            elif item_type == "tool_result":
                result_content = item.get("content", "")
                if isinstance(result_content, list):
                    result_content = "\n".join(str(part) for part in result_content)
                results.append(str(result_content))
    return "\n".join(part for part in texts if part).strip(), "\n".join(part for part in results if part).strip()

def flatten_assistant_content(content):
    texts = []
    if isinstance(content, str):
        texts.append(content)
    elif isinstance(content, list):
        for item in content:
            if isinstance(item, dict) and item.get("type") == "text":
                texts.append(item.get("text", ""))
    return "\n".join(part for part in texts if part).strip()

def compact(text, limit=320):
    if not text:
        return ""
    lines = [line.strip() for line in str(text).splitlines() if line.strip()]
    if not lines:
        return ""
    value = "\n".join(lines[:4])
    if len(value) <= limit:
        return value
    return value[: limit - 3].rstrip() + "..."

def extract_content_section(text):
    if "## Content" not in text:
        return ""
    section = text.split("## Content", 1)[1]
    lines = []
    for raw in section.splitlines():
        line = raw.strip()
        if not line:
            if lines:
                break
            continue
        if line.startswith("---") or line.startswith("You can talk to:") or line.startswith("Reply:") or line.startswith("No reply needed"):
            break
        lines.append(line)
    return "\n".join(lines)

for raw_line in session_log.read_text().splitlines():
    try:
        entry = json.loads(raw_line)
    except json.JSONDecodeError:
        continue

    entry_type = entry.get("type")
    if entry_type == "user":
        message = entry.get("message", {})
        text, tool_result = flatten_user_content(message.get("content"))
        if text:
            latest_user_text = text
        if tool_result:
            tool_results.append(tool_result)
    elif entry_type == "assistant":
        message = entry.get("message", {})
        text = flatten_assistant_content(message.get("content"))
        if text:
            assistant_texts.append(text)

objective = ""
for tool_result in reversed(tool_results):
    section = extract_content_section(tool_result)
    if section:
        objective = compact(section)
        break
if not objective:
    objective = compact(latest_user_text) or "No recent objective captured."

next_action = ""
next_action_pattern = re.compile(r"(I.?ll|I.?m|I am|Next|Resume|Continu|Check|Patch|Implement|Verif)", re.IGNORECASE)
for assistant_text in reversed(assistant_texts):
    for raw_line in assistant_text.splitlines():
        line = raw_line.strip()
        if line and next_action_pattern.search(line):
            next_action = compact(line)
            break
    if next_action:
        break
if not next_action and assistant_texts:
    next_action = compact(assistant_texts[-1])
if not next_action:
    next_action = "Resume from the objective and active paths below."

blockers = ""
blocker_pattern = re.compile(r"\b(blocked|blocking|denied|failed|failure|error|cannot|can.?t)\b", re.IGNORECASE)
for assistant_text in reversed(assistant_texts):
    for raw_line in assistant_text.splitlines():
        line = raw_line.strip()
        lowered = line.lower()
        if line and blocker_pattern.search(line) and "no done or blocked signal" not in lowered and "no delivery stalls" not in lowered:
            blockers = compact(line)
            break
    if blockers:
        break
if not blockers:
    blockers = "None recorded."

verification = ""
verification_pattern = re.compile(r"^(Verification:)|\b(verified|clean worktree|tests? passed)\b|^Sent:", re.IGNORECASE)
for assistant_text in reversed(assistant_texts):
    for raw_line in assistant_text.splitlines():
        line = raw_line.strip()
        if line and verification_pattern.search(line):
            verification = compact(line)
            break
    if verification:
        break
if not verification:
    verification = "Use the verification snapshot below."

recent_artifacts = []
if mkmd_dir.is_dir():
    files = [path for path in mkmd_dir.rglob("*") if path.is_file()]
    files.sort(key=lambda path: path.stat().st_mtime, reverse=True)
    project_files = [path for path in files if hook_cwd.name and hook_cwd.name in str(path)]
    selected_files = project_files or files
    recent_artifacts = [str(path) for path in selected_files[:5]]

print(json.dumps({
    "objective": objective,
    "next_action": next_action,
    "blockers": blockers,
    "verification": verification,
    "recent_artifacts": recent_artifacts,
}))
' 2>/dev/null || printf '%s' "$SESSION_STATE_JSON")"
fi

OBJECTIVE="$(printf '%s' "$SESSION_STATE_JSON" | jq -r '.objective')"
NEXT_ACTION="$(printf '%s' "$SESSION_STATE_JSON" | jq -r '.next_action')"
BLOCKERS="$(printf '%s' "$SESSION_STATE_JSON" | jq -r '.blockers')"
VERIFICATION="$(printf '%s' "$SESSION_STATE_JSON" | jq -r '.verification')"
RECENT_ARTIFACTS="$(printf '%s' "$SESSION_STATE_JSON" | jq -r '.recent_artifacts[]?')"

FILE=$(mkmd --dir tmp --label compact-save)
LATEST_STATE_FILE="${SESSION_ENV_DIR}/handoff-${PROJECT_KEY}-latest.md"
SESSION_STATE_FILE=""
if [ -n "$HOOK_SESSION_ID" ]; then
  SESSION_STATE_FILE="${SESSION_ENV_DIR}/handoff-${PROJECT_KEY}-${HOOK_SESSION_ID}.md"
fi

GIT_STATUS="$(git --no-optional-locks status --short 2>/dev/null || echo "(not a git repo)")"
RECENT_COMMITS="$(git log --oneline -5 2>/dev/null || echo "(no commits)")"
CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || echo "(detached HEAD or not git)")"
ACTIVE_REPO_PATHS="$(printf '%s\n' "$GIT_STATUS" | awk 'NF { print $NF }')"

{
  echo "# Claude Session Handoff"
  echo ""
  echo "Timestamp: $(date +%Y-%m-%dT%H:%M:%S%z)"
  echo ""
  echo "Trigger: ${HOOK_TRIGGER:-unknown}"
  echo ""
  echo "Session ID: ${HOOK_SESSION_ID:-unknown}"
  echo ""
  echo "Working Directory: $HOOK_CWD"
  echo ""
  echo "Transcript: ${SESSION_LOG:-not found}"
  echo ""
  echo "## Objective"
  echo ""
  printf '%s\n' "$OBJECTIVE"
  echo ""
  echo "## Next Action"
  echo ""
  printf '%s\n' "$NEXT_ACTION"
  echo ""
  echo "## Blockers"
  echo ""
  printf '%s\n' "$BLOCKERS"
  echo ""
  echo "## Active Repo Paths"
  echo ""
  if [ -n "$ACTIVE_REPO_PATHS" ]; then
    while IFS= read -r path; do
      [ -n "$path" ] && printf -- '- %s\n' "$path"
    done <<EOF
$ACTIVE_REPO_PATHS
EOF
  else
    echo "- (none)"
  fi
  echo ""
  echo "## Active Plan / Artifact Paths"
  echo ""
  if [ -n "$RECENT_ARTIFACTS" ]; then
    while IFS= read -r artifact; do
      [ -n "$artifact" ] && printf -- '- %s\n' "$artifact"
    done <<EOF
$RECENT_ARTIFACTS
EOF
  else
    echo "- (none found)"
  fi
  echo ""
  echo "## Latest Verification Outcome"
  echo ""
  printf '%s\n' "$VERIFICATION"
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
} >"$FILE"

cp "$FILE" "$LATEST_STATE_FILE"
if [ -n "$SESSION_STATE_FILE" ]; then
  cp "$FILE" "$SESSION_STATE_FILE"
fi

echo "Context saved to $FILE" >&2

exit 0
