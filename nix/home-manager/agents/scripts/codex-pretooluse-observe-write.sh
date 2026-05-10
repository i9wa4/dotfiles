#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# codex-pretooluse-observe-write.sh - Observe Codex write-tool hook payloads.
# Hook: PreToolUse | Matcher: apply_patch|Edit|Write
#
# This is intentionally not an enforcement hook. It records payload shape and
# small metadata so we can decide whether a later deny hook is reliable enough.

INPUT=$(cat)
[[ -z $INPUT ]] && exit 0

LOG_DIR="${CODEX_HOOK_OBSERVE_DIR:-$HOME/.codex/hook-observations}"
LOG_FILE="$LOG_DIR/pretooluse-write-tools.jsonl"

mkdir -p "$LOG_DIR"
chmod 700 "$LOG_DIR" 2>/dev/null || true

jq -c \
  --arg observed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '
  def scalar_paths:
    [paths(scalars) | map(tostring) | join(".")] | unique;

  {
    observed_at: $observed_at,
    hook_event_name: (.hook_event_name // .hook_event_name? // null),
    tool_name: (.tool_name // null),
    cwd: (.cwd // null),
    command_length: (.tool_input.command? // "" | length),
    tool_input_keys: (.tool_input // {} | keys_unsorted),
    scalar_paths: scalar_paths
  }
  ' <<<"$INPUT" >>"$LOG_FILE" 2>/dev/null || true

exit 0
