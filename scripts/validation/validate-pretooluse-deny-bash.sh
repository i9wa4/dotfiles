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
  '^(cat|head|tail|wc|sort|uniq|cut)([[:space:]]|$)'
  # Deliberately broad: Git safety must come from the hook's parsed
  # effective-argv classifier, not raw regex substrings.
  '^git.*status([[:space:]]|$)'
  '^git.*diff([[:space:]]|$)'
  '^git.*log([[:space:]]|$)'
  '^git.*show([[:space:]]|$)'
)
declare -a DENY_PATTERNS=()
declare -a DENY_JUSTIFICATIONS=()
declare -a STRIP_DATA_ARGS=('__issue_373_unused_strip_arg__')
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

git_fixture="$tmp_dir/git-fixture"
mkdir "$git_fixture"
git -C "$git_fixture" init -q
git -C "$git_fixture" config user.email "fixture@example.invalid"
git -C "$git_fixture" config user.name "fixture"
mkdir -p "$git_fixture/secrets" "$git_fixture/.ssh" "$git_fixture/config/zsh"
printf 'placeholder\n' >"$git_fixture/.env"
printf 'placeholder\n' >"$git_fixture/.env.example"
printf 'placeholder\n' >"$git_fixture/.example"
printf 'placeholder\n' >"$git_fixture/.e??"
printf 'placeholder\n' >"$git_fixture/--stat"
printf 'placeholder\n' >"$git_fixture/.ssh:config"
printf 'placeholder\n' >"$git_fixture/.ssh/config"
printf 'placeholder\n' >"$git_fixture/.ssh/id_rsa"
printf 'placeholder\n' >"$git_fixture/secrets/api.key"
printf 'placeholder\n' >"$git_fixture/config/zsh/keybind.zsh"
git -C "$git_fixture" add -Af -- .
git -C "$git_fixture" commit -qm 'fixture'

assert_real_git_success() {
  local name="$1"
  local command="$2"

  if ! bash -lc "cd \"$git_fixture\" && $command >/dev/null"; then
    printf 'not ok - %s\nreal git fixture command failed: %s\n' "$name" "$command" >&2
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

assert_denied 'G406-F1 git show rev:path .env' 'git show HEAD:.env'
assert_denied 'G406-F1 git show rev:path secret key' 'git show HEAD:secrets/api.key'
assert_denied 'G406-F1 git show quote-concatenated rev:path' 'git show HEAD:".env"'
assert_denied 'G406-F1 git show with global option' 'git --no-pager show HEAD:.env'
assert_denied 'GIT-001 git show with global -C' "git -C \"$git_fixture\" show HEAD:.env"
assert_denied 'GIT-001 git log with global -C' "git -C \"$git_fixture\" log -p -- .env"
assert_denied 'GIT-001 git diff with global -C' "git -C \"$git_fixture\" diff HEAD~1 -- .env"
assert_denied 'GIT-001 unsupported global option is rejected before raw allow' 'git --literal-pathspecs show HEAD:.env'
assert_denied 'GIT-002 command-local show alias is rejected' 'git -c alias.x=show x HEAD:.env'
assert_denied 'GIT-002 command-local log alias is rejected' 'git -c alias.x=log x -p -- .env'
assert_denied 'G406-F2 git show commit path defaults to patch' 'git show HEAD -- .env'
assert_denied 'G406-F2 git show explicit patch path' 'git show --patch HEAD -- .env'
assert_denied 'G406-F2 git show short patch path' 'git show -p HEAD -- secrets/api.key'
assert_denied 'GIT-003 git show --format does not suppress patch' 'git show --format=medium HEAD -- .env'
assert_allowed 'GIT-003 git show -s --format suppresses patch' 'git show -s --format=medium HEAD -- .env'
assert_denied 'GIT-004 git show treats --stat after -- as pathspec' 'git show HEAD -- --stat .env'
assert_denied 'GIT-004 git show treats --name-only after -- as pathspec' 'git show HEAD -- --name-only .env'
assert_denied 'GIT-005 git show rejects ANSI-C dollar quote' "git show HEAD:$'.env'"
assert_denied 'GIT-005 git show rejects concatenated ANSI-C dollar quote' "git show HEAD:prefix$'.env'"
assert_denied 'G406-F3 git log short patch path' 'git log -p -- .env'
assert_denied 'G406-F3 git log unified patch path' 'git log -u -- secrets/api.key'
assert_denied 'G406-F3 git log long patch path' 'git log --patch -- secrets/api.key'
assert_denied 'G406-F3 git log patch-count path' 'git log --patch=1 -- .env'
assert_denied 'G406-F3 git log patch-with-stat path' 'git log --patch-with-stat -- .env'
assert_denied 'GIT-006 git log -U path' 'git log -U3 -- .env'
assert_denied 'GIT-006 git log --unified path' 'git log --unified -- .env'
assert_denied 'GIT-006 git log --unified=count path' 'git log --unified=3 -- .env'
assert_denied 'GIT-007 git log patch bare protected operand' 'git log -p secrets'
assert_denied 'G406-F4 git diff path after boundary' 'git diff -- secrets/api.key'
assert_denied 'G406-F4 git diff relative protected path' 'git diff HEAD -- .ssh/id_rsa'
assert_denied 'G406-F4 git diff pathspec magic literal' 'git diff -- :(literal).env'
assert_denied 'G406-F4 git diff multiple paths one protected' 'git diff -- README.md secrets/api.key'
assert_denied 'GIT-007 git diff bare protected operand' 'git diff secrets'
assert_denied 'GIT-008 git show shell glob rev:path' 'git show HEAD:.e??'
assert_denied 'GIT-008 git diff shell brace path' 'git diff -- .{env,example}'
assert_denied 'GIT-008 git diff nonliteral git glob pathspec' 'git diff -- :(glob).e*'
assert_denied 'GIT-009 git show .ssh colon rev:path' 'git show HEAD:.ssh:config'
assert_allowed 'GIT-010 git diff name-only secret path remains metadata-only' 'git diff --name-only -- .env'
assert_allowed 'GIT-010 git diff name-status secret path remains metadata-only' 'git diff --name-status -- .env'
assert_allowed 'GIT-010 git diff stat secret path remains metadata-only' 'git diff --stat -- .env'
assert_allowed 'GIT-010 git diff shortstat secret path remains metadata-only' 'git diff --shortstat -- .env'
assert_allowed 'GIT-010 git diff numstat secret path remains metadata-only' 'git diff --numstat -- .env'
assert_allowed 'GIT-010 git diff summary secret path remains metadata-only' 'git diff --summary -- .env'
assert_allowed 'GIT-010 git diff raw secret path remains metadata-only' 'git diff --raw -- .env'
assert_allowed 'GIT-010 git diff quiet secret path remains metadata-only' 'git diff --quiet -- .env'
assert_denied 'GIT-010 git diff patch precedence over name-only' 'git diff --name-only -p -- .env'

assert_allowed 'git status remains allowed' 'git status'
assert_allowed 'git show metadata stat remains allowed' 'git show --stat HEAD'
assert_allowed 'git show metadata stat with secret path remains allowed' 'git show --stat HEAD -- .env'
assert_allowed 'git show non-secret rev:path remains allowed' 'git show HEAD:config/zsh/keybind.zsh'
assert_allowed 'git log metadata-only secret path remains allowed' 'git log -- .env'
assert_allowed 'git log patch non-secret path remains allowed' 'git log -p -- config/zsh/keybind.zsh'
assert_allowed 'git diff non-secret path remains allowed' 'git diff -- config/zsh/keybind.zsh'
assert_allowed 'cat non-secret keybind remains allowed' 'cat config/zsh/keybind.zsh'
assert_allowed 'cat .envrc remains allowed' 'cat .envrc'
assert_allowed 'cat .env.example remains allowed' 'cat .env.example'

assert_real_git_success 'real fixture GIT-001 -C show shape' "git -C \"$git_fixture\" show HEAD:.env"
assert_real_git_success 'real fixture GIT-003 show --format path shape' 'git show --format=medium HEAD -- .env'
assert_real_git_success 'real fixture GIT-004 -- path shape' 'git show HEAD -- --stat .env'
assert_real_git_success 'real fixture GIT-006 --unified path shape' 'git log --unified=3 -- .env'
assert_real_git_success 'real fixture GIT-008 shell glob shape' 'git show HEAD:.e??'
assert_real_git_success 'real fixture GIT-008 git glob pathspec shape' 'git diff --name-only -- ":(glob).e*"'
assert_real_git_success 'real fixture GIT-009 .ssh colon rev:path shape' 'git show HEAD:.ssh:config'

printf 'ok - pretooluse-deny-bash heredoc and git secret-path regression checks passed\n'
