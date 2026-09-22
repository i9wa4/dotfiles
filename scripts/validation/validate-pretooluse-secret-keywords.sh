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
  '^(cat|head|tail|wc|sort|uniq|cut|grep|rg|ripgrep)([[:space:]]|$)'
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

protected_paths=(
  id_rsa
  id_ed25519
  /etc/shadow
  ~/.netrc
  ~/.pgpass
  ~/.npmrc
  server.pem
  ~/.kube/config
)

for secret_path in "${protected_paths[@]}"; do
  assert_denied "secret-shaped path: $secret_path" "cat $secret_path"
  assert_denied "double-quoted secret path: $secret_path" "cat \"$secret_path\""
  assert_denied "single-quoted secret path: $secret_path" "cat '$secret_path'"
  assert_denied "multiple arguments include secret path: $secret_path" "cat README.md \"$secret_path\""
done

assert_denied 'nested secret path' 'cat nested/id_rsa'

for compound in api_key secret_key private_key access_token; do
  assert_denied "high-confidence secret compound: $compound" "cat ${compound}.txt"
done

for plural in keys tokens passwords; do
  assert_denied "plural secret keyword: $plural" "cat ${plural}.txt"
done

for reader in cat grep rg ripgrep; do
  assert_denied "split quote secret path for $reader" "$reader .e''nv"
  assert_denied "escaped secret keyword for $reader" "$reader k\\ey.txt"

  printf -v lf_continuation '%s\\\n%s' "$reader .e" 'nv'
  assert_denied "LF continuation secret path for $reader" "$lf_continuation"
  printf -v crlf_continuation '%s\\\r\n%s' "$reader .e" 'nv'
  assert_denied "CRLF continuation secret path for $reader" "$crlf_continuation"

  printf -v escaped_apostrophe_lf '%s\\%s README.md .e\\\n%s' "$reader" "'" 'nv'
  assert_denied "escaped apostrophe before LF continuation for $reader" "$escaped_apostrophe_lf"
  printf -v escaped_apostrophe_crlf '%s\\%s README.md .e\\\r\n%s' "$reader" "'" 'nv'
  assert_denied "escaped apostrophe before CRLF continuation for $reader" "$escaped_apostrophe_crlf"

  assert_allowed "safe .env example for $reader" "$reader .env.example"
  assert_allowed "quoted literal backslash for $reader" "$reader \"\\\\.env\""
done

for nonsecret_path in \
  token_bucket.md \
  key_bind.md \
  key_binding.md \
  tokenizer.md \
  monkey_patch.md \
  .envrc \
  .env.example \
  config/zsh/keybind.zsh; do
  assert_allowed "non-secret path remains allowed: $nonsecret_path" "cat $nonsecret_path"
done

printf 'ok - pretooluse-deny-bash secret-keyword regression checks passed\n'
