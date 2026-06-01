#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
tmp_root=$(mktemp -d)
trap 'rm -rf "$tmp_root"' EXIT
unset GIT_DIR GIT_INDEX_FILE GIT_PREFIX GIT_WORK_TREE

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file=$1
  local expected=$2

  if ! grep -Fq -- "$expected" "$file"; then
    echo "Expected to find: ${expected}" >&2
    echo "--- ${file}" >&2
    sed -n '1,200p' "$file" >&2
    fail "missing expected text"
  fi
}

assert_not_contains() {
  local file=$1
  local unexpected=$2

  if grep -Fq -- "$unexpected" "$file"; then
    echo "Did not expect to find: ${unexpected}" >&2
    echo "--- ${file}" >&2
    sed -n '1,200p' "$file" >&2
    fail "found unexpected text"
  fi
}

make_fake_tools() {
  local fakebin=$1
  local bash_path

  mkdir -p "$fakebin"
  bash_path=$(command -v bash)

  {
    printf '#!%s\n' "$bash_path"
    cat <<'SH'
set -o errexit
set -o nounset
set -o pipefail

case "${1:-} ${2:-}" in
  "issue view")
    issue_number=${3:-}
    if [[ $issue_number == "222" ]]; then
      echo "missing issue" >&2
      exit 1
    fi
    printf '{"title":"Direnv allow test %s","body":"body","comments":[]}\n' "$issue_number"
    ;;
  "pr view")
    printf 'pr-feature\ti9wa4\tdotfiles\tfalse\n'
    ;;
  *)
    echo "unexpected gh args: $*" >&2
    exit 1
    ;;
esac
SH
  } >"${fakebin}/gh"

  {
    printf '#!%s\n' "$bash_path"
    cat <<'SH'
set -o errexit
set -o nounset
set -o pipefail

printf '%s\n' 'direnv-allow-test'
SH
  } >"${fakebin}/claude"

  {
    printf '#!%s\n' "$bash_path"
    cat <<'SH'
set -o errexit
set -o nounset
set -o pipefail

printf 'pwd=%s args=%s\n' "$PWD" "$*" >>"${REPO_SETUP_LOG:?}"
SH
  } >"${fakebin}/repo-setup"

  {
    printf '#!%s\n' "$bash_path"
    cat <<'SH'
exit 0
SH
  } >"${fakebin}/zoxide"

  chmod +x "${fakebin}/gh" "${fakebin}/claude" "${fakebin}/repo-setup" "${fakebin}/zoxide"
}

make_fake_direnv() {
  local fakebin=$1
  local bash_path

  mkdir -p "$fakebin"
  bash_path=$(command -v bash)

  {
    printf '#!%s\n' "$bash_path"
    cat <<'SH'
set -o errexit
set -o nounset
set -o pipefail

printf 'direnv pwd=%s args=%s\n' "$PWD" "$*" >>"${REPO_SETUP_LOG:?}"

case "${1:-}" in
  allow)
    test -f "${2:?}"
    ;;
  exec)
    workdir=${2:?}
    shift 2
    cd "$workdir"
    "$@"
    ;;
  *)
    echo "unexpected direnv args: $*" >&2
    exit 1
    ;;
esac
SH
  } >"${fakebin}/direnv"

  chmod +x "${fakebin}/direnv"
}

create_fixture_repo() {
  local name=$1
  local fixture_dir="${tmp_root}/${name}"
  local repo="${fixture_dir}/repo"
  local origin="${fixture_dir}/origin.git"

  mkdir -p "$fixture_dir"
  git init --quiet -b main "$repo"
  (
    cd "$repo"
    git config user.email "tests@example.invalid"
    git config user.name "Worktree Test"
    printf '%s\n' "# fixture" >README.md
    git add README.md
    git commit --quiet -m "init"
    printf '%s\n' "use flake" >.envrc

    git init --quiet --bare "$origin"
    git remote add origin "$origin"
    git push --quiet -u origin main

    git switch --quiet -c pr-feature
    printf '%s\n' "pr fixture" >pr.txt
    git add pr.txt
    git commit --quiet -m "add pr fixture"
    git push --quiet -u origin pr-feature
    git switch --quiet main
  )

  printf '%s\n' "$repo"
}

run_with_fake_tools() {
  local fakebin=$1
  local log=$2
  local workdir=$3
  shift 3

  touch "$log"
  (
    export PATH="${fakebin}:${PATH}"
    export REPO_SETUP_LOG="$log"
    cd "$workdir"
    "$@"
  )
}

test_repo_setup_loads_direnv_after_allowing_existing_envrc() {
  local repo
  local fakebin="${tmp_root}/fakebin-repo-setup-existing"
  local log="${tmp_root}/repo-setup-existing.log"
  local stdout="${tmp_root}/repo-setup-existing.out"
  local stderr="${tmp_root}/repo-setup-existing.err"

  repo=$(create_fixture_repo "repo-setup-existing")
  make_fake_direnv "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/repo-setup" --allow-direnv --skip-devshell-hooks >"$stdout" 2>"$stderr"

  assert_contains "$log" "args=allow ${repo}/.envrc"
  assert_contains "$log" "args=exec ${repo} true"
  assert_contains "$stdout" "* Allowed existing .envrc with direnv"
  assert_contains "$stdout" "* Loaded .envrc with direnv"
}

test_repo_setup_loads_direnv_after_allowing_generated_envrc() {
  local repo
  local fakebin="${tmp_root}/fakebin-repo-setup-generated"
  local log="${tmp_root}/repo-setup-generated.log"
  local stdout="${tmp_root}/repo-setup-generated.out"
  local stderr="${tmp_root}/repo-setup-generated.err"

  repo=$(create_fixture_repo "repo-setup-generated")
  make_fake_direnv "$fakebin"
  (
    cd "$repo"
    rm .envrc
    printf '%s\n' "{ outputs = { self }: { }; }" >flake.nix
  )

  run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/repo-setup" --skip-devshell-hooks >"$stdout" 2>"$stderr"

  assert_contains "$log" "args=allow ${repo}/.envrc"
  assert_contains "$log" "args=exec ${repo} true"
  assert_contains "$stdout" "* Created .envrc with use flake"
  assert_contains "$stdout" "* Allowed generated .envrc with direnv"
  assert_contains "$stdout" "* Loaded .envrc with direnv"
  assert_contains "${repo}/.envrc" "use flake"
}

test_repo_setup_does_not_load_direnv_when_envrc_is_not_allowed() {
  local repo
  local fakebin="${tmp_root}/fakebin-repo-setup-no-allow"
  local log="${tmp_root}/repo-setup-no-allow.log"
  local stdout="${tmp_root}/repo-setup-no-allow.out"
  local stderr="${tmp_root}/repo-setup-no-allow.err"

  repo=$(create_fixture_repo "repo-setup-no-allow")
  make_fake_direnv "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/repo-setup" --skip-devshell-hooks >"$stdout" 2>"$stderr"

  assert_contains "$stdout" "* Skipped allowing .envrc by default"
  assert_not_contains "$log" "direnv"
}

test_issue_from_primary_main_auto_allows() {
  local repo
  local fakebin="${tmp_root}/fakebin-primary"
  local log="${tmp_root}/primary.log"
  local stdout="${tmp_root}/primary.out"
  local stderr="${tmp_root}/primary.err"

  repo=$(create_fixture_repo "primary")
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" 101 >"$stdout" 2>"$stderr"

  assert_contains "$stdout" "Allowing copied source .envrc for issue worktree"
  assert_contains "$log" "args=--allow-direnv"
  assert_contains "${repo}/.worktrees/issue-101-direnv-allow-test/.envrc" "use flake"
}

test_issue_from_linked_worktree_copied_envrc_auto_allows_by_default() {
  local repo
  local linked
  local fakebin="${tmp_root}/fakebin-linked"
  local log="${tmp_root}/linked.log"
  local stdout="${tmp_root}/linked.out"
  local stderr="${tmp_root}/linked.err"

  repo=$(create_fixture_repo "linked")
  linked="${repo}/.worktrees/source-feature"
  (
    cd "$repo"
    git branch feature-source
    git worktree add --quiet "$linked" feature-source
  )
  (
    cd "$linked"
    printf '%s\n' "use flake feature-source" >.envrc
  )
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$linked" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" 202 >"$stdout" 2>"$stderr"

  assert_contains "$stdout" "Allowing copied source .envrc for issue worktree"
  assert_contains "$log" "args=--allow-direnv"
  assert_not_contains "$stdout" "not allowed"
  assert_contains "${linked}/.worktrees/issue-202-direnv-allow-test/.envrc" "feature-source"
}

test_issue_from_linked_flake_without_envrc_allows_generated_envrc_by_default() {
  local repo
  local linked
  local fakebin="${tmp_root}/fakebin-linked-flake"
  local log="${tmp_root}/linked-flake.log"
  local stdout="${tmp_root}/linked-flake.out"
  local stderr="${tmp_root}/linked-flake.err"

  repo=$(create_fixture_repo "linked-flake")
  linked="${repo}/.worktrees/source-flake-feature"
  (
    cd "$repo"
    git branch feature-flake
    git worktree add --quiet "$linked" feature-flake
  )
  (
    cd "$linked"
    git config user.email "tests@example.invalid"
    git config user.name "Worktree Test"
    cat >flake.nix <<'NIX'
{
  outputs = { self }: { };
}
NIX
    git add flake.nix
    git commit --quiet -m "add feature flake"
  )
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$linked" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" 404 >"$stdout" 2>"$stderr"

  assert_contains "$log" "args="
  assert_not_contains "$log" "--allow-direnv"
  assert_not_contains "$log" "--no-allow-generated-envrc"
  assert_not_contains "$stdout" "Allowing copied source .envrc for issue worktree"
  assert_not_contains "$stdout" "not allowed"
}

test_issue_branch_provided_envrc_is_not_allowed_by_default() {
  local repo
  local fakebin="${tmp_root}/fakebin-branch-envrc"
  local log="${tmp_root}/branch-envrc.log"
  local stdout="${tmp_root}/branch-envrc.out"
  local stderr="${tmp_root}/branch-envrc.err"

  repo=$(create_fixture_repo "branch-envrc")
  (
    cd "$repo"
    rm .envrc
    git switch --quiet -c issue-777-direnv-allow-test
    printf '%s\n' "use flake branch-provided" >.envrc
    git add -f .envrc
    git commit --quiet -m "add branch envrc"
    git switch --quiet main
    printf '%s\n' "use flake source-checkout" >.envrc
  )
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" 777 >"$stdout" 2>"$stderr"

  assert_contains "$stdout" "Existing .envrc from issue branch not allowed by default"
  assert_contains "$log" "args=--no-allow-generated-envrc"
  assert_not_contains "$log" "--allow-direnv"
  assert_contains "${repo}/.worktrees/issue-777-direnv-allow-test/.envrc" "branch-provided"
}

test_issue_branch_envrc_is_not_overwritten_by_source_envrc() {
  local repo
  local worktree
  local status
  local fakebin="${tmp_root}/fakebin-branch-envrc-source"
  local log="${tmp_root}/branch-envrc-source.log"
  local stdout="${tmp_root}/branch-envrc-source.out"
  local stderr="${tmp_root}/branch-envrc-source.err"

  repo=$(create_fixture_repo "branch-envrc-source")
  (
    cd "$repo"
    printf '%s\n' "use flake source-checkout" >.envrc
    git switch --quiet -c issue-778-direnv-allow-test
    printf '%s\n' "use flake branch-provided" >.envrc
    git add -f .envrc
    git commit --quiet -m "add branch envrc"
    git switch --quiet main
    printf '%s\n' "use flake source-checkout" >.envrc
  )
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" 778 >"$stdout" 2>"$stderr"

  worktree="${repo}/.worktrees/issue-778-direnv-allow-test"
  status=$(cd "$worktree" && git status --short)

  assert_contains "$stdout" "Existing .envrc from issue branch left unchanged"
  assert_contains "$stdout" "Existing .envrc from issue branch not allowed by default"
  assert_contains "$log" "args=--no-allow-generated-envrc"
  assert_not_contains "$log" "--allow-direnv"
  assert_contains "${worktree}/.envrc" "branch-provided"
  assert_not_contains "${worktree}/.envrc" "source-checkout"
  if [[ -n $status ]]; then
    echo "Unexpected worktree status:" >&2
    printf '%s\n' "$status" >&2
    fail "issue worktree was dirtied"
  fi
}

test_issue_branch_envrc_explicit_allow_new_worktree() {
  local repo
  local worktree
  local fakebin="${tmp_root}/fakebin-branch-envrc-allow"
  local log="${tmp_root}/branch-envrc-allow.log"
  local stdout="${tmp_root}/branch-envrc-allow.out"
  local stderr="${tmp_root}/branch-envrc-allow.err"

  repo=$(create_fixture_repo "branch-envrc-allow")
  (
    cd "$repo"
    printf '%s\n' "use flake source-checkout" >.envrc
    git switch --quiet -c issue-779-direnv-allow-test
    printf '%s\n' "use flake branch-provided" >.envrc
    git add -f .envrc
    git commit --quiet -m "add branch envrc"
    git switch --quiet main
    printf '%s\n' "use flake source-checkout" >.envrc
  )
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" --allow-direnv 779 >"$stdout" 2>"$stderr"

  worktree="${repo}/.worktrees/issue-779-direnv-allow-test"

  assert_contains "$log" "args=--allow-direnv"
  assert_contains "${worktree}/.envrc" "branch-provided"
  assert_not_contains "${worktree}/.envrc" "source-checkout"
}

test_issue_no_allow_direnv_opt_out_skips_default_allow() {
  local repo
  local fakebin="${tmp_root}/fakebin-no-allow"
  local log="${tmp_root}/no-allow.log"
  local stdout="${tmp_root}/no-allow.out"
  local stderr="${tmp_root}/no-allow.err"

  repo=$(create_fixture_repo "no-allow")
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" --no-allow-direnv 606 >"$stdout" 2>"$stderr"

  assert_contains "$stdout" "Copied .envrc not allowed by request"
  assert_contains "$log" "args=--no-allow-generated-envrc"
  assert_not_contains "$log" "--allow-direnv"
  assert_contains "${repo}/.worktrees/issue-606-direnv-allow-test/.envrc" "use flake"
}

test_existing_matching_issue_worktree_is_remediated_from_primary_main() {
  local repo
  local worktree
  local fakebin="${tmp_root}/fakebin-existing"
  local log="${tmp_root}/existing.log"
  local stdout="${tmp_root}/existing.out"
  local stderr="${tmp_root}/existing.err"

  repo=$(create_fixture_repo "existing")
  worktree="${repo}/.worktrees/issue-303-direnv-allow-test"
  (
    cd "$repo"
    mkdir -p .worktrees
    git worktree add --quiet -b issue-303-direnv-allow-test "$worktree" main
    cp .envrc "${worktree}/.envrc"
  )
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" 303 >"$stdout" 2>"$stderr"

  assert_contains "$stdout" "Allowing existing copied source .envrc for issue worktree"
  assert_contains "$log" "args=--allow-direnv"
}

test_existing_drifted_issue_worktree_is_not_auto_allowed() {
  local repo
  local worktree
  local fakebin="${tmp_root}/fakebin-existing-drifted"
  local log="${tmp_root}/existing-drifted.log"
  local stdout="${tmp_root}/existing-drifted.out"
  local stderr="${tmp_root}/existing-drifted.err"

  repo=$(create_fixture_repo "existing-drifted")
  worktree="${repo}/.worktrees/issue-505-direnv-allow-test"
  (
    cd "$repo"
    mkdir -p .worktrees
    git worktree add --quiet -b issue-505-direnv-allow-test "$worktree" main
    printf '%s\n' "use flake drifted" >"${worktree}/.envrc"
  )
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" 505 >"$stdout" 2>"$stderr"

  assert_contains "$stdout" "Existing .envrc differs from source .envrc"
  assert_not_contains "$log" "--allow-direnv"
}

test_existing_self_invocation_branch_envrc_is_not_auto_allowed() {
  local repo
  local worktree
  local fakebin="${tmp_root}/fakebin-existing-self"
  local log="${tmp_root}/existing-self.log"
  local stdout="${tmp_root}/existing-self.out"
  local stderr="${tmp_root}/existing-self.err"

  repo=$(create_fixture_repo "existing-self")
  worktree="${repo}/.worktrees/issue-889-direnv-allow-test"
  (
    cd "$repo"
    git worktree add --quiet -b issue-889-direnv-allow-test "$worktree" main
  )
  (
    cd "$worktree"
    git config user.email "tests@example.invalid"
    git config user.name "Worktree Test"
    printf '%s\n' "use flake branch-only-existing" >.envrc
    git add -f .envrc
    git commit --quiet -m "add existing branch envrc"
  )
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$worktree" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" 889 >"$stdout" 2>"$stderr"

  assert_contains "$stdout" "Existing .envrc from this issue worktree not allowed by default"
  assert_not_contains "$stdout" "Allowing existing copied source .envrc for issue worktree"
  assert_not_contains "$log" "--allow-direnv"
}

test_existing_self_invocation_branch_envrc_explicit_allow() {
  local repo
  local worktree
  local fakebin="${tmp_root}/fakebin-existing-self-allow"
  local log="${tmp_root}/existing-self-allow.log"
  local stdout="${tmp_root}/existing-self-allow.out"
  local stderr="${tmp_root}/existing-self-allow.err"

  repo=$(create_fixture_repo "existing-self-allow")
  worktree="${repo}/.worktrees/issue-890-direnv-allow-test"
  (
    cd "$repo"
    git worktree add --quiet -b issue-890-direnv-allow-test "$worktree" main
  )
  (
    cd "$worktree"
    git config user.email "tests@example.invalid"
    git config user.name "Worktree Test"
    printf '%s\n' "use flake branch-only-existing" >.envrc
    git add -f .envrc
    git commit --quiet -m "add existing branch envrc"
  )
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$worktree" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" --allow-direnv 890 >"$stdout" 2>"$stderr"

  assert_contains "$log" "args=--allow-direnv"
  assert_contains "${worktree}/.envrc" "branch-only-existing"
}

test_pr_default_does_not_allow_direnv() {
  local repo
  local fakebin="${tmp_root}/fakebin-pr"
  local log="${tmp_root}/pr.log"
  local stdout="${tmp_root}/pr.out"
  local stderr="${tmp_root}/pr.err"

  repo=$(create_fixture_repo "pr")
  make_fake_tools "$fakebin"

  run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/pr-worktree-create" 55 >"$stdout" 2>"$stderr"

  assert_contains "$log" "args=--no-allow-generated-envrc"
  assert_not_contains "$log" "--allow-direnv"
  assert_contains "${repo}/.worktrees/pr-55-pr-feature/.envrc" "use flake"
}

test_issue_multi_failure_exits_nonzero_without_success_footer() {
  local repo
  local fakebin="${tmp_root}/fakebin-failure"
  local log="${tmp_root}/failure.log"
  local stdout="${tmp_root}/failure.out"
  local stderr="${tmp_root}/failure.err"

  repo=$(create_fixture_repo "failure")
  make_fake_tools "$fakebin"

  if run_with_fake_tools "$fakebin" "$log" "$repo" \
    "$BASH" "${repo_root}/bin/issue-worktree-create" 111 222 >"$stdout" 2>"$stderr"; then
    fail "issue-worktree-create succeeded despite a failed issue"
  fi

  assert_contains "$stderr" "Error: Failed to fetch Issue #222. Skipping."
  assert_contains "$stderr" "Error: Some issue worktrees could not be prepared."
  assert_not_contains "$stdout" "* All issue worktrees are ready."
}

test_issue_from_primary_main_auto_allows
test_issue_from_linked_worktree_copied_envrc_auto_allows_by_default
test_issue_from_linked_flake_without_envrc_allows_generated_envrc_by_default
test_issue_branch_provided_envrc_is_not_allowed_by_default
test_issue_branch_envrc_is_not_overwritten_by_source_envrc
test_issue_branch_envrc_explicit_allow_new_worktree
test_issue_no_allow_direnv_opt_out_skips_default_allow
test_existing_matching_issue_worktree_is_remediated_from_primary_main
test_existing_drifted_issue_worktree_is_not_auto_allowed
test_existing_self_invocation_branch_envrc_is_not_auto_allowed
test_existing_self_invocation_branch_envrc_explicit_allow
test_pr_default_does_not_allow_direnv
test_issue_multi_failure_exits_nonzero_without_success_footer
test_repo_setup_loads_direnv_after_allowing_existing_envrc
test_repo_setup_loads_direnv_after_allowing_generated_envrc
test_repo_setup_does_not_load_direnv_when_envrc_is_not_allowed

echo "worktree direnv tests passed"
