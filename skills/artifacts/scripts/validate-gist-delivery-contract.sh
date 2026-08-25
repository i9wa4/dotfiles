#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

fail() {
  echo "gist delivery contract: $*" >&2
  exit 1
}

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)
reference="$repo_root/skills/artifacts/references/gist-delivery.md"

require_doc() {
  pattern=$1
  rg --fixed-strings --quiet "$pattern" "$reference" ||
    fail "missing documented contract: $pattern"
}

make_verify_tmp() {
  mktemp -d "${TMPDIR:-/tmp}/artifacts-gist.XXXXXX"
}

fetch_raw_copy() {
  url=$1
  destination=$2
  curl --fail --location --silent --show-error "$url" >"$destination"
}

scan_raw_copy() {
  file=$1
  set +e
  rg --quiet '/\.local/|tmux-a2a|pop_receipt|BEGIN (RSA|OPENSSH|PRIVATE)' "$file"
  rg_status=$?
  set -e
  case "$rg_status" in
  0)
    return 10
    ;;
  1)
    return 0
    ;;
  *)
    return 11
    ;;
  esac
}

verify_raw_copy() {
  source_file=$1
  raw_file=$2

  cmp -s "$source_file" "$raw_file" || return 20

  source_hash=$(shasum -a 256 "$source_file" | awk '{print $1}')
  raw_hash=$(shasum -a 256 "$raw_file" | awk '{print $1}')
  test "$source_hash" = "$raw_hash" || return 21

  scan_raw_copy "$raw_file"
}

assert_success() {
  name=$1
  shift
  "$@" || fail "expected success: $name"
}

assert_failure() {
  name=$1
  shift
  if "$@"; then
    fail "expected failure: $name"
  fi
}

# shellcheck disable=SC2016 # Literal documentation snippet must not expand.
require_doc 'mktemp -d "${TMPDIR:-/tmp}/artifacts-gist.XXXXXX"'
require_doc 'curl --fail --location --silent --show-error'
# shellcheck disable=SC2016 # Literal documentation snippet must not expand.
require_doc 'cmp -s "$MKMD_ARTIFACT" "$verify_tmp/gist-raw.md"'
# shellcheck disable=SC2016 # Literal documentation snippet must not expand.
require_doc 'shasum -a 256 "$MKMD_ARTIFACT" "$verify_tmp/gist-raw.md"'
require_doc 'rg_status=$?'
require_doc '0) echo "private content found in Gist raw copy" >&2; exit 1 ;;'
require_doc '1) : ;;'
# shellcheck disable=SC2016 # Literal documentation snippet must not expand.
require_doc '*) echo "private-content scan failed with status $rg_status" >&2; exit 1 ;;'
require_doc 'When replacing an earlier Gist delivery copy'

fixture_dir=$(mktemp -d "${TMPDIR:-/tmp}/artifacts-gist-contract.XXXXXX")
cleanup_fixture_dir() {
  rm -rf "$fixture_dir"
}
trap cleanup_fixture_dir EXIT HUP INT TERM

first_tmp=$(make_verify_tmp)
second_tmp=$(make_verify_tmp)
test -d "$first_tmp" || fail "first temporary directory was not created"
test -d "$second_tmp" || fail "second temporary directory was not created"
test "$first_tmp" != "$second_tmp" || fail "temporary directory names are not unique"
rm -rf "$first_tmp" "$second_tmp"

mock_bin="$fixture_dir/bin"
mkdir "$mock_bin"

cat >"$mock_bin/curl" <<'EOF'
#!/bin/sh
case "${ARTIFACTS_GIST_CURL_MODE:-ok}" in
ok)
  cat "$ARTIFACTS_GIST_SOURCE"
  ;;
changed)
  printf '%s\n' 'changed content'
  ;;
fail)
  exit 22
  ;;
*)
  exit 64
  ;;
esac
EOF
chmod 700 "$mock_bin/curl"

cat >"$mock_bin/rg" <<'EOF'
#!/bin/sh
case "${ARTIFACTS_GIST_RG_MODE:-clean}" in
clean) exit 1 ;;
hit) exit 0 ;;
error) exit 2 ;;
*) exit 64 ;;
esac
EOF
chmod 700 "$mock_bin/rg"

source_file="$fixture_dir/source.md"
raw_file="$fixture_dir/raw.md"
printf '%s\n' 'clean handoff body' >"$source_file"

PATH="$mock_bin:$PATH" \
  ARTIFACTS_GIST_SOURCE="$source_file" \
  ARTIFACTS_GIST_CURL_MODE=ok \
  fetch_raw_copy "https://example.invalid/raw" "$raw_file"

PATH="$mock_bin:$PATH" ARTIFACTS_GIST_RG_MODE=clean \
  assert_success clean-copy verify_raw_copy "$source_file" "$raw_file"

PATH="$mock_bin:$PATH" ARTIFACTS_GIST_RG_MODE=hit \
  assert_failure private-scan-hit verify_raw_copy "$source_file" "$raw_file"

PATH="$mock_bin:$PATH" ARTIFACTS_GIST_RG_MODE=error \
  assert_failure private-scan-error verify_raw_copy "$source_file" "$raw_file"

changed_raw="$fixture_dir/changed.md"
PATH="$mock_bin:$PATH" \
  ARTIFACTS_GIST_SOURCE="$source_file" \
  ARTIFACTS_GIST_CURL_MODE=changed \
  fetch_raw_copy "https://example.invalid/raw" "$changed_raw"
PATH="$mock_bin:$PATH" ARTIFACTS_GIST_RG_MODE=clean \
  assert_failure changed-copy verify_raw_copy "$source_file" "$changed_raw"

failed_raw="$fixture_dir/failed.md"
PATH="$mock_bin:$PATH" \
  ARTIFACTS_GIST_SOURCE="$source_file" \
  ARTIFACTS_GIST_CURL_MODE=fail \
  assert_failure failing-transport fetch_raw_copy "https://example.invalid/raw" "$failed_raw"

replacement_raw="$fixture_dir/replacement.md"
printf '%s\n' 'replacement body' >"$replacement_raw"
PATH="$mock_bin:$PATH" ARTIFACTS_GIST_RG_MODE=clean \
  assert_failure replacement-mismatch verify_raw_copy "$source_file" "$replacement_raw"

echo "gist delivery contract: OK"
