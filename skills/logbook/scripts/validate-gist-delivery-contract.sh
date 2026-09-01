#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

fail() {
  echo "gist delivery contract: $*" >&2
  exit 1
}

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)
reference="$repo_root/skills/logbook/references/gist-delivery.md"
verifier="$repo_root/skills/logbook/scripts/verify-gist-delivery"
real_rg=$(command -v rg)

require_doc() {
  pattern=$1
  rg --fixed-strings --quiet "$pattern" "$reference" ||
    fail "missing documented contract: $pattern"
}

assert_success() {
  name=$1
  shift
  "$@" >/dev/null || fail "expected success: $name"
}

assert_failure() {
  name=$1
  shift
  if "$@" >/dev/null 2>&1; then
    fail "expected failure: $name"
  fi
}

# shellcheck disable=SC2030,SC2031
run_verifier_fixture() {
  (
    export PATH="$mock_bin:$PATH"
    export MKMD_ARTIFACT="$source_file"
    export GIST_ID="abc123"
    export GIST_OWNER="example-owner"
    export GIST_DESCRIPTION="Expected handoff"
    export GIST_FILENAME="source.md"
    export GIST_EXPECTED_FILES="source.md"
    export ARTIFACTS_GIST_SOURCE="$source_file"
    export ARTIFACTS_GIST_REAL_RG="$real_rg"
    bash "$verifier"
  )
}

# shellcheck disable=SC2030,SC2031
run_operator_fixture() {
  (
    cd "$operator_cwd"
    export PATH="$mock_bin:$PATH"
    export MKMD_ARTIFACT="$source_file"
    export GIST_ID="abc123"
    export GIST_OWNER="example-owner"
    export GIST_DESCRIPTION="Expected handoff"
    export GIST_FILENAME="source.md"
    export GIST_EXPECTED_FILES="source.md"
    export ARTIFACTS_GIST_SOURCE="$source_file"
    export ARTIFACTS_GIST_REAL_RG="$real_rg"
    if test "${ARTIFACTS_OPERATOR_EXPORT_ROOT:-1}" = 1; then
      export LOGBOOK_SKILL_ROOT="$repo_root/skills/logbook"
    else
      unset LOGBOOK_SKILL_ROOT
    fi
    bash "${LOGBOOK_SKILL_ROOT}/scripts/verify-gist-delivery"
  )
}

run_old_relative_operator_fixture() {
  (
    cd "$operator_cwd"
    skills/logbook/scripts/verify-gist-delivery
  )
}

require_doc 'LOGBOOK_SKILL_ROOT'
# shellcheck disable=SC2016
require_doc '${LOGBOOK_SKILL_ROOT}/scripts/verify-gist-delivery'
require_doc 'public=false'
require_doc 'GIST_DESCRIPTION'
require_doc 'GIST_EXPECTED_FILES'
require_doc 'GIST_REPLACEMENT_OLD_FILENAME'
require_doc '/Users/...'
require_doc 'visibility/metadata differs'

test -x "$verifier" || fail "verifier is not executable: $verifier"
bash -n "$verifier"

fixture_dir=$(mktemp -d "${TMPDIR:-/tmp}/logbook-gist-contract.XXXXXX")
cleanup_fixture_dir() {
  rm -rf "$fixture_dir"
}
trap cleanup_fixture_dir EXIT HUP INT TERM

first_tmp=$(mktemp -d "${TMPDIR:-/tmp}/logbook-gist.XXXXXX")
second_tmp=$(mktemp -d "${TMPDIR:-/tmp}/logbook-gist.XXXXXX")
test -d "$first_tmp" || fail "first temporary directory was not created"
test -d "$second_tmp" || fail "second temporary directory was not created"
test "$first_tmp" != "$second_tmp" || fail "temporary directory names are not unique"
rm -rf "$first_tmp" "$second_tmp"
operator_cwd=$(mktemp -d "${TMPDIR:-/tmp}/logbook-gist-unrelated-cwd.XXXXXX")
test -d "$operator_cwd" || fail "operator cwd was not created"

mock_bin="$fixture_dir/bin"
mkdir "$mock_bin"

cat >"$mock_bin/gh" <<'EOF'
#!/bin/sh
case "$1 $2" in
"api gists/abc123")
  printf '%s\t%s\t%s\t%s\n' \
    "${ARTIFACTS_GIST_PUBLIC:-false}" \
    "${ARTIFACTS_GIST_DESCRIPTION_ACTUAL:-Expected handoff}" \
    "${ARTIFACTS_GIST_FILES_ACTUAL:-source.md}" \
    "${ARTIFACTS_GIST_URL_ACTUAL:-https://gist.github.com/example-owner/abc123}"
  ;;
*)
  exit 64
  ;;
esac
EOF
chmod 700 "$mock_bin/gh"

cat >"$mock_bin/curl" <<'EOF'
#!/bin/sh
case "${ARTIFACTS_GIST_CURL_MODE:-ok}" in
ok)
  case "$*" in
  *"--head"*) exit 0 ;;
  *) cat "$ARTIFACTS_GIST_SOURCE" ;;
  esac
  ;;
changed)
  case "$*" in
  *"--head"*) exit 0 ;;
  *) printf '%s\n' 'changed content' ;;
  esac
  ;;
fail-head)
  case "$*" in
  *"--head"*) exit 22 ;;
  *) cat "$ARTIFACTS_GIST_SOURCE" ;;
  esac
  ;;
fail-raw)
  case "$*" in
  *"--head"*) exit 0 ;;
  *) exit 22 ;;
  esac
  ;;
*)
  exit 64
  ;;
esac
EOF
chmod 700 "$mock_bin/curl"

cat >"$mock_bin/rg" <<'EOF'
#!/bin/sh
case "${ARTIFACTS_GIST_RG_MODE:-real}" in
clean) exit 1 ;;
hit) exit 0 ;;
error) exit 2 ;;
real) exec "$ARTIFACTS_GIST_REAL_RG" "$@" ;;
*) exit 64 ;;
esac
EOF
chmod 700 "$mock_bin/rg"

source_file="$fixture_dir/source.md"
printf '%s\n' 'clean handoff body' >"$source_file"

ARTIFACTS_GIST_RG_MODE=clean assert_success clean-copy run_verifier_fixture
ARTIFACTS_GIST_RG_MODE=clean assert_success injected-root-operator run_operator_fixture
ARTIFACTS_GIST_RG_MODE=clean assert_failure old-relative-operator run_old_relative_operator_fixture
ARTIFACTS_OPERATOR_EXPORT_ROOT=0 \
  ARTIFACTS_GIST_RG_MODE=clean \
  assert_failure missing-logbook-skill-root run_operator_fixture

ARTIFACTS_GIST_CURL_MODE=changed \
  ARTIFACTS_GIST_RG_MODE=clean \
  assert_failure byte-mismatch run_verifier_fixture

ARTIFACTS_GIST_PUBLIC=true \
  ARTIFACTS_GIST_RG_MODE=clean \
  assert_failure public-visibility run_verifier_fixture

ARTIFACTS_GIST_DESCRIPTION_ACTUAL="Wrong description" \
  ARTIFACTS_GIST_RG_MODE=clean \
  assert_failure wrong-description run_verifier_fixture

ARTIFACTS_GIST_FILES_ACTUAL="other.md" \
  ARTIFACTS_GIST_RG_MODE=clean \
  assert_failure wrong-filename-file-set run_verifier_fixture

GIST_REPLACEMENT_OLD_FILENAME=source.md \
  ARTIFACTS_GIST_RG_MODE=clean \
  assert_failure replacement-collision run_verifier_fixture

ARTIFACTS_GIST_CURL_MODE=fail-head \
  ARTIFACTS_GIST_RG_MODE=clean \
  assert_failure html-transport-failure run_verifier_fixture

ARTIFACTS_GIST_CURL_MODE=fail-raw \
  ARTIFACTS_GIST_RG_MODE=clean \
  assert_failure raw-transport-failure run_verifier_fixture

ARTIFACTS_GIST_RG_MODE=hit assert_failure private-scan-hit run_verifier_fixture
ARTIFACTS_GIST_RG_MODE=error assert_failure private-scan-error run_verifier_fixture

# private-content-scan: allow-next-line -- fixture proves machine-local path detection fails closed.
printf '%s\n' 'local path /Users/example/private.md' >"$source_file"
ARTIFACTS_GIST_RG_MODE=real assert_failure machine-local-users-path run_verifier_fixture

# private-content-scan: allow-next-line -- fixtures prove Linux, checkout, and Nix paths fail closed.
printf '%s\n' 'local path /home/example/private.md' >"$source_file"
ARTIFACTS_GIST_RG_MODE=real assert_failure machine-local-home-path run_verifier_fixture

printf '%s\n' 'local checkout ~/ghq/github.com/i9wa4/dotfiles' >"$source_file"
ARTIFACTS_GIST_RG_MODE=real assert_failure machine-local-ghq-path run_verifier_fixture

printf '%s\n' 'local store /nix/store/example-source' >"$source_file"
ARTIFACTS_GIST_RG_MODE=real assert_failure machine-local-nix-store-path run_verifier_fixture

echo "gist delivery contract: OK"
