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
  local file=$1
  local command=
  local line=
  local continuation=0
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%"${line##*[![:space:]]}"}
    if [ "$continuation" -eq 1 ]; then
      command="$command$line"
    else
      command=$line
    fi
    case "$line" in
    *\\)
      command=${command%\\}
      continuation=1
      continue
      ;;
    esac
    if command_has_public_gist_flag "$command"; then
      printf '%s\n' "$command"
      return 0
    fi
    command=
    continuation=0
  done <"$file"
  if [ -n "$command" ] && command_has_public_gist_flag "$command"; then
    printf '%s\n' "$command"
    return 0
  fi
  return 1
}

tokenize_shell_words() {
  local command=$1
  TOKENS=()
  TOKEN_QUOTED=()
  TOKEN_ASSIGNMENT_PREFIX=()
  local token=
  local quoted=0
  local assignment_prefix=0
  local assignment_equal_seen=0
  local assignment_name_valid=1
  local assignment_name_len=0
  local state=normal
  local i=0
  local char=
  local next=
  flush_token() {
    TOKENS+=("$token")
    TOKEN_QUOTED+=("$quoted")
    TOKEN_ASSIGNMENT_PREFIX+=("$assignment_prefix")
    token=
    quoted=0
    assignment_prefix=0
    assignment_equal_seen=0
    assignment_name_valid=1
    assignment_name_len=0
  }
  append_unquoted_char() {
    local appended=$1
    if [ "$assignment_equal_seen" -eq 0 ]; then
      case "$appended" in
      =)
        if [ "$assignment_name_valid" -eq 1 ] && [ "$assignment_name_len" -gt 0 ]; then
          assignment_prefix=1
        fi
        assignment_equal_seen=1
        ;;
      [A-Za-z_])
        assignment_name_len=$((assignment_name_len + 1))
        ;;
      [0-9])
        if [ "$assignment_name_len" -eq 0 ]; then
          assignment_name_valid=0
        fi
        assignment_name_len=$((assignment_name_len + 1))
        ;;
      *)
        assignment_name_valid=0
        assignment_name_len=$((assignment_name_len + 1))
        ;;
      esac
    fi
    token="$token$appended"
  }
  append_quoted_char() {
    local appended=$1
    # Only an unquoted NAME= prefix is shell assignment syntax; quoted NAME=
    # remains the command argv word.
    if [ "$assignment_equal_seen" -eq 0 ]; then
      assignment_name_valid=0
    fi
    token="$token$appended"
  }
  while [ "$i" -lt "${#command}" ]; do
    char=${command:i:1}
    case "$state" in
    normal)
      case "$char" in
      [[:space:]])
        if [ -n "$token" ] || [ "$quoted" -eq 1 ]; then
          flush_token
        fi
        ;;
      "'")
        state=single
        quoted=1
        if [ "$assignment_equal_seen" -eq 0 ]; then
          assignment_name_valid=0
        fi
        ;;
      '"')
        state=double
        quoted=1
        if [ "$assignment_equal_seen" -eq 0 ]; then
          assignment_name_valid=0
        fi
        ;;
      \\)
        i=$((i + 1))
        if [ "$i" -lt "${#command}" ]; then
          append_quoted_char "${command:i:1}"
        fi
        ;;
      ';')
        if [ -n "$token" ] || [ "$quoted" -eq 1 ]; then
          flush_token
        fi
        TOKENS+=(';')
        TOKEN_QUOTED+=(0)
        TOKEN_ASSIGNMENT_PREFIX+=(0)
        ;;
      '&' | '|' | '(' | ')')
        if [ -n "$token" ] || [ "$quoted" -eq 1 ]; then
          flush_token
        fi
        next=${command:$((i + 1)):1}
        if [ "$char" != '(' ] && [ "$char" != ')' ] && [ "$next" = "$char" ]; then
          TOKENS+=("$char$next")
          TOKEN_QUOTED+=(0)
          TOKEN_ASSIGNMENT_PREFIX+=(0)
          i=$((i + 1))
        else
          TOKENS+=("$char")
          TOKEN_QUOTED+=(0)
          TOKEN_ASSIGNMENT_PREFIX+=(0)
        fi
        ;;
      *)
        append_unquoted_char "$char"
        ;;
      esac
      ;;
    single)
      if [ "$char" = "'" ]; then
        state=normal
      else
        append_quoted_char "$char"
      fi
      ;;
    double)
      case "$char" in
      '"')
        state=normal
        ;;
      \\)
        i=$((i + 1))
        if [ "$i" -lt "${#command}" ]; then
          next=${command:i:1}
          case "$next" in
          '"' | \\ | '$' | '`')
            append_quoted_char "$next"
            ;;
          $'\n')
            ;;
          *)
            # shellcheck disable=SC1003 # Literal backslash preserved in double quotes.
            append_quoted_char '\'
            append_quoted_char "$next"
            ;;
          esac
        fi
        ;;
      *)
        append_quoted_char "$char"
        ;;
      esac
      ;;
    esac
    i=$((i + 1))
  done
  if [ -n "$token" ] || [ "$quoted" -eq 1 ]; then
    flush_token
  fi
}

segment_has_public_gist_flag() {
  local start=$1
  local end=$2
  local index=0
  index=$start
  while [ "$index" -lt "$end" ] && [ "${TOKEN_ASSIGNMENT_PREFIX[$index]}" -eq 1 ]; do
    index=$((index + 1))
  done
  while [ "$index" -lt "$end" ]; do
    if [ "${TOKENS[$index]}" = env ]; then
      index=$((index + 1))
      while [ "$index" -lt "$end" ]; do
        case "${TOKENS[$index]}" in
        -u | --unset)
          index=$((index + 2))
          ;;
        -u* | --unset=* | [A-Za-z_]*=*)
          index=$((index + 1))
          ;;
        -*)
          index=$((index + 1))
          ;;
        *)
          break
          ;;
        esac
      done
    elif [ "${TOKENS[$index]}" = command ]; then
      index=$((index + 1))
      while [ "$index" -lt "$end" ] && [[ ${TOKENS[$index]} == -* ]]; do
        index=$((index + 1))
      done
    else
      break
    fi
  done
  [ "${TOKENS[$index]:-}" = gh ] || return 1
  [ "${TOKENS[$((index + 1))]:-}" = gist ] || return 1
  case "${TOKENS[$((index + 2))]:-}" in
  create | edit | list | delete) ;;
  *) return 1 ;;
  esac
  local flag_index=$((index + 3))
  while [ "$flag_index" -lt "$end" ]; do
    case "${TOKENS[$flag_index]}" in
    --) return 1 ;;
    --desc | --description | -d | --filename | --file | -f)
      flag_index=$((flag_index + 2))
      continue
      ;;
    --desc=* | --description=* | --filename=* | --file=*)
      flag_index=$((flag_index + 1))
      continue
      ;;
    --public | --public=* | -p)
      return 0
      ;;
    esac
    flag_index=$((flag_index + 1))
  done
  return 1
}

command_has_public_gist_flag() {
  local command=$1
  tokenize_shell_words "$command"
  local start=0
  local index=0
  while [ "$index" -le "${#TOKENS[@]}" ]; do
    if [ "$index" -eq "${#TOKENS[@]}" ]; then
      segment_has_public_gist_flag "$start" "$index" && return 0
    else
      case "${TOKENS[$index]}" in
      ';' | '&' | '&&' | '||' | '|' | '(' | ')')
        segment_has_public_gist_flag "$start" "$index" && return 0
        start=$((index + 1))
        ;;
      esac
    fi
    index=$((index + 1))
  done
  return 1
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

assert_command_rejected() {
  name=$1
  command=$2
  command_has_public_gist_flag "$command" ||
    fail "public-mode command bypassed argv parser: $name"
}

assert_command_allowed() {
  name=$1
  command=$2
  if command_has_public_gist_flag "$command"; then
    fail "allowed command was rejected by argv parser: $name"
  fi
}

assert_token_equals() {
  name=$1
  command=$2
  index=$3
  expected=$4
  tokenize_shell_words "$command"
  test "${TOKENS[$index]:-}" = "$expected" ||
    fail "tokenizer produced unexpected token for $name"
}

run_public_mode_fixtures() {
  continuation=$(printf '%b' '\134')
  assert_token_equals direct-double-quote-preserved-nonspecial-backslash \
    'gh gist create "--pub\lic" task.md' 3 '--pub\lic'
  assert_token_equals direct-double-quote-escaped-backslash \
    'gh gist create "--pub\\lic" task.md' 3 '--pub\lic'
  assert_token_equals direct-double-quote-escaped-quote \
    'gh gist create "--pub\"lic" task.md' 3 '--pub"lic'
  # shellcheck disable=SC2016 # Literal dollar exercises double-quote escaping.
  assert_token_equals direct-double-quote-escaped-dollar \
    'gh gist create "--pub\$lic" task.md' 3 '--pub$lic'
  assert_token_equals direct-double-quote-escaped-backtick \
    'gh gist create "--pub\`lic" task.md' 3 '--pub`lic'
  assert_token_equals direct-double-quote-backslash-newline-removal \
    $'gh gist create "--pub\\\nlic" task.md' 3 '--public'
  assert_command_allowed direct-double-quote-preserved-nonspecial-backslash-create \
    'gh gist create "--pub\lic" task.md'
  assert_command_allowed direct-double-quote-escaped-backslash-create \
    'gh gist create "--pub\\lic" task.md'
  assert_command_rejected direct-double-quote-backslash-newline-public-create \
    $'gh gist create "--pub\\\nlic" task.md'
  assert_command_rejected direct-quote-spliced-gh-create \
    'g"h" gist create --public task.md'
  assert_command_rejected direct-command-quote-spliced-public-create \
    'command g"h" gist create --public task.md'
  assert_command_rejected direct-ampersand-separated-public-create \
    'printf x & gh gist create --public task.md'
  assert_command_rejected direct-assignment-quoted-value-public-create \
    'TOKEN="x" gh gist create --public task.md'
  assert_command_rejected direct-env-quoted-assignment-public-create \
    'env "TOKEN=x" gh gist create --public task.md'
  assert_command_allowed direct-quoted-assignment-like-command \
    '"TOKEN=x" gh gist create --public task.md'
  assert_command_allowed direct-desc-public-value \
    "gh gist create --desc '--public' task.md"
  assert_command_allowed direct-stop-option-public-positional \
    "gh gist create -- '--public'"
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
  assert_fixture_rejected quoted-public-argv-create \
    "gh gist create '--public' task.md"
  assert_fixture_rejected quote-spliced-public-create \
    'gh gist create --pub"lic" task.md'
  assert_fixture_rejected split-public-continuation-create \
    "gh gist create --pub$continuation" \
    'lic task.md'
  assert_fixture_rejected split-public-double-quoted-continuation-create \
    "gh gist create \"--pub$continuation" \
    'lic" task.md'
  assert_fixture_rejected split-quote-spliced-gh-continuation-create \
    "g$continuation" \
    '"h" gist create --public task.md'
  assert_fixture_rejected split-quote-spliced-gist-continuation-create \
    "gh g$continuation" \
    '"ist" create --public task.md'
  assert_fixture_rejected split-assignment-prefix-continuation-create \
    "TOKEN=$continuation" \
    '"x" gh gist create --public task.md'
  assert_fixture_rejected split-env-assignment-continuation-create \
    "env \"TOKEN=$continuation" \
    'x" gh gist create --public task.md'
  assert_fixture_rejected separated-public-create \
    'printf x; gh gist create --public task.md'
  assert_fixture_rejected assignment-prefixed-public-create \
    'TOKEN=x gh gist create --public task.md'
  assert_fixture_rejected quote-spliced-gh-create \
    'g"h" gist create --public task.md'
  assert_fixture_rejected quote-spliced-gist-create \
    'gh g"ist" create --public task.md'
  assert_fixture_rejected quote-spliced-create-create \
    'gh gist c"reate" --public task.md'
  assert_fixture_rejected quoted-assignment-prefixed-public-create \
    'TOKEN="x" gh gist create --public task.md'
  assert_fixture_rejected env-quoted-assignment-public-create \
    'env "TOKEN=x" gh gist create --public task.md'
  assert_fixture_rejected ampersand-separated-public-create \
    'printf x & gh gist create --public task.md'
  assert_fixture_rejected command-quote-spliced-public-create \
    'command g"h" gist create --public task.md'
  assert_fixture_rejected grouped-public-create \
    '( gh gist create --public task.md )'
  assert_fixture_allowed allowed-create \
    "gh gist create --desc 'agent-task:<repo>:<task>' task.md"
  assert_fixture_allowed allowed-multiline-create \
    "gh gist create $continuation" \
    "  --desc 'agent-task:<repo>:<task>' $continuation" \
    '  task.md'
  assert_fixture_allowed allowed-list 'gh gist list --secret --limit 100'
  assert_fixture_allowed allowed-publicity-token \
    'gh gist create --publicity task.md'
  assert_fixture_allowed allowed-double-quoted-preserved-backslash-public-token \
    'gh gist create "--pub\lic" task.md'
  assert_fixture_allowed allowed-double-quoted-escaped-backslash-public-token \
    'gh gist create "--pub\\lic" task.md'
  assert_fixture_allowed allowed-split-publicity-continuation-token \
    "gh gist create --pub$continuation" \
    'licity task.md'
  assert_fixture_allowed allowed-preview-short-token \
    'gh gist create -preview task.md'
  assert_fixture_allowed allowed-quoted-text \
    'printf "%s\n" "gh gist create --public task.md"'
  assert_fixture_allowed allowed-quoted-description-public-text \
    'gh gist create --desc "document the --public prohibition" task.md'
  assert_fixture_allowed allowed-single-quoted-description-public-text \
    "gh gist create --desc 'document the --public prohibition' task.md"
  assert_fixture_allowed allowed-quoted-filename-public-text \
    'gh gist create "--public-task.md"'
  assert_fixture_allowed allowed-quoted-assignment-like-command \
    '"TOKEN=x" gh gist create --public task.md'
  assert_fixture_allowed allowed-split-quoted-assignment-like-command \
    "\"TOKEN=x\"$continuation" \
    ' gh gist create --public task.md'
  assert_fixture_allowed allowed-desc-public-value \
    "gh gist create --desc '--public' task.md"
  assert_fixture_allowed allowed-stop-option-public-positional \
    "gh gist create -- '--public'"
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
	if [ -n "${GIST_CREATE_RECORD:-}" ]; then
		printf '%s\n' create >> "$GIST_CREATE_RECORD"
	fi
	if [ -n "${GIST_ORDER_RECORD:-}" ]; then
		printf '%s\n' create >> "$GIST_ORDER_RECORD"
	fi
	case "${GIST_CREATE_MODE:-ok}" in
	ok)
		printf '%s\n' 'https://gist.github.com/fixtureGistId'
		;;
	nonzero-side-effect)
		printf '%s\n' 'https://gist.github.com/fixtureGistId'
		exit 64
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
	path-extra)
		printf '%s\n' 'https://gist.github.com/fixtureGistId/extra'
		;;
	query-extra)
		printf '%s\n' 'https://gist.github.com/fixtureGistId?extra'
		;;
	*)
		exit 64
		;;
	esac
	exit 0
fi
if [ "$1" = gist ] && [ "$2" = edit ] && [ "$3" = fixtureGistId ]; then
	if [ "${GIST_EDIT_MODE:-ok}" = fail ]; then
		exit 64
	fi
	exit 0
fi
if [ "$1" = gist ] && [ "$2" = delete ]; then
	printf '%s\n' "$3" >> "$GIST_DELETE_RECORD"
	exit 0
fi
if [ "$1" = gist ] && [ "$2" = view ]; then
	if [ "${GIST_VIEW_MODE:-ok}" = fail ]; then
		exit 64
	fi
	cat "$GIST_FIXTURE_SOURCE"
	exit 0
fi
if [ "$1" = gist ] && [ "$2" = list ] && [ "$3" = --secret ]; then
	list_call_number=1
	if [ -n "${GIST_LIST_RECORD:-}" ]; then
		if [ -f "$GIST_LIST_RECORD" ]; then
			list_call_number=$(($(wc -l < "$GIST_LIST_RECORD") + 1))
		fi
		printf '%s\n' list >> "$GIST_LIST_RECORD"
	fi
	for arg in "$@"; do
		if [ "$arg" = --json ]; then
			jq_arg=
			while [ "$#" -gt 0 ]; do
				if [ "$1" = --jq ]; then
					jq_arg=$2
					break
				fi
				shift
			done
			case "$jq_arg" in
			*fromdateiso8601*) ;;
			*) exit 64 ;;
			esac
			case "$jq_arg" in
			*'"i9wa4", 8'*) exit 64 ;;
			esac
			case "${GIST_LIST_MODE:-ok}" in
			invalid-timestamp)
				exit 64
				;;
			future)
				age=-1
				;;
			*)
				age=${GIST_LIST_AGE_DAYS:-8}
				;;
			esac
			gist_id=fixtureGistId
			case "${GIST_LIST_MODE:-ok}:$list_call_number" in
			divergent:2)
				gist_id=divergentGistId
				;;
			esac
			printf '%s\t%s\t%s\t%s\t%s\n' \
				"$gist_id" i9wa4 i9wa4 "$age" 'agent-task:<repo>:<task>'
			exit 0
		fi
	done
	exit 0
fi
if [ "$1" = api ] && [ "$2" = gists/fixtureGistId ] && [ "$3" = --jq ]; then
	if [ "${GIST_API_MODE:-ok}" = fail ]; then
		exit 64
	fi
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

  cat >"$mock_bin/date" <<'EOF'
#!/bin/sh
if [ "$1" = +%s ]; then
	printf '%s\n' "${GIST_NOW_EPOCH:-1000}"
	exit 0
fi
exec /bin/date "$@"
EOF
  chmod 700 "$mock_bin/date"

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
if [ -n "${GIST_SCAN_RECORD:-}" ]; then
	printf '%s\n' "$*" >> "$GIST_SCAN_RECORD"
fi
if [ -n "${GIST_ORDER_RECORD:-}" ]; then
	printf '%s\n' scan >> "$GIST_ORDER_RECORD"
fi
if [ "${GIST_SCAN_MODE:-ok}" = fail ] || [ "${GIST_SCAN_MODE:-ok}" = fail-local ]; then
	printf '%s\n' '1:tmux-a2a'
	exit 0
fi
if [ "${GIST_SCAN_MODE:-ok}" = error-local ]; then
	printf '%s\n' 'scanner error' >&2
	exit 2
fi
for arg do
	if [ "${GIST_SCAN_MODE:-ok}" = error ]; then
		case "$arg" in
		*/agent-task-gist.*)
			printf '%s\n' 'scanner error' >&2
			exit 2
			;;
		esac
	fi
	if [ -f "$arg" ] && grep -Fq 'tmux-a2a' "$arg"; then
		printf '%s\n' '1:tmux-a2a'
		exit 0
	fi
done
exit 1
EOF
  chmod 700 "$mock_bin/rg"

  cat >"$mock_bin/shasum" <<'EOF'
#!/bin/sh
if [ "$1" != -a ] || [ "$2" != 256 ]; then
  exit 64
fi
case "${GIST_HASH_MODE:-ok}:$3" in
fail-local:*task.md)
	exit 64
	;;
fail-raw:*/agent-task-gist.*)
	exit 64
	;;
esac
sum=$(cksum < "$3" | awk '{print $1}')
printf '%064d  %s\n' "$sum" "$3"
EOF
  chmod 700 "$mock_bin/shasum"

  printf 'fixture memo\n' >"$fixture_dir/task.md"
  printf 'tmux-a2a marker\n' >"$fixture_dir/private-task.md"
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
    GIST_CREATE_RECORD="$fixture_dir/create-record" \
    GIST_SCAN_RECORD="$fixture_dir/local-scan-record" \
    GIST_ORDER_RECORD="$fixture_dir/local-order-record" \
    PATH="$mock_bin:$PATH" \
    task_file="$fixture_dir/task.md" \
    sh "$fixture_dir/create-read-back.sh" >"$fixture_dir/create-read-back.out"
  test "$(wc -l <"$fixture_dir/create-record")" -eq 1 ||
    fail "documented clean local scan did not reach create exactly once"
  test -s "$fixture_dir/local-scan-record" ||
    fail "documented clean flow did not scan local task before create"
  test "$(printf 'scan\ncreate\n')" = "$(cat "$fixture_dir/local-order-record")" ||
    fail "documented clean flow did not scan before create"
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
      if [ "$expected_pending_id" = unknown ]; then
        if grep -Fq 'gist_id=' "$pending_record"; then
          fail "documented unknown pending cleanup record included a Gist ID: $name"
        fi
      else
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
  assert_create_failure_blocks_handoff create-nonzero-side-effect unknown GIST_CREATE_MODE=nonzero-side-effect
  assert_create_failure_blocks_handoff stderr-url-leakage unknown GIST_CREATE_MODE=stderr-url
  assert_create_failure_blocks_handoff noisy-create-output unknown GIST_CREATE_MODE=noisy
  assert_create_failure_blocks_handoff multiline-create-output unknown GIST_CREATE_MODE=multiline
  assert_create_failure_blocks_handoff malformed-create-output unknown GIST_CREATE_MODE=malformed
  assert_create_failure_blocks_handoff malformed-create-path-extra unknown GIST_CREATE_MODE=path-extra
  assert_create_failure_blocks_handoff malformed-create-query-extra unknown GIST_CREATE_MODE=query-extra
  assert_create_failure_blocks_handoff metadata-edit-failed fixtureGistId GIST_EDIT_MODE=fail
  assert_create_failure_blocks_handoff metadata-api-failed fixtureGistId GIST_API_MODE=fail

  assert_local_scan_blocks_create() {
    name=$1
    shift
    out_file="$fixture_dir/$name.out"
    err_file="$fixture_dir/$name.err"
    create_record="$fixture_dir/$name-create-record"
    scan_record="$fixture_dir/$name-scan-record"
    order_record="$fixture_dir/$name-order-record"
    pending_record="$fixture_dir/$name-pending-cleanup"
    delete_record="$fixture_dir/$name-delete-record"
    url_record="$fixture_dir/$name-url-record"
    if GIST_CREATE_RECORD="$create_record" \
      GIST_SCAN_RECORD="$scan_record" \
      GIST_ORDER_RECORD="$order_record" \
      GIST_URL_HANDOFF_RECORD="$url_record" \
      GIST_DELETE_RECORD="$delete_record" \
      pending_cleanup_record="$pending_record" \
      PATH="$mock_bin:$PATH" \
      env "$@" sh "$fixture_dir/create-url-flow.sh" >"$out_file" 2>"$err_file"; then
      fail "documented local scan failure reached URL handoff: $name"
    fi
    test -s "$scan_record" ||
      fail "documented local scan failure did not scan before create: $name"
    test "$(cat "$order_record")" = scan ||
      fail "documented local scan failure order was not scan-only: $name"
    test ! -e "$create_record" ||
      fail "documented local scan failure still created a Gist: $name"
    test ! -e "$pending_record" ||
      fail "documented local scan failure invented pending remote cleanup: $name"
    test ! -e "$url_record" ||
      fail "documented local scan failure created URL handoff record: $name"
    test ! -e "$delete_record" ||
      fail "documented local scan failure deleted before remote creation: $name"
    if grep -Fq 'https://gist.github.com/' "$out_file" "$err_file"; then
      fail "documented local scan failure leaked URL: $name"
    fi
  }

  assert_local_scan_blocks_create local-scan-prohibited-marker task_file="$fixture_dir/private-task.md"
  assert_local_scan_blocks_create local-scan-scanner-error task_file="$fixture_dir/task.md" GIST_SCAN_MODE=error-local

  for signal_name in HUP INT TERM; do
    signal_script="$fixture_dir/create-signal-$signal_name.sh"
    awk -v signal_name="$signal_name" '
      { print }
      $0 == "post_create_lifecycle=1" {
        printf "kill -s %s $$\n", signal_name
      }
    ' "$fixture_dir/create-url-flow.sh" >"$signal_script"
    pending_record="$fixture_dir/create-signal-$signal_name-pending-cleanup"
    delete_record="$fixture_dir/create-signal-$signal_name-delete-record"
    url_record="$fixture_dir/create-signal-$signal_name-url-record"
    GIST_URL_HANDOFF_RECORD="$url_record" \
      GIST_DELETE_RECORD="$delete_record" \
      pending_cleanup_record="$pending_record" \
      PATH="$mock_bin:$PATH" \
      task_file="$fixture_dir/task.md" \
      sh "$signal_script" >"$fixture_dir/create-signal-$signal_name.out" 2>"$fixture_dir/create-signal-$signal_name.err" &&
      fail "documented create/read-back signal reached URL handoff: $signal_name"
    test -s "$pending_record" ||
      fail "documented create/read-back signal left no pending cleanup record: $signal_name"
    if grep -Fq 'gist_id=' "$pending_record"; then
      fail "documented create/read-back signal recorded an unvalidated Gist ID: $signal_name"
    fi
    if grep -Fq 'https://gist.github.com/' "$pending_record" "$fixture_dir/create-signal-$signal_name.out" "$fixture_dir/create-signal-$signal_name.err"; then
      fail "documented create/read-back signal leaked URL: $signal_name"
    fi
    test ! -e "$url_record" ||
      fail "documented create/read-back signal created URL handoff record: $signal_name"
    test ! -e "$delete_record" ||
      fail "documented create/read-back signal deleted before reviewed confirmation: $signal_name"
  done

  extract_documented_snippet '# agent-task-gist-reviewed-preview' "$fixture_dir/preview.sh"
  GIST_LIST_RECORD="$fixture_dir/preview-list-record" \
    GIST_DELETE_RECORD="$fixture_dir/unused-preview-delete-record" \
    PATH="$mock_bin:$PATH" \
    reviewed_preview="$fixture_dir/reviewed-preview.tsv" \
    sh "$fixture_dir/preview.sh" >"$fixture_dir/preview.out"
  test "$(wc -l <"$fixture_dir/preview-list-record")" -eq 1 ||
    fail "documented reviewed-preview producer listed candidates more than once"
  test -s "$fixture_dir/reviewed-preview.tsv" ||
    fail "documented reviewed-preview producer did not write a preview record"
  grep -Fq '# schema=agent-task-gist-reviewed-preview-v1' "$fixture_dir/reviewed-preview.tsv" ||
    fail "documented reviewed-preview producer did not write schema metadata"
  grep -Fq "$(printf 'fixtureGistId\ti9wa4\ti9wa4\t8\tagent-task:<repo>:<task>')" "$fixture_dir/reviewed-preview.tsv" ||
    fail "documented reviewed-preview producer did not persist the derived age row"
  test ! -e "$fixture_dir/unused-preview-delete-record" ||
    fail "documented reviewed-preview producer deleted a Gist"
  awk '/^#/ { next } NF { print }' "$fixture_dir/reviewed-preview.tsv" >"$fixture_dir/reviewed-preview-data.tsv"
  cmp -s "$fixture_dir/preview.out" "$fixture_dir/reviewed-preview-data.tsv" ||
    fail "documented reviewed-preview display was not derived from the proof-bound data"

  GIST_LIST_MODE=divergent \
    GIST_LIST_RECORD="$fixture_dir/divergent-preview-list-record" \
    GIST_DELETE_RECORD="$fixture_dir/divergent-preview-unused-delete-record" \
    PATH="$mock_bin:$PATH" \
    reviewed_preview="$fixture_dir/divergent-reviewed-preview.tsv" \
    sh "$fixture_dir/preview.sh" >"$fixture_dir/divergent-preview.out"
  test "$(wc -l <"$fixture_dir/divergent-preview-list-record")" -eq 1 ||
    fail "documented reviewed-preview producer permitted divergent consecutive lists"
  awk '/^#/ { next } NF { print }' "$fixture_dir/divergent-reviewed-preview.tsv" >"$fixture_dir/divergent-reviewed-preview-data.tsv"
  cmp -s "$fixture_dir/divergent-preview.out" "$fixture_dir/divergent-reviewed-preview-data.tsv" ||
    fail "documented divergent preview display was not proof-bound"
  grep -Fq "$(printf 'fixtureGistId\ti9wa4\ti9wa4\t8\tagent-task:<repo>:<task>')" \
    "$fixture_dir/divergent-reviewed-preview.tsv" ||
    fail "documented divergent preview did not preserve the reviewed candidate row"
  if grep -Fq divergentGistId "$fixture_dir/divergent-preview.out" "$fixture_dir/divergent-reviewed-preview.tsv"; then
    fail "documented divergent preview used a second candidate list"
  fi
  test ! -e "$fixture_dir/divergent-preview-unused-delete-record" ||
    fail "documented divergent reviewed-preview producer deleted a Gist"

  GIST_LIST_MODE=invalid-timestamp \
    GIST_DELETE_RECORD="$fixture_dir/invalid-preview-delete-record" \
    PATH="$mock_bin:$PATH" \
    reviewed_preview="$fixture_dir/invalid-reviewed-preview.tsv" \
    sh "$fixture_dir/preview.sh" >"$fixture_dir/invalid-preview.out" 2>"$fixture_dir/invalid-preview.err" &&
    fail "documented reviewed-preview producer accepted an invalid updatedAt timestamp"
  test ! -e "$fixture_dir/invalid-preview-delete-record" ||
    fail "documented reviewed-preview producer deleted after invalid timestamp"

  GIST_LIST_MODE=future \
    GIST_DELETE_RECORD="$fixture_dir/future-preview-delete-record" \
    PATH="$mock_bin:$PATH" \
    reviewed_preview="$fixture_dir/future-reviewed-preview.tsv" \
    sh "$fixture_dir/preview.sh" >"$fixture_dir/future-preview.out" 2>"$fixture_dir/future-preview.err" &&
    fail "documented reviewed-preview producer accepted a future updatedAt timestamp"
  test ! -e "$fixture_dir/future-preview-delete-record" ||
    fail "documented reviewed-preview producer deleted after future timestamp"

  write_reviewed_preview() {
    destination=$1
    generated_epoch=$2
    preview_id=$3
    preview_owner=$4
    preview_account=$5
    preview_age_days=$6
    preview_description=$7
    metadata_schema=${8:-agent-task-gist-reviewed-preview-v1}
    metadata_account=${9:-i9wa4}
    preview_data="$destination.data"
    preview_proof="$destination.proof"
    printf '%s\t%s\t%s\t%s\t%s\n' \
      "$preview_id" "$preview_owner" "$preview_account" "$preview_age_days" "$preview_description" \
      >"$preview_data"
    {
      printf '# schema=%s\n' "$metadata_schema"
      printf '# account=%s\n' "$metadata_account"
      printf '# generated_epoch=%s\n' "$generated_epoch"
      cat "$preview_data"
    } >"$preview_proof"
    preview_hash=$(PATH="$mock_bin:$PATH" shasum -a 256 "$preview_proof" | awk '{print $1}')
    {
      cat "$preview_proof"
      printf '# proof_sha256=%s\n' "$preview_hash"
    } >"$destination"
  }

  extract_documented_snippet '# agent-task-gist-delete-confirmation' "$fixture_dir/delete.sh"
  sed 's/<reviewed-gist-id>/fixtureGistId/g' "$fixture_dir/delete.sh" >"$fixture_dir/delete-fixture.sh"
  GIST_DELETE_RECORD="$fixture_dir/delete-record" \
    reviewed_preview="$fixture_dir/reviewed-preview.tsv" \
    now_epoch=1000 \
    PATH="$mock_bin:$PATH" \
    sh "$fixture_dir/delete-fixture.sh" <<'EOF'
fixtureGistId
EOF
  test -f "$fixture_dir/delete-record" ||
    fail "documented deletion confirmation did not invoke the exact approved ID"
  GIST_DELETE_RECORD="$fixture_dir/delete-record-bash" \
    reviewed_preview="$fixture_dir/reviewed-preview.tsv" \
    now_epoch=1000 \
    PATH="$mock_bin:$PATH" \
    bash "$fixture_dir/delete-fixture.sh" <<'EOF'
fixtureGistId
EOF
  test -f "$fixture_dir/delete-record-bash" ||
    fail "documented deletion confirmation is not Bash-compatible"
  GIST_DELETE_RECORD="$fixture_dir/divergent-delete-record" \
    reviewed_preview="$fixture_dir/divergent-reviewed-preview.tsv" \
    now_epoch=1000 \
    PATH="$mock_bin:$PATH" \
    sh "$fixture_dir/delete-fixture.sh" <<'EOF'
fixtureGistId
EOF
  test "$(cat "$fixture_dir/divergent-delete-record")" = fixtureGistId ||
    fail "documented deletion was not bound to the divergent reviewed dataset"

  GIST_LIST_AGE_DAYS=6 \
    PATH="$mock_bin:$PATH" \
    reviewed_preview="$fixture_dir/too-new-produced-preview.tsv" \
    sh "$fixture_dir/preview.sh" >"$fixture_dir/too-new-produced-preview.out"
  GIST_DELETE_RECORD="$fixture_dir/too-new-produced-delete-record" \
    reviewed_preview="$fixture_dir/too-new-produced-preview.tsv" \
    now_epoch=1000 \
    PATH="$mock_bin:$PATH" \
    sh "$fixture_dir/delete-fixture.sh" >"$fixture_dir/too-new-produced.out" 2>"$fixture_dir/too-new-produced.err" <<'EOF' &&
fixtureGistId
EOF
    fail "documented deletion accepted producer-derived too-new age"
  test ! -e "$fixture_dir/too-new-produced-delete-record" ||
    fail "documented deletion deleted producer-derived too-new preview"

  assert_delete_rejected() {
    name=$1
    preview_owner=$2
    preview_account=$3
    preview_age_days=$4
    preview_id=$5
    typed_id=$6
    account_value=$7
    preview_description=${8:-agent-task:<repo>:<task>}
    generated_epoch=${9:-1000}
    current_epoch=${10:-1000}
    delete_record="$fixture_dir/$name-delete-record"
    preview_file="$fixture_dir/$name-reviewed-preview.tsv"
    write_reviewed_preview "$preview_file" "$generated_epoch" \
      "$preview_id" "$preview_owner" "$preview_account" "$preview_age_days" "$preview_description"
    GIST_DELETE_RECORD="$delete_record" \
      GIST_MOCK_ACCOUNT="$account_value" \
      reviewed_preview="$preview_file" \
      now_epoch="$current_epoch" \
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
  assert_delete_rejected wrong-description i9wa4 i9wa4 8 fixtureGistId fixtureGistId i9wa4 wrong-description
  assert_delete_rejected stale-preview i9wa4 i9wa4 8 fixtureGistId fixtureGistId i9wa4 'agent-task:<repo>:<task>' 0 5000
  assert_delete_rejected future-metadata-recomputed i9wa4 i9wa4 8 fixtureGistId fixtureGistId i9wa4 'agent-task:<repo>:<task>' 2000 1000
  write_reviewed_preview "$fixture_dir/future-unchanged-reviewed-preview.tsv" 1000 \
    fixtureGistId i9wa4 i9wa4 8 'agent-task:<repo>:<task>'
  sed 's/# generated_epoch=1000/# generated_epoch=2000/' \
    "$fixture_dir/future-unchanged-reviewed-preview.tsv" \
    >"$fixture_dir/future-unchanged-reviewed-preview-mutated.tsv"
  GIST_DELETE_RECORD="$fixture_dir/future-unchanged-delete-record" \
    reviewed_preview="$fixture_dir/future-unchanged-reviewed-preview-mutated.tsv" \
    now_epoch=1000 \
    PATH="$mock_bin:$PATH" \
    sh "$fixture_dir/delete-fixture.sh" >"$fixture_dir/future-unchanged.out" 2>"$fixture_dir/future-unchanged.err" <<'EOF' &&
fixtureGistId
EOF
    fail "documented deletion accepted future metadata with unchanged proof"
  test ! -e "$fixture_dir/future-unchanged-delete-record" ||
    fail "documented deletion deleted future metadata with unchanged proof"
  write_reviewed_preview "$fixture_dir/wrong-schema-reviewed-preview.tsv" 1000 \
    fixtureGistId i9wa4 i9wa4 8 'agent-task:<repo>:<task>' wrong-schema i9wa4
  GIST_DELETE_RECORD="$fixture_dir/wrong-schema-delete-record" \
    reviewed_preview="$fixture_dir/wrong-schema-reviewed-preview.tsv" \
    now_epoch=1000 \
    PATH="$mock_bin:$PATH" \
    sh "$fixture_dir/delete-fixture.sh" >"$fixture_dir/wrong-schema.out" 2>"$fixture_dir/wrong-schema.err" <<'EOF' &&
fixtureGistId
EOF
    fail "documented deletion accepted wrong proof-bound schema"
  test ! -e "$fixture_dir/wrong-schema-delete-record" ||
    fail "documented deletion deleted wrong proof-bound schema"
  write_reviewed_preview "$fixture_dir/wrong-metadata-account-reviewed-preview.tsv" 1000 \
    fixtureGistId i9wa4 i9wa4 8 'agent-task:<repo>:<task>' agent-task-gist-reviewed-preview-v1 other-account
  GIST_DELETE_RECORD="$fixture_dir/wrong-metadata-account-delete-record" \
    reviewed_preview="$fixture_dir/wrong-metadata-account-reviewed-preview.tsv" \
    now_epoch=1000 \
    PATH="$mock_bin:$PATH" \
    sh "$fixture_dir/delete-fixture.sh" >"$fixture_dir/wrong-metadata-account.out" 2>"$fixture_dir/wrong-metadata-account.err" <<'EOF' &&
fixtureGistId
EOF
    fail "documented deletion accepted wrong proof-bound account"
  test ! -e "$fixture_dir/wrong-metadata-account-delete-record" ||
    fail "documented deletion deleted wrong proof-bound account"
  printf '%s\t%s\n' fixtureGistId i9wa4 >"$fixture_dir/malformed-reviewed-preview.tsv.data"
  {
    printf '# schema=agent-task-gist-reviewed-preview-v1\n'
    printf '# account=i9wa4\n'
    printf '# generated_epoch=1000\n'
    cat "$fixture_dir/malformed-reviewed-preview.tsv.data"
  } >"$fixture_dir/malformed-reviewed-preview.tsv.proof"
  malformed_hash=$(PATH="$mock_bin:$PATH" shasum -a 256 "$fixture_dir/malformed-reviewed-preview.tsv.proof" | awk '{print $1}')
  {
    cat "$fixture_dir/malformed-reviewed-preview.tsv.proof"
    printf '# proof_sha256=%s\n' "$malformed_hash"
  } >"$fixture_dir/malformed-reviewed-preview.tsv"
  GIST_DELETE_RECORD="$fixture_dir/malformed-delete-record" \
    reviewed_preview="$fixture_dir/malformed-reviewed-preview.tsv" \
    now_epoch=1000 \
    PATH="$mock_bin:$PATH" \
    sh "$fixture_dir/delete-fixture.sh" >"$fixture_dir/malformed.out" 2>"$fixture_dir/malformed.err" <<'EOF' &&
fixtureGistId
EOF
    fail "documented deletion accepted malformed preview"
  test ! -e "$fixture_dir/malformed-delete-record" ||
    fail "documented deletion deleted from malformed preview"
  printf '%s\t%s\t%s\t%s\t%s\n' fixtureGistId i9wa4 i9wa4 8 'agent-task:<repo>:<task>' \
    >"$fixture_dir/fabricated-reviewed-preview.tsv"
  GIST_DELETE_RECORD="$fixture_dir/fabricated-delete-record" \
    reviewed_preview="$fixture_dir/fabricated-reviewed-preview.tsv" \
    now_epoch=1000 \
    PATH="$mock_bin:$PATH" \
    sh "$fixture_dir/delete-fixture.sh" >"$fixture_dir/fabricated.out" 2>"$fixture_dir/fabricated.err" <<'EOF' &&
fixtureGistId
EOF
    fail "documented deletion accepted fabricated preview without provenance metadata"
  test ! -e "$fixture_dir/fabricated-delete-record" ||
    fail "documented deletion deleted from fabricated preview"
  write_reviewed_preview "$fixture_dir/unproven-reviewed-preview.tsv" 1000 \
    fixtureGistId i9wa4 i9wa4 8 'agent-task:<repo>:<task>'
  printf '%s\t%s\t%s\t%s\t%s\n' tamper i9wa4 i9wa4 8 'agent-task:<repo>:<task>' \
    >>"$fixture_dir/unproven-reviewed-preview.tsv"
  GIST_DELETE_RECORD="$fixture_dir/unproven-delete-record" \
    reviewed_preview="$fixture_dir/unproven-reviewed-preview.tsv" \
    now_epoch=1000 \
    PATH="$mock_bin:$PATH" \
    sh "$fixture_dir/delete-fixture.sh" >"$fixture_dir/unproven.out" 2>"$fixture_dir/unproven.err" <<'EOF' &&
fixtureGistId
EOF
    fail "documented deletion accepted digest-mismatched preview"
  test ! -e "$fixture_dir/unproven-delete-record" ||
    fail "documented deletion deleted from digest-mismatched preview"
  assert_fixture_allowed bare-list-preview \
    "gh gist list --secret --filter '^agent-task:<repo>:' --limit 100"

  extract_documented_snippet '# agent-task-gist-raw-verification' "$fixture_dir/raw.sh"
  raw_signal_script="$fixture_dir/raw-signal.sh"
  awk '
    { print }
    $0 == "raw_file=\"$raw_dir/task.md\"" {
      print "kill -s TERM $$"
    }
  ' "$fixture_dir/raw.sh" >"$raw_signal_script"
  {
    printf 'set -e\n'
    cat "$fixture_dir/create-read-back.sh"
    cat "$raw_signal_script"
    cat "$fixture_dir/url-handoff.sh"
    # shellcheck disable=SC2016 # The generated script must write this literal expansion.
    printf '%s\n' 'printf "%s\n" "$secret_gist_url" > "$GIST_URL_HANDOFF_RECORD"'
  } >"$fixture_dir/full-raw-signal-flow.sh"
  GIST_CLEANUP_RECORD="$fixture_dir/raw-signal-cleanup-record" \
    GIST_FIXTURE_SOURCE="$fixture_dir/task.md" \
    GIST_URL_HANDOFF_RECORD="$fixture_dir/raw-signal-url-record" \
    GIST_DELETE_RECORD="$fixture_dir/raw-signal-delete-record" \
    pending_cleanup_record="$fixture_dir/raw-signal-pending-cleanup" \
    task_file="$fixture_dir/task.md" \
    PATH="$mock_bin:$PATH" \
    env -u TMPDIR sh "$fixture_dir/full-raw-signal-flow.sh" >"$fixture_dir/full-raw-signal-flow.out" 2>&1 &&
    fail "documented raw-stage signal reached URL handoff"
  test -s "$fixture_dir/raw-signal-cleanup-record" ||
    fail "documented raw-stage signal did not clean raw temp state"
  raw_signal_cleaned_directory=$(cat "$fixture_dir/raw-signal-cleanup-record")
  test ! -e "$raw_signal_cleaned_directory" ||
    fail "documented raw-stage signal left raw temp state behind"
  grep -Fq 'gist_id=fixtureGistId' "$fixture_dir/raw-signal-pending-cleanup" ||
    fail "documented raw-stage signal did not preserve exact pending cleanup ID"
  if grep -Fq 'https://gist.github.com/' "$fixture_dir/raw-signal-pending-cleanup" "$fixture_dir/full-raw-signal-flow.out"; then
    fail "documented raw-stage signal leaked URL"
  fi
  test ! -e "$fixture_dir/raw-signal-url-record" ||
    fail "documented raw-stage signal created URL handoff record"
  test ! -e "$fixture_dir/raw-signal-delete-record" ||
    fail "documented raw-stage signal deleted before reviewed confirmation"

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

  assert_raw_failure_pending() {
    name=$1
    shift
    pending_record="$fixture_dir/$name-pending-cleanup"
    delete_record="$fixture_dir/$name-delete-record"
    GIST_CLEANUP_RECORD="$fixture_dir/$name-cleanup-record" \
      GIST_FIXTURE_SOURCE="$fixture_dir/task.md" \
      GIST_DELETE_RECORD="$delete_record" \
      pending_cleanup_record="$pending_record" \
      gist_id=fixtureGistId \
      task_file="$fixture_dir/task.md" \
      PATH="$mock_bin:$PATH" \
      env "$@" sh "$fixture_dir/raw.sh" >"$fixture_dir/$name.out" 2>"$fixture_dir/$name.err" &&
      fail "documented raw verification accepted failure path: $name"
    test -s "$pending_record" ||
      fail "documented raw verification did not write pending cleanup for: $name"
    grep -Fq 'gist_id=fixtureGistId' "$pending_record" ||
      fail "documented raw verification did not record exact ID for: $name"
    if grep -Fq 'https://gist.github.com/' "$pending_record" "$fixture_dir/$name.out" "$fixture_dir/$name.err"; then
      fail "documented raw verification leaked URL for: $name"
    fi
    test ! -e "$delete_record" ||
      fail "documented raw verification deleted outside reviewed confirmation: $name"
  }

  assert_raw_failure_pending raw-fetch-failure GIST_VIEW_MODE=fail
  assert_raw_failure_pending raw-local-hash-failure GIST_HASH_MODE=fail-local
  assert_raw_failure_pending raw-remote-hash-failure GIST_HASH_MODE=fail-raw
  pending_record="$fixture_dir/raw-temp-failure-pending-cleanup"
  delete_record="$fixture_dir/raw-temp-failure-delete-record"
  GIST_FIXTURE_SOURCE="$fixture_dir/task.md" \
    GIST_DELETE_RECORD="$delete_record" \
    pending_cleanup_record="$pending_record" \
    gist_id=fixtureGistId \
    task_file="$fixture_dir/task.md" \
    PATH="$mock_bin:$PATH" \
    TMPDIR="$fixture_dir/missing-tmpdir" \
    sh "$fixture_dir/raw.sh" >"$fixture_dir/raw-temp-failure.out" 2>"$fixture_dir/raw-temp-failure.err" &&
    fail "documented raw verification accepted temp directory failure"
  test -s "$pending_record" ||
    fail "documented raw temp failure did not write pending cleanup"
  grep -Fq 'gist_id=fixtureGistId' "$pending_record" ||
    fail "documented raw temp failure did not record exact ID"
  test ! -e "$delete_record" ||
    fail "documented raw temp failure deleted outside reviewed confirmation"

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

  {
    printf 'set -e\n'
    cat "$fixture_dir/create-read-back.sh"
    cat "$fixture_dir/raw.sh"
    cat "$fixture_dir/url-handoff.sh"
    # shellcheck disable=SC2016 # The generated script must write this literal expansion.
    printf '%s\n' 'printf "%s\n" "$secret_gist_url" > "$GIST_URL_HANDOFF_RECORD"'
  } >"$fixture_dir/full-scan-error-flow.sh"
  GIST_CLEANUP_RECORD="$fixture_dir/full-scan-error-cleanup-record" \
    GIST_FIXTURE_SOURCE="$fixture_dir/task.md" \
    GIST_SCAN_MODE=error \
    GIST_URL_HANDOFF_RECORD="$fixture_dir/scan-error-url-handoff-record" \
    GIST_DELETE_RECORD="$fixture_dir/scan-error-delete-record" \
    pending_cleanup_record="$fixture_dir/full-scan-error-pending-cleanup" \
    task_file="$fixture_dir/task.md" \
    PATH="$mock_bin:$PATH" \
    env -u TMPDIR sh "$fixture_dir/full-scan-error-flow.sh" >"$fixture_dir/full-scan-error-flow.out" 2>&1 &&
    fail "documented full flow reached URL handoff after scanner error"
  test ! -e "$fixture_dir/scan-error-url-handoff-record" ||
    fail "documented scanner error flow reached URL handoff"
  grep -Fq 'gist_id=fixtureGistId' "$fixture_dir/full-scan-error-pending-cleanup" ||
    fail "documented scanner error flow did not record exact pending cleanup ID"
  if grep -Fq 'https://gist.github.com/' "$fixture_dir/full-scan-error-pending-cleanup" "$fixture_dir/full-scan-error-flow.out"; then
    fail "documented scanner error flow leaked URL"
  fi
  test ! -e "$fixture_dir/scan-error-delete-record" ||
    fail "documented scanner error flow deleted outside reviewed confirmation"
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
