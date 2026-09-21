#!/usr/bin/env bash
# Focused regression validation for the shared Bash PreToolUse deny hook.

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
  '^(tmux-a2a-postman|cat|head|tail|wc|sort|uniq|cut|git)([[:space:]]|$)'
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

# shellcheck disable=SC2016 # literal command substitution text for the hook to inspect
printf -v two_unquoted_heredocs_with_odd_quote_before_substitution '%s\n%s\n%s\n%s\n%s' \
  'tmux-a2a-postman send-heredoc --to orchestrator <<FIRST <<SECOND' \
  "one apostrophe '" \
  'FIRST' \
  '$(whoami)' \
  'SECOND'

assert_denied \
  'unquoted heredoc command substitution after literal apostrophe' \
  "$unquoted_heredoc_with_odd_quote_before_substitution"

assert_denied \
  'two unquoted heredocs keep body quote state isolated' \
  "$two_unquoted_heredocs_with_odd_quote_before_substitution"

assert_allowed \
  'quoted heredoc body keeps literal metacharacters inert' \
  "$quoted_heredoc_with_literal_metacharacters"

protected_paths=(
  id_rsa
  id_ed25519
  /etc/shadow
  .netrc
  .pgpass
  .npmrc
  server.pem
  .kube/config
)

for secret_path in "${protected_paths[@]}"; do
  assert_denied "git show rev:path: $secret_path" "git show HEAD:$secret_path"
  assert_denied "quoted git show rev:path: $secret_path" "git show \"HEAD:$secret_path\""
  assert_denied "single-quoted git show rev:path: $secret_path" "git show 'HEAD:$secret_path'"
done

assert_denied 'git log patch secret path' 'git log -p -- id_rsa'
assert_denied 'git diff secret path' 'git diff -- .kube/config'
assert_denied 'git show quote-concatenated rev:path' 'git show HEAD:".env"'
assert_denied 'git show with global option' 'git --no-pager show HEAD:id_rsa'
assert_denied 'git show commit path defaults to patch' 'git show HEAD -- id_rsa'
assert_denied 'git show explicit patch path' 'git show --patch HEAD -- .netrc'
assert_denied 'git log unified patch path' 'git log -u -- .pgpass'
assert_denied 'git log patch-count path' 'git log --patch=1 -- .npmrc'
assert_denied 'git diff pathspec magic literal' 'git diff -- :(literal).env'
assert_denied 'git diff multiple paths one protected' 'git diff -- README.md server.pem'

assert_allowed 'plain git status' 'git status'
assert_allowed 'git show commit metadata' 'git show --stat HEAD'
assert_allowed 'git show metadata with secret path' 'git show --stat HEAD -- .env'
assert_allowed 'non-secret git show rev:path' 'git show HEAD:config/zsh/keybind.zsh'
assert_allowed 'non-patch git log path' 'git log -- .env'
assert_allowed 'non-secret git diff path' 'git diff -- config/zsh/keybind.zsh'

printf 'ok - pretooluse-deny-bash heredoc and Git secret-path regression checks passed\n'
