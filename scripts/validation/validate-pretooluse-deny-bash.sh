#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
hook_source="$repo_root/nix/home-manager/agents/scripts/pretooluse-deny-bash.sh"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

hook="$tmp_dir/pretooluse-deny-bash.sh"
cp "$hook_source" "$hook"
chmod +x "$hook"

cat >"$tmp_dir/deny-bash-patterns.sh" <<'PATTERNS'
declare -a ALLOW_PATTERNS=(
  '^tmux-a2a-postman([[:space:]]|$)'
)
declare -a DENY_PATTERNS=()
declare -a DENY_JUSTIFICATIONS=()
declare -a STRIP_DATA_ARGS=('__issue_353_unused_strip_arg__')
PATTERNS

run_hook() {
  local command="$1"

  jq -n --arg command "$command" \
    '{tool_input: {command: $command}}' |
    "$hook"
}

assert_denied() {
  local name="$1"
  local command="$2"
  local output

  output="$(run_hook "$command")"
  if ! jq -e '.hookSpecificOutput.permissionDecision == "deny"' >/dev/null 2>&1 <<<"$output"; then
    printf 'not ok - %s\nexpected deny JSON, got:\n%s\n' "$name" "${output:-<empty>}" >&2
    return 1
  fi
}

assert_allowed() {
  local name="$1"
  local command="$2"
  local output

  output="$(run_hook "$command")"
  if [ -n "$output" ]; then
    printf 'not ok - %s\nexpected empty allow output, got:\n%s\n' "$name" "$output" >&2
    return 1
  fi
}

# shellcheck disable=SC2016 # literal command substitution text for the hook to inspect
printf -v unquoted_heredoc_with_odd_quote_before_substitution '%s\n%s\n%s\n%s' \
  'tmux-a2a-postman send-heredoc --to orchestrator <<EOF' \
  "one apostrophe '" \
  '$(whoami)' \
  'EOF'

# shellcheck disable=SC2016 # literal command substitution/backtick text for the hook to inspect
printf -v quoted_heredoc_with_literal_metacharacters '%s\n%s\n%s' \
  "tmux-a2a-postman send-heredoc --to orchestrator <<'EOF'" \
  'hello <node> $(literal) `literal`' \
  'EOF'

assert_denied \
  'unquoted heredoc command substitution after literal apostrophe' \
  "$unquoted_heredoc_with_odd_quote_before_substitution"

assert_allowed \
  'quoted heredoc body keeps literal metacharacters inert' \
  "$quoted_heredoc_with_literal_metacharacters"

printf 'ok - pretooluse-deny-bash heredoc regression checks passed\n'
