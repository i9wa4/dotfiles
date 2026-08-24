#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

policy_file="skills/dotfiles/references/resume-handoff.md"
skill_file="skills/dotfiles/SKILL.md"

fail() {
  echo "$*" >&2
  exit 1
}

contains_public_gist_command() {
  awk '
	  function inspect(command) {
	    if (command ~ /^[[:space:]]*((command[[:space:]]+)|(env([[:space:]]+(-[[:alnum:]_=-]+|[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]+))*[[:space:]]+))?gh[[:space:]]+gist[[:space:]]+(create|edit|list|delete)([[:space:]]|$)/ && command ~ /(^|[[:space:]])--public([[:space:]]|$)/) {
	      print command
	      found = 1
	    }
	  }
    {
      line = $0
      sub(/[[:space:]]+$/, "", line)
      if (continued) {
        command = command " " line
      } else {
        command = line
      }
      if (line ~ /\\$/) {
        sub(/\\$/, "", command)
        continued = 1
        next
      }
      inspect(command)
      command = ""
      continued = 0
    }
    END {
      if (continued) {
        inspect(command)
      }
      exit(found ? 0 : 1)
    }
  ' "$1"
}

extract_documented_snippet() {
  marker=$1
  destination=$2
  awk -v marker="$marker" '
    $0 == marker { capture = 1; next }
    capture && /^```/ { exit }
    capture { print }
  ' "$policy_file" >"$destination"
  test -s "$destination" || fail "missing documented snippet: $marker"
}

fixture_dir=$(mktemp -d "${TMPDIR:-/tmp}/agent-task-gist-policy.XXXXXX")
cleanup_fixture_dir() {
  rm -rf "$fixture_dir"
}
trap cleanup_fixture_dir EXIT HUP INT TERM

assert_fixture_rejected() {
  name=$1
  shift
  printf '%s\n' "$@" >"$fixture_dir/$name"
  contains_public_gist_command "$fixture_dir/$name" >/dev/null ||
    fail "public-mode fixture bypassed validator: $name"
}

assert_fixture_allowed() {
  name=$1
  shift
  printf '%s\n' "$@" >"$fixture_dir/$name"
  if contains_public_gist_command "$fixture_dir/$name" >/dev/null; then
    fail "allowed fixture was rejected: $name"
  fi
}

run_public_mode_fixtures() {
  continuation=$(printf '%b' '\134')
  assert_fixture_rejected multiline-create \
    "gh gist create $continuation" \
    '  --public task.md'
  assert_fixture_rejected multiline-edit \
    "gh gist edit gist-id $continuation" \
    "  --filename task.md $continuation" \
    '  --public task.md'
  assert_fixture_rejected multiline-list \
    "gh gist list $continuation" \
    '  --public'
  assert_fixture_rejected multiline-delete \
    "gh gist delete $continuation" \
    '  --public gist-id'
  assert_fixture_rejected env-prefixed-public-create \
    'env GITHUB_TOKEN=fixture gh gist create --public task.md'
  assert_fixture_rejected command-prefixed-public-list \
    'command gh gist list --public'
  assert_fixture_allowed allowed-create \
    "gh gist create --desc 'agent-task:<repo>:<task>' task.md"
  assert_fixture_allowed allowed-multiline-create \
    "gh gist create $continuation" \
    "  --desc 'agent-task:<repo>:<task>' $continuation" \
    '  task.md'
  assert_fixture_allowed allowed-list 'gh gist list --secret --limit 100'
}

run_documented_snippet_fixtures() {
  mock_bin="$fixture_dir/mock-bin"
  mkdir "$mock_bin"

  cat >"$mock_bin/gh" <<'EOF'
#!/bin/sh
if [ "$1" = auth ] && [ "$2" = status ]; then
	printf '%s\n' 'Logged in to github.com account i9wa4'
	exit 0
fi
if [ "$1" = api ] && [ "$2" = user ] && [ "$3" = --jq ] && [ "$4" = .login ]; then
	printf '%s\n' "${GIST_MOCK_ACCOUNT:-i9wa4}"
	exit 0
fi
if [ "$1" = gist ] && [ "$2" = create ]; then
	case "${GIST_CREATE_MODE:-ok}" in
	ok)
		printf '%s\n' 'https://gist.github.com/fixtureGistId'
		;;
	stderr-url)
		printf '%s\n' 'https://gist.github.com/fixtureGistId' >&2
		printf '%s\n' 'https://gist.github.com/fixtureGistId'
		;;
	noisy)
		printf '%s\n%s\n' 'created:' 'https://gist.github.com/fixtureGistId'
		;;
	multiline)
		printf '%s\n%s\n' 'https://gist.github.com/fixtureGistId' 'https://gist.github.com/other'
		;;
	malformed)
		printf '%s\n' 'not-a-gist-url'
		;;
	*)
		exit 64
		;;
	esac
	exit 0
fi
if [ "$1" = gist ] && [ "$2" = edit ] && [ "$3" = fixtureGistId ]; then
	exit 0
fi
if [ "$1" = gist ] && [ "$2" = delete ]; then
	printf '%s\n' "$3" >> "$GIST_DELETE_RECORD"
	exit 0
fi
if [ "$1" = gist ] && [ "$2" = view ]; then
	cat "$GIST_FIXTURE_SOURCE"
	exit 0
fi
if [ "$1" = api ] && [ "$2" = gists/fixtureGistId ] && [ "$3" = --jq ]; then
	case "$4" in
	.public)
		printf '%s\n' "${GIST_MOCK_PUBLIC:-false}"
		;;
	.description)
		printf '%s\n' "${GIST_MOCK_DESCRIPTION:-agent-task:<repo>:<task>}"
		;;
	'.files | keys | length')
		printf '%s\n' "${GIST_MOCK_FILE_COUNT:-1}"
		;;
	'.files | keys[0]')
		printf '%s\n' "${GIST_MOCK_FILENAME:-task.md}"
		;;
	.html_url)
		: > "$GIST_URL_HANDOFF_RECORD"
		printf '%s\n' 'https://gist.github.com/fixtureGistId'
		;;
	*)
		exit 64
		;;
	esac
	exit 0
fi
exit 64
EOF
  chmod 700 "$mock_bin/gh"

  cat >"$mock_bin/rm" <<'EOF'
#!/bin/sh
if [ -n "${GIST_CLEANUP_RECORD:-}" ]; then
	printf '%s\n' "$2" > "$GIST_CLEANUP_RECORD"
fi
exec /bin/rm "$@"
EOF
  chmod 700 "$mock_bin/rm"

  cat >"$mock_bin/rg" <<'EOF'
#!/bin/sh
exit 1
EOF
  chmod 700 "$mock_bin/rg"

  cat >"$mock_bin/shasum" <<'EOF'
#!/bin/sh
if [ "$1" != -a ] || [ "$2" != 256 ]; then
  exit 64
fi
case "$(cat "$3")" in
"fixture memo")
  printf '%s  %s\n' '1c72c50d1320856521d1a956f0cae3c257091c72294a1c99a22b337417457127' "$3"
  ;;
"different memo")
  printf '%s  %s\n' 'e9cf18bd5c7a707b7c5f624f45639792a38b2ed609c5fbfb6d2df921c68bf858' "$3"
  ;;
*)
  exit 64
  ;;
esac
EOF
  chmod 700 "$mock_bin/shasum"

  printf 'fixture memo\n' >"$fixture_dir/task.md"
  extract_documented_snippet '# agent-task-gist-create-read-back' "$fixture_dir/create-read-back.sh"
  extract_documented_snippet '# agent-task-gist-url-handoff' "$fixture_dir/url-handoff.sh"
  {
    printf 'set -e\n'
    cat "$fixture_dir/create-read-back.sh"
    cat "$fixture_dir/url-handoff.sh"
    # shellcheck disable=SC2016 # The generated script must write this literal expansion.
    printf '%s\n' 'printf "%s\n" "$secret_gist_url" > "$GIST_URL_HANDOFF_RECORD"'
  } >"$fixture_dir/create-url-flow.sh"
  GIST_URL_HANDOFF_RECORD="$fixture_dir/create-url-record" \
    GIST_DELETE_RECORD="$fixture_dir/create-delete-record" \
    PATH="$mock_bin:$PATH" \
    task_file="$fixture_dir/task.md" \
    sh "$fixture_dir/create-read-back.sh" >"$fixture_dir/create-read-back.out"
  if grep -Fq 'https://gist.github.com/' "$fixture_dir/create-read-back.out"; then
    fail "documented create/read-back flow prints the secret URL before verification"
  fi
  test ! -e "$fixture_dir/create-delete-record" ||
    fail "documented create/read-back flow cleaned up after successful metadata verification"

  assert_create_failure_blocks_handoff() {
    name=$1
    shift
    out_file="$fixture_dir/$name.out"
    err_file="$fixture_dir/$name.err"
    url_record="$fixture_dir/$name-url-record"
    delete_record="$fixture_dir/$name-delete-record"
    if GIST_URL_HANDOFF_RECORD="$url_record" \
      GIST_DELETE_RECORD="$delete_record" \
      PATH="$mock_bin:$PATH" \
      task_file="$fixture_dir/task.md" \
      env "$@" sh "$fixture_dir/create-url-flow.sh" >"$out_file" 2>"$err_file"; then
      fail "documented create/read-back failure reached URL handoff: $name"
    fi
    if grep -Fq 'https://gist.github.com/' "$out_file" "$err_file"; then
      fail "documented create/read-back failure leaked URL to logs: $name"
    fi
    test ! -e "$url_record" ||
      fail "documented create/read-back failure created URL handoff record: $name"
  }

  assert_create_failure_blocks_handoff bad-account GIST_MOCK_ACCOUNT=other-user
  assert_create_failure_blocks_handoff public-metadata GIST_MOCK_PUBLIC=true
  test "$(cat "$fixture_dir/public-metadata-delete-record")" = fixtureGistId ||
    fail "public metadata failure did not clean up the created Gist"
  assert_create_failure_blocks_handoff wrong-description GIST_MOCK_DESCRIPTION=wrong
  test "$(cat "$fixture_dir/wrong-description-delete-record")" = fixtureGistId ||
    fail "wrong description failure did not clean up the created Gist"
  assert_create_failure_blocks_handoff wrong-filename GIST_MOCK_FILENAME=wrong.md
  test "$(cat "$fixture_dir/wrong-filename-delete-record")" = fixtureGistId ||
    fail "wrong filename failure did not clean up the created Gist"
  assert_create_failure_blocks_handoff multiple-filenames GIST_MOCK_FILE_COUNT=2
  test "$(cat "$fixture_dir/multiple-filenames-delete-record")" = fixtureGistId ||
    fail "multiple filename failure did not clean up the created Gist"
  assert_create_failure_blocks_handoff stderr-url-leakage GIST_CREATE_MODE=stderr-url
  assert_create_failure_blocks_handoff noisy-create-output GIST_CREATE_MODE=noisy
  assert_create_failure_blocks_handoff multiline-create-output GIST_CREATE_MODE=multiline
  assert_create_failure_blocks_handoff malformed-create-output GIST_CREATE_MODE=malformed

  extract_documented_snippet '# agent-task-gist-delete-confirmation' "$fixture_dir/delete.sh"
  sed 's/<reviewed-gist-id>/fixtureGistId/g' "$fixture_dir/delete.sh" >"$fixture_dir/delete-fixture.sh"
  GIST_DELETE_RECORD="$fixture_dir/delete-record" \
    PATH="$mock_bin:$PATH" \
    sh "$fixture_dir/delete-fixture.sh" <<'EOF'
fixtureGistId
EOF
  test -f "$fixture_dir/delete-record" ||
    fail "documented deletion confirmation did not invoke the exact approved ID"
  GIST_DELETE_RECORD="$fixture_dir/delete-record-bash" \
    PATH="$mock_bin:$PATH" \
    bash "$fixture_dir/delete-fixture.sh" <<'EOF'
fixtureGistId
EOF
  test -f "$fixture_dir/delete-record-bash" ||
    fail "documented deletion confirmation is not Bash-compatible"

  extract_documented_snippet '# agent-task-gist-raw-verification' "$fixture_dir/raw.sh"
  GIST_CLEANUP_RECORD="$fixture_dir/cleanup-record" \
    GIST_FIXTURE_SOURCE="$fixture_dir/task.md" \
    gist_id=fixtureGistId \
    task_file="$fixture_dir/task.md" \
    PATH="$mock_bin:$PATH" \
    env -u TMPDIR sh "$fixture_dir/raw.sh"
  test -s "$fixture_dir/cleanup-record" ||
    fail "documented raw verification did not clean up its temporary directory"
  cleaned_directory=$(cat "$fixture_dir/cleanup-record")
  case "$cleaned_directory" in
  /tmp/agent-task-gist.*) ;;
  *) fail "documented raw verification did not use the TMPDIR fallback: $cleaned_directory" ;;
  esac
  test ! -e "$cleaned_directory" ||
    fail "documented raw verification left its temporary directory behind"

  printf 'different memo\n' >"$fixture_dir/mismatch-task.md"
  GIST_CLEANUP_RECORD="$fixture_dir/mismatch-cleanup-record" \
    GIST_FIXTURE_SOURCE="$fixture_dir/mismatch-task.md" \
    gist_id=fixtureGistId \
    task_file="$fixture_dir/task.md" \
    PATH="$mock_bin:$PATH" \
    env -u TMPDIR sh "$fixture_dir/raw.sh" >"$fixture_dir/raw-mismatch.out" 2>&1 &&
    fail "documented raw verification accepted mismatched content"
  test -s "$fixture_dir/mismatch-cleanup-record" ||
    fail "documented raw verification mismatch path did not clean up"
  mismatch_cleaned_directory=$(cat "$fixture_dir/mismatch-cleanup-record")
  test ! -e "$mismatch_cleaned_directory" ||
    fail "documented raw verification mismatch path left its temporary directory behind"

  {
    printf 'set -e\n'
    cat "$fixture_dir/create-read-back.sh"
    cat "$fixture_dir/raw.sh"
    cat "$fixture_dir/url-handoff.sh"
    # shellcheck disable=SC2016 # The generated script must write this literal expansion.
    printf '%s\n' 'printf "%s\n" "$secret_gist_url" > "$GIST_URL_HANDOFF_RECORD"'
  } >"$fixture_dir/full-mismatch-flow.sh"
  GIST_CLEANUP_RECORD="$fixture_dir/full-mismatch-cleanup-record" \
    GIST_FIXTURE_SOURCE="$fixture_dir/mismatch-task.md" \
    GIST_URL_HANDOFF_RECORD="$fixture_dir/url-handoff-record" \
    task_file="$fixture_dir/task.md" \
    PATH="$mock_bin:$PATH" \
    env -u TMPDIR sh "$fixture_dir/full-mismatch-flow.sh" >"$fixture_dir/full-mismatch-flow.out" 2>&1 &&
    fail "documented full flow reached URL handoff after mismatched content"
  if grep -Fq 'https://gist.github.com/' "$fixture_dir/full-mismatch-flow.out"; then
    fail "documented mismatch flow printed the secret URL"
  fi
  test ! -e "$fixture_dir/url-handoff-record" ||
    fail "documented mismatch flow reached URL handoff"
}

# shellcheck disable=SC2016 # The literal command text is the policy assertion.
for required in \
  '1 task = 1 Gist = 1 Markdown file' \
  'agent-task:<repo>:<task>' \
  'secret/unlisted' \
  'not access-controlled private storage' \
  'gh auth status' \
  'public=false' \
  'shasum -a 256' \
  'gh gist list --secret' \
  'per-Gist confirmation' \
  'Do not use `gh gist delete --yes`'; do
  grep -Fq -- "$required" "$policy_file" ||
    fail "missing required agent-task Gist policy text: $required"
done

grep -Fq -- 'optional portable agent task-memo Gists' "$skill_file" ||
  fail "dotfiles skill does not expose portable agent task-memo Gists"

if contains_public_gist_command "$policy_file"; then
  fail "agent-task Gist policy offers a public-mode command path"
fi

run_public_mode_fixtures
run_documented_snippet_fixtures

url_handoff_line=$(grep -n '^# agent-task-gist-url-handoff$' "$policy_file" | cut -d: -f1)
url_assignment_line=$(grep -n '^secret_gist_url=' "$policy_file" | cut -d: -f1)
test -n "$url_handoff_line" || fail "missing post-verification URL handoff marker"
test -n "$url_assignment_line" || fail "missing post-verification URL handoff assignment"
test "$url_assignment_line" -gt "$url_handoff_line" ||
  fail "secret URL is assigned before the approved handoff stage"

echo "agent-task Gist policy validation passed"
