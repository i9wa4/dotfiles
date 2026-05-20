#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

repo_root="$(git rev-parse --show-toplevel)"
guard="${repo_root}/bin/git-branch-publication-guard"
tmp_dir="$(mktemp -d)"
zero_oid="0000000000000000000000000000000000000000"

cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

git init -q "${tmp_dir}"
cd "${tmp_dir}"
git config user.email "test@example.invalid"
git config user.name "Test User"
touch README.md
git add README.md
git commit -qm "test: initial"
git switch -c issue-205-test >/dev/null
head_oid="$(git rev-parse HEAD)"

run_guard() {
  local line=$1
  local output_file="${tmp_dir}/guard.out"

  if printf '%s\n' "${line}" | "${guard}" origin "git@example.invalid:owner/repo.git" >"${output_file}" 2>&1; then
    return 0
  fi
  return 1
}

assert_allows() {
  local name=$1
  local line=$2

  if ! run_guard "${line}"; then
    echo "FAIL: expected allow: ${name}" >&2
    cat "${tmp_dir}/guard.out" >&2
    exit 1
  fi
}

assert_rejects() {
  local name=$1
  local line=$2
  local expected=$3

  if run_guard "${line}"; then
    echo "FAIL: expected reject: ${name}" >&2
    exit 1
  fi
  if ! grep -Fq "${expected}" "${tmp_dir}/guard.out"; then
    echo "FAIL: expected reject message for ${name}: ${expected}" >&2
    cat "${tmp_dir}/guard.out" >&2
    exit 1
  fi
}

assert_allows \
  "same-name HEAD publication" \
  "HEAD ${head_oid} refs/heads/issue-205-test ${zero_oid}"
assert_allows \
  "same-name refs/heads publication" \
  "refs/heads/issue-205-test ${head_oid} refs/heads/issue-205-test ${zero_oid}"
assert_allows \
  "tag publication ignored by branch guard" \
  "refs/tags/v1 ${head_oid} refs/tags/v1 ${zero_oid}"
assert_allows \
  "delete ignored by branch guard" \
  "(delete) ${zero_oid} refs/heads/main ${head_oid}"

assert_rejects \
  "mismatched branch destination" \
  "refs/heads/issue-205-test ${head_oid} refs/heads/other-feature ${zero_oid}" \
  "branch-name mismatch"
assert_rejects \
  "protected main destination" \
  "refs/heads/issue-205-test ${head_oid} refs/heads/main ${zero_oid}" \
  "protected branch 'main'"
assert_rejects \
  "protected dev destination" \
  "refs/heads/issue-205-test ${head_oid} refs/heads/dev ${zero_oid}" \
  "protected branch 'dev'"
assert_rejects \
  "raw object to branch destination" \
  "${head_oid} ${head_oid} refs/heads/issue-205-test ${zero_oid}" \
  "does not identify a local branch"

echo "git-branch-publication-guard smoke checks passed"
