#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp_dir="$(mktemp -d)"
stub_bin="${tmp_dir}/bin"
direnv_log="${tmp_dir}/direnv.log"

cleanup() {
  rm -rf "${tmp_dir}"
}

trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

reset_direnv_log() {
  : >"${direnv_log}"
}

write_stub_direnv() {
  mkdir -p "${stub_bin}"
  cat >"${stub_bin}/direnv" <<'EOF'
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

printf '%s\n' "$*" >>"${DIRENV_LOG}"
EOF
  chmod +x "${stub_bin}/direnv"
}

new_git_repo() {
  local path=$1

  mkdir -p "${path}"
  cd "${path}"
  git init -q
  git config user.email repo-setup-smoke@example.invalid
  git config user.name repo-setup-smoke
}

run_repo_setup() {
  local path=$1
  shift

  cd "${path}"
  PATH="${stub_bin}:${PATH}" DIRENV_LOG="${direnv_log}" \
    "${repo_root}/bin/repo-setup" --skip-devshell-hooks "$@"
}

assert_file_content() {
  local path=$1
  local expected=$2
  local expected_path="${tmp_dir}/expected"

  printf '%s\n' "${expected}" >"${expected_path}"
  cmp -s "${expected_path}" "${path}" ||
    fail "unexpected content in ${path}"
}

assert_direnv_allowed() {
  local envrc_path=$1

  grep -Fx "allow ${envrc_path}" "${direnv_log}" >/dev/null ||
    fail "direnv allow was not called for ${envrc_path}"
}

assert_no_direnv_call() {
  if [[ -s ${direnv_log} ]]; then
    fail "unexpected direnv calls: $(cat "${direnv_log}")"
  fi
}

test_missing_envrc_created_and_allowed() {
  local repo="${tmp_dir}/missing-envrc"

  new_git_repo "${repo}"
  touch "${repo}/flake.nix"
  reset_direnv_log
  run_repo_setup "${repo}"

  assert_file_content "${repo}/.envrc" "use flake"
  assert_direnv_allowed "${repo}/.envrc"
}

test_missing_envrc_can_skip_allow_for_untrusted_worktree() {
  local repo="${tmp_dir}/missing-envrc-skip-allow"

  new_git_repo "${repo}"
  touch "${repo}/flake.nix"
  reset_direnv_log
  run_repo_setup "${repo}" --no-allow-generated-envrc

  assert_file_content "${repo}/.envrc" "use flake"
  assert_no_direnv_call
}

test_existing_envrc_not_overwritten_or_allowed_by_default() {
  local repo="${tmp_dir}/existing-envrc-default"

  new_git_repo "${repo}"
  touch "${repo}/flake.nix"
  printf '%s\n' "custom" >"${repo}/.envrc"
  reset_direnv_log
  run_repo_setup "${repo}"

  assert_file_content "${repo}/.envrc" "custom"
  assert_no_direnv_call
}

test_existing_envrc_allowed_when_requested() {
  local repo="${tmp_dir}/existing-envrc-allow"

  new_git_repo "${repo}"
  touch "${repo}/flake.nix"
  printf '%s\n' "custom" >"${repo}/.envrc"
  reset_direnv_log
  run_repo_setup "${repo}" --allow-direnv

  assert_file_content "${repo}/.envrc" "custom"
  assert_direnv_allowed "${repo}/.envrc"
}

test_non_flake_repo_does_not_create_envrc() {
  local repo="${tmp_dir}/non-flake"

  new_git_repo "${repo}"
  reset_direnv_log
  run_repo_setup "${repo}"

  [[ ! -e "${repo}/.envrc" ]] ||
    fail "non-flake repo should not get generated .envrc"
  assert_no_direnv_call
}

test_pr_worktree_default_preserves_generated_envrc_trust_gate() {
  grep -F 'repo-setup --no-allow-generated-envrc' \
    "${repo_root}/bin/pr-worktree-create" >/dev/null ||
    fail "pr-worktree-create must not auto-allow generated .envrc by default"
  grep -F 'repo-setup --allow-direnv' \
    "${repo_root}/bin/pr-worktree-create" >/dev/null ||
    fail "pr-worktree-create must keep explicit .envrc authorization path"
}

write_stub_direnv
test_missing_envrc_created_and_allowed
test_missing_envrc_can_skip_allow_for_untrusted_worktree
test_existing_envrc_not_overwritten_or_allowed_by_default
test_existing_envrc_allowed_when_requested
test_non_flake_repo_does_not_create_envrc
test_pr_worktree_default_preserves_generated_envrc_trust_gate

echo "PASS: repo-setup smoke checks"
