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
  '^(cat|head|tail|wc|sort|uniq|cut)([[:space:]]|$)'
)
declare -a DENY_PATTERNS=()
declare -a DENY_JUSTIFICATIONS=()
declare -a STRIP_DATA_ARGS=('__issue_374_unused_strip_arg__')
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

for secret_path in \
  id_rsa \
  id_ed25519 \
  /etc/shadow \
  ~/.netrc \
  ~/.pgpass \
  ~/.npmrc \
  server.pem \
  ~/.kube/config \
  keys.txt \
  tokens.json \
  passwords.txt \
  api_key.txt; do
  assert_denied "secret-shaped path: $secret_path" "cat $secret_path"
done

for nonsecret_path in \
  .envrc \
  .env.example \
  config/zsh/keybind.zsh; do
  assert_allowed "non-secret path remains allowed: $nonsecret_path" "cat $nonsecret_path"
done

printf 'ok - pretooluse-deny-bash secret-keyword regression checks passed\n'
