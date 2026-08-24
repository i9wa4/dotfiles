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
    function is_assignment(token) {
      return token ~ /^[A-Za-z_][A-Za-z0-9_]*=/
    }
    function first_command_token(token_count, tokens, token_index) {
      token_index = 1
      while (token_index <= token_count) {
        if (tokens[token_index] == "env") {
          token_index++
          while (token_index <= token_count) {
            if (tokens[token_index] == "-u" || tokens[token_index] == "--unset") {
              token_index += 2
            } else if (tokens[token_index] ~ /^-u./ || tokens[token_index] ~ /^--unset=/ || is_assignment(tokens[token_index])) {
              token_index++
            } else if (tokens[token_index] ~ /^-/) {
              token_index++
            } else {
              break
            }
          }
        } else if (tokens[token_index] == "command") {
          token_index++
          while (token_index <= token_count && tokens[token_index] ~ /^-/) {
            token_index++
          }
        } else {
          break
        }
      }
      return token_index
    }
    function is_public_token(token) {
      return token == "--public" || token ~ /^--public=/ || token == "-p"
    }
    function inspect(command, token_count, tokens, token_index, action_index, public_index) {
      sub(/^[[:space:]]+/, "", command)
      sub(/[[:space:]]+$/, "", command)
      token_count = split(command, tokens, /[[:space:]]+/)
      token_index = first_command_token(token_count, tokens)
      action_index = token_index + 2
      if (tokens[token_index] != "gh" || tokens[token_index + 1] != "gist") {
        return
      }
      if (tokens[action_index] !~ /^(create|edit|list|delete)$/) {
        return
      }
      for (public_index = action_index + 1; public_index <= token_count; public_index++) {
        if (is_public_token(tokens[public_index])) {
          print command
          found = 1
          return
        }
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
  assert_fixture_rejected env-unset-prefixed-public-create \
    'env -u TOKEN gh gist create --public task.md'
  assert_fixture_rejected command-prefixed-public-list \
    'command gh gist list --public'
  assert_fixture_rejected command-path-prefixed-public-create \
    'command -p gh gist create --public task.md'
  assert_fixture_rejected public-equals-create \
    'gh gist create --public=true task.md'
  assert_fixture_rejected short-public-create \
    'gh gist create -p task.md'
  assert_fixture_allowed allowed-create \
    "gh gist create --desc 'agent-task:<repo>:<task>' task.md"
  assert_fixture_allowed allowed-multiline-create \
    "gh gist create $continuation" \
    "  --desc 'agent-task:<repo>:<task>' $continuation" \
    '  task.md'
  assert_fixture_allowed allowed-list 'gh gist list --secret --limit 100'
  assert_fixture_allowed allowed-publicity-token \
    'gh gist create --publicity task.md'
  assert_fixture_allowed allowed-preview-short-token \
    'gh gist create -preview task.md'
  assert_fixture_allowed allowed-quoted-text \
    'printf "%s\n" "gh gist create --public task.md"'
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
if [ "${GIST_SCAN_MODE:-ok}" = fail ]; then
	printf '%s\n' '1:tmux-a2a'
	exit 0
fi
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
    expected_pending_id=$2
    shift
    shift
    out_file="$fixture_dir/$name.out"
    err_file="$fixture_dir/$name.err"
    url_record="$fixture_dir/$name-url-record"
    delete_record="$fixture_dir/$name-delete-record"
    pending_record="$fixture_dir/$name-pending-cleanup"
    if GIST_URL_HANDOFF_RECORD="$url_record" \
      GIST_DELETE_RECORD="$delete_record" \
      pending_cleanup_record="$pending_record" \
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
    test ! -e "$delete_record" ||
      fail "documented create/read-back failure deleted before reviewed confirmation: $name"
    if [ "$expected_pending_id" != none ]; then
      test -s "$pending_record" ||
        fail "documented create/read-back failure left no pending cleanup record: $name"
      if grep -Fq 'https://gist.github.com/' "$pending_record"; then
        fail "documented pending cleanup record leaked URL: $name"
      fi
      if [ "$expected_pending_id" != unknown ]; then
        grep -Fq "gist_id=$expected_pending_id" "$pending_record" ||
          fail "documented pending cleanup record did not include exact Gist ID: $name"
      fi
    fi
  }

  assert_create_failure_blocks_handoff bad-account none GIST_MOCK_ACCOUNT=other-user
  assert_create_failure_blocks_handoff public-metadata fixtureGistId GIST_MOCK_PUBLIC=true
  assert_create_failure_blocks_handoff wrong-description fixtureGistId GIST_MOCK_DESCRIPTION=wrong
  assert_create_failure_blocks_handoff wrong-filename fixtureGistId GIST_MOCK_FILENAME=wrong.md
  assert_create_failure_blocks_handoff multiple-filenames fixtureGistId GIST_MOCK_FILE_COUNT=2
  assert_create_failure_blocks_handoff stderr-url-leakage unknown GIST_CREATE_MODE=stderr-url
  assert_create_failure_blocks_handoff noisy-create-output unknown GIST_CREATE_MODE=noisy
  assert_create_failure_blocks_handoff multiline-create-output unknown GIST_CREATE_MODE=multiline
  assert_create_failure_blocks_handoff malformed-create-output unknown GIST_CREATE_MODE=malformed

  extract_documented_snippet '# agent-task-gist-delete-confirmation' "$fixture_dir/delete.sh"
  sed 's/<reviewed-gist-id>/fixtureGistId/g' "$fixture_dir/delete.sh" >"$fixture_dir/delete-fixture.sh"
  printf '%s\t%s\t%s\t%s\t%s\n' \
    fixtureGistId i9wa4 i9wa4 8 'agent-task:<repo>:<task>' \
    >"$fixture_dir/reviewed-preview.tsv"
  GIST_DELETE_RECORD="$fixture_dir/delete-record" \
    reviewed_preview="$fixture_dir/reviewed-preview.tsv" \
    PATH="$mock_bin:$PATH" \
    sh "$fixture_dir/delete-fixture.sh" <<'EOF'
fixtureGistId
EOF
  test -f "$fixture_dir/delete-record" ||
    fail "documented deletion confirmation did not invoke the exact approved ID"
  GIST_DELETE_RECORD="$fixture_dir/delete-record-bash" \
    reviewed_preview="$fixture_dir/reviewed-preview.tsv" \
    PATH="$mock_bin:$PATH" \
    bash "$fixture_dir/delete-fixture.sh" <<'EOF'
fixtureGistId
EOF
  test -f "$fixture_dir/delete-record-bash" ||
    fail "documented deletion confirmation is not Bash-compatible"

  assert_delete_rejected() {
    name=$1
    preview_owner=$2
    preview_account=$3
    preview_age_days=$4
    preview_id=$5
    typed_id=$6
    account_value=$7
    delete_record="$fixture_dir/$name-delete-record"
    preview_file="$fixture_dir/$name-reviewed-preview.tsv"
    printf '%s\t%s\t%s\t%s\t%s\n' \
      "$preview_id" "$preview_owner" "$preview_account" "$preview_age_days" 'agent-task:<repo>:<task>' \
      >"$preview_file"
    GIST_DELETE_RECORD="$delete_record" \
      GIST_MOCK_ACCOUNT="$account_value" \
      reviewed_preview="$preview_file" \
      PATH="$mock_bin:$PATH" \
      sh "$fixture_dir/delete-fixture.sh" >"$fixture_dir/$name.out" 2>"$fixture_dir/$name.err" <<EOF &&
$typed_id
EOF
      fail "documented deletion authority gate accepted invalid case: $name"
    test ! -e "$delete_record" ||
      fail "documented deletion authority gate deleted invalid case: $name"
  }

  assert_delete_rejected wrong-owner other-owner i9wa4 8 fixtureGistId fixtureGistId i9wa4
  assert_delete_rejected wrong-account i9wa4 other-account 8 fixtureGistId fixtureGistId i9wa4
  assert_delete_rejected missing-current-account i9wa4 i9wa4 8 fixtureGistId fixtureGistId other-user
  assert_delete_rejected too-new i9wa4 i9wa4 6 fixtureGistId fixtureGistId i9wa4
  assert_delete_rejected missing-preview-membership i9wa4 i9wa4 8 otherGistId fixtureGistId i9wa4
  assert_delete_rejected missing-confirmation i9wa4 i9wa4 8 fixtureGistId wrongGistId i9wa4
  assert_fixture_allowed bare-list-preview \
    "gh gist list --secret --filter '^agent-task:<repo>:' --limit 100"

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
    pending_cleanup_record="$fixture_dir/mismatch-pending-cleanup" \
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
  grep -Fq 'gist_id=fixtureGistId' "$fixture_dir/mismatch-pending-cleanup" ||
    fail "documented raw verification mismatch path did not record the exact pending cleanup ID"
  if grep -Fq 'https://gist.github.com/' "$fixture_dir/mismatch-pending-cleanup"; then
    fail "documented raw verification mismatch pending cleanup record leaked URL"
  fi

  GIST_CLEANUP_RECORD="$fixture_dir/scan-cleanup-record" \
    GIST_FIXTURE_SOURCE="$fixture_dir/task.md" \
    GIST_SCAN_MODE=fail \
    pending_cleanup_record="$fixture_dir/scan-pending-cleanup" \
    gist_id=fixtureGistId \
    task_file="$fixture_dir/task.md" \
    PATH="$mock_bin:$PATH" \
    env -u TMPDIR sh "$fixture_dir/raw.sh" >"$fixture_dir/raw-scan.out" 2>&1 &&
    fail "documented raw verification accepted scanned private content"
  grep -Fq 'gist_id=fixtureGistId' "$fixture_dir/scan-pending-cleanup" ||
    fail "documented raw verification scan failure did not record the exact pending cleanup ID"
  if grep -Fq 'https://gist.github.com/' "$fixture_dir/scan-pending-cleanup"; then
    fail "documented raw verification scan pending cleanup record leaked URL"
  fi

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
    pending_cleanup_record="$fixture_dir/full-mismatch-pending-cleanup" \
    task_file="$fixture_dir/task.md" \
    PATH="$mock_bin:$PATH" \
    env -u TMPDIR sh "$fixture_dir/full-mismatch-flow.sh" >"$fixture_dir/full-mismatch-flow.out" 2>&1 &&
    fail "documented full flow reached URL handoff after mismatched content"
  if grep -Fq 'https://gist.github.com/' "$fixture_dir/full-mismatch-flow.out"; then
    fail "documented mismatch flow printed the secret URL"
  fi
  test ! -e "$fixture_dir/url-handoff-record" ||
    fail "documented mismatch flow reached URL handoff"
  grep -Fq 'gist_id=fixtureGistId' "$fixture_dir/full-mismatch-pending-cleanup" ||
    fail "documented mismatch flow did not record exact pending cleanup ID"
  if grep -Fq 'https://gist.github.com/' "$fixture_dir/full-mismatch-pending-cleanup"; then
    fail "documented mismatch flow pending cleanup record leaked URL"
  fi
  test ! -e "${GIST_DELETE_RECORD:-$fixture_dir/unused-delete-record}" ||
    fail "documented pre-handoff flow deleted outside reviewed confirmation"
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
