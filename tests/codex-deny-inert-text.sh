#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

hook_script=""
patterns_file=""
codex_config=""

usage() {
  cat <<'USAGE'
usage: codex-deny-inert-text.sh --hook-script PATH --patterns-file PATH --codex-config PATH
USAGE
}

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
  --hook-script)
    hook_script=${2:-}
    shift 2
    ;;
  --patterns-file)
    patterns_file=${2:-}
    shift 2
    ;;
  --codex-config)
    codex_config=${2:-}
    shift 2
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    fail "unexpected argument: $1"
    ;;
  esac
done

[ -n "$hook_script" ] || fail "--hook-script is required"
[ -n "$patterns_file" ] || fail "--patterns-file is required"
[ -n "$codex_config" ] || fail "--codex-config is required"
[ -f "$hook_script" ] || fail "hook script not found: $hook_script"
[ -f "$patterns_file" ] || fail "patterns file not found: $patterns_file"
[ -f "$codex_config" ] || fail "codex config not found: $codex_config"

tmp_root=$(mktemp -d)
trap 'rm -rf "$tmp_root"' EXIT

script_dir="${tmp_root}/scripts"
mkdir -p "$script_dir"
ln -s "$hook_script" "${script_dir}/pretooluse-deny-bash.sh"
ln -s "$patterns_file" "${script_dir}/deny-bash-patterns.sh"

assert_file_not_contains() {
  local file=$1
  local unexpected=$2

  if grep -Fq -- "$unexpected" "$file"; then
    echo "Unexpected text found in ${file}: ${unexpected}" >&2
    fail "embedded Codex deny rule source is present"
  fi
}

run_hook() {
  local command_text=$1

  jq -n --arg command "$command_text" \
    '{tool_input: {command: $command}}' |
    "$BASH" "${script_dir}/pretooluse-deny-bash.sh"
}

assert_allowed() {
  local name=$1
  local command_text=$2
  local output

  output=$(run_hook "$command_text")
  if [ -n "$output" ]; then
    echo "Expected allow for ${name}, got hook output:" >&2
    printf '%s\n' "$output" >&2
    fail "${name} was denied"
  fi
}

assert_denied() {
  local name=$1
  local command_text=$2
  local output

  output=$(run_hook "$command_text")
  if ! printf '%s\n' "$output" | jq -e '.hookSpecificOutput.permissionDecision == "deny"' >/dev/null; then
    echo "Expected deny for ${name}, got hook output:" >&2
    printf '%s\n' "$output" >&2
    fail "${name} was not denied"
  fi
}

postman_body_command=$(
  cat <<'COMMAND'
tmux-a2a-postman send-heredoc --to orchestrator <<'POSTMAN_BODY'
This prose mentions git push as inert message data.

```sh
git push origin main
```
POSTMAN_BODY
COMMAND
)

assert_file_not_contains "$codex_config" "prefix_rule("
assert_file_not_contains "$codex_config" "embedded Codex rules ="

assert_allowed "prose in git commit message" \
  'git commit -m "document why git push is policy-denied in prose"'
assert_allowed "postman heredoc payload with prose and fenced code" \
  "$postman_body_command"

assert_denied "actual git push command" \
  "git push origin HEAD:refs/heads/example"
assert_denied "wrapped git push command" \
  "bash -c 'git push origin HEAD:refs/heads/example'"

echo "codex-deny-inert-text: all checks passed"
