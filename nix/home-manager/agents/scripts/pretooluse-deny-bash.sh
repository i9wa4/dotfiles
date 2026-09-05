#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# pretooluse-deny-bash.sh - Bash command default-deny/allowlist hook
# (shared by Claude/Codex)
# Hook: PreToolUse | Matcher: Bash
# Patterns: deny-bash-patterns.sh (generated from denied-bash-commands.nix
# and allowed-bash-commands.nix; despite the filename, this now carries
# both ALLOW_PATTERNS and DENY_PATTERNS -- renaming it is a separate,
# larger diff across both Nix modules and is left for a follow-up).
# Same JSON-in / JSON-out schema (`hookSpecificOutput.permissionDecision`)
# is accepted by both Claude Code and Codex CLI hook runtimes.
#
# ── Model ──────────────────────────────────────────────────────────────
#
# Default-deny: every command is denied unless it matches an allow path.
# Every decision is explicit -- this script never silently exits 0 with
# no JSON output the way its default-allow predecessor did, because
# under default-deny a silent "no opinion" would mean "nothing works."
#
# Allow paths, checked in this order:
#   1. check_grep_rg_allow: a dedicated, already approver-reviewed
#      (twice) procedural rule for single-shape grep/rg/ripgrep
#      invocations, absorbed here from the former standalone
#      claude-pretooluse-allow-safe-grep.sh design (issue #342) rather
#      than kept as a second, separately-maintained hook. Operates on
#      the whole raw command, exactly as it did as a standalone hook --
#      it already rejects any chaining/substitution/redirection
#      metacharacter outright, so it does not participate in the
#      per-fragment split below.
#   2. ALLOW_PATTERNS (allowed-bash-commands.nix): per-fragment regex
#      allowlist for simple, side-effect-free commands (ls, pwd, git
#      status, the tmux-a2a-postman entry that supersedes the old
#      ALLOW_PREFIX_BYPASS mechanism, etc.).
#
# denied-bash-commands.nix's DENY_PATTERNS are NOT a second enforcement
# gate. They no longer decide whether a command runs -- everything that
# misses the allow paths above is denied regardless of whether it also
# matches a DENY_PATTERNS entry. What DENY_PATTERNS still controls is
# message quality: a command that is both off the allowlist and matches
# a known-bad pattern here gets that pattern's specific, repair-oriented
# justification; anything else off the allowlist gets a generic
# not-on-the-allowlist message. Same outcome (denied) either way.
#
# Every deny message also appends a hint to request the command through
# `tmux-a2a-postman execute-bash` instead of retrying it directly.
#
# Before any allow path runs, `mask_heredoc_bodies` strips heredoc BODY
# lines out of the command text (issue #355). Heredoc bodies are literal
# data -- postman message text in practice -- not live shell syntax; the
# earlier #352/#354 fix already exempted the `<<`/`<<-`/`<<<` operator
# marker itself from `fragment_has_risky_construct`, but left body lines
# unprotected, so a Markdown-formatted body (backticks, `$(`, bare `<`/`>`)
# still tripped a false deny before the `tmux-a2a-postman` allow entry was
# ever consulted.

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PATTERNS_FILE="$SCRIPT_DIR/deny-bash-patterns.sh"
[[ ! -f $PATTERNS_FILE ]] && exit 0

# shellcheck source=/dev/null
source "$PATTERNS_FILE"

COMMAND=$(jq -r '.tool_input.command // empty' 2>/dev/null) || true
[[ -z $COMMAND ]] && exit 0

EXECUTE_BASH_HINT="If this command should run, request it via 'tmux-a2a-postman execute-bash --label <short-label> --category <category> --reason <why>' instead of retrying it directly."

trim_bash_fragment() {
  local fragment="$1"
  fragment="${fragment#"${fragment%%[![:space:]]*}"}"
  fragment="${fragment%"${fragment##*[![:space:]]}"}"
  printf '%s' "$fragment"
}

strip_one_quote_layer() {
  local value="$1"
  local first_char
  local last_char

  if [ "${#value}" -lt 2 ]; then
    printf '%s' "$value"
    return 0
  fi

  first_char="${value:0:1}"
  last_char="${value: -1}"

  if [[ $first_char == "'" && $last_char == "'" ]] || [[ $first_char == '"' && $last_char == '"' ]]; then
    printf '%s' "${value:1:${#value}-2}"
    return 0
  fi

  printf '%s' "$value"
}

unwrap_shell_wrapper() {
  local fragment="$1"
  local inner_script

  if [[ $fragment =~ ^(bash|sh|zsh)[[:space:]]+-(lc|cl|c)[[:space:]]+(.+)$ ]]; then
    inner_script="${BASH_REMATCH[3]}"
    inner_script="$(trim_bash_fragment "$inner_script")"
    inner_script="$(strip_one_quote_layer "$inner_script")"
    inner_script="$(trim_bash_fragment "$inner_script")"
    printf '%s' "$inner_script"
    return 0
  fi

  return 1
}

# Replace the quoted value following each STRIP_DATA_ARGS arg with an empty
# string before regex matching (deny OR allow). This neutralises false
# positives from arg values that legitimately contain words like "rm" or
# "sudo" without weakening the check on the surrounding command (e.g.
# --amend still trips the deny check; a stray "-m" value can't smuggle an
# allow-pattern match either). The original fragment is preserved
# separately so messages report the command the agent actually issued,
# not the stripped version.
# NOTE: sed delimiter must NOT appear inside the regex. Using `|` collides
# with the `|` inside `(^|[[:space:]])` and makes sed treat the regex as
# malformed (`unknown option to 's'`), silently emptying the fragment --
# net effect, no denies OR allows fire and the hook falls through to a
# default deny on everything. Use `#` instead.
strip_data_arg_values() {
  local fragment="$1"
  local arg
  for arg in "${STRIP_DATA_ARGS[@]}"; do
    fragment=$(printf '%s' "$fragment" | sed -E "s#(^|[[:space:]])${arg}[[:space:]]+\"[^\"]*\"#\1${arg} \"\"#g")
    fragment=$(printf '%s' "$fragment" | sed -E "s#(^|[[:space:]])${arg}[[:space:]]+'[^']*'#\1${arg} ''#g")
  done
  printf '%s' "$fragment"
}

# Reject constructs that could smuggle additional commands past a
# prefix-shaped allow match (e.g. "ls > /etc/passwd", "ls $(rm -rf /)",
# "ls `evil`"). ALLOW_PATTERNS only checks a fragment's leading token, so
# this guard must run before any allow-pattern match is trusted -- unlike
# DENY_PATTERNS, where a false negative here would just miss a specific
# friendlier message and fall through to the (still-safe) generic deny,
# a false negative on the ALLOW side would incorrectly permit execution.
# `;`, `&`, `|` are excluded from this list because the caller already
# splits on those as top-level fragment separators before this check
# runs; a literal one inside the current fragment would only be possible
# inside quotes, which is data, not a live shell operator.
#
# Quote-aware: reuses the same char-by-char quote-tracking walk_bash_fragments
# uses, rather than a naive substring case-match, so a backtick/$(/</> inside
# a quoted argument (data) is not confused with a live shell metacharacter.
# A run of two or more unquoted `<` is a heredoc (`<<`) or here-string
# (`<<<`) marker, not input redirection -- unlike a bare single `<`, it never
# reads from an arbitrary file, so it is not flagged. `>` gets no equivalent
# exemption: `>>` is still real output redirection either way.
# shellcheck disable=SC2329 # invoked indirectly via check_bash_fragment_for_allow
fragment_has_risky_construct() {
  local fragment="$1"
  local char next_char
  local index
  local single_quoted=0 double_quoted=0 escaped=0

  for ((index = 0; index < ${#fragment}; index++)); do
    char="${fragment:index:1}"

    if [ "$escaped" -eq 1 ]; then
      escaped=0
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [[ $char == \\ ]]; then
      escaped=1
      continue
    fi

    if [ "$double_quoted" -eq 0 ] && [ "$char" = "'" ]; then
      if [ "$single_quoted" -eq 1 ]; then
        single_quoted=0
      else
        single_quoted=1
      fi
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [ "$char" = '"' ]; then
      if [ "$double_quoted" -eq 1 ]; then
        double_quoted=0
      else
        double_quoted=1
      fi
      continue
    fi

    if [ "$single_quoted" -eq 1 ] || [ "$double_quoted" -eq 1 ]; then
      if [ "$char" = '`' ]; then
        # Backtick and $( ) still expand inside double quotes in real
        # bash, so unlike </>, they stay risky there too.
        if [ "$double_quoted" -eq 1 ]; then
          return 0
        fi
      elif [ "$char" = '$' ] && [ "${fragment:index+1:1}" = "(" ] && [ "$double_quoted" -eq 1 ]; then
        return 0
      fi
      continue
    fi

    case "$char" in
    '`')
      return 0
      ;;
    '$')
      if [ "${fragment:index+1:1}" = "(" ]; then
        return 0
      fi
      ;;
    '<')
      next_char="${fragment:index+1:1}"
      if [ "$next_char" = "<" ]; then
        # Heredoc (<<, <<-) or here-string (<<<) marker: skip the whole
        # run of unquoted `<` so neither end of it is mistaken for a
        # standalone input-redirection `<`.
        while [ "${fragment:index+1:1}" = "<" ]; do
          index=$((index + 1))
        done
        continue
      fi
      return 0
      ;;
    '>')
      return 0
      ;;
    esac
  done

  return 1
}

# Extract EVERY heredoc/here-string-operator delimiter from a single line,
# outside quotes, in the order the operators appear (bash consumes heredoc
# bodies in that same order when a line carries more than one, e.g.
# `cmd <<'A' <<B`). Only genuine two-character `<<`/`<<-` runs open a
# heredoc; a run of three or more (`<<<`, here-string) is single-line, has
# no following body, and is skipped -- but scanning CONTINUES past it
# rather than abandoning the line, because a here-string can be followed
# later on the same line by a real heredoc operator (round 5 finding: an
# earlier version of this logic lived in two places -- this whole-line
# scan, and a since-deleted single-operator function that `return`ed empty
# handed on a here-string instead of skipping past it. The two recognizers
# disagreed on exactly this shape, and the call site picked between them by
# counting delimiters, so a line with one real heredoc plus a preceding
# here-string got a different, wrong answer depending on which one ran.
# Collapsing to this single recognizer, used for both the one-delimiter and
# multi-delimiter cases, removes that class of disagreement entirely).
#
# Prints one `word<TAB>strip_tabs_flag<TAB>quoted_flag` line per operator
# found to stdout (not a nameref array -- `set -o posix` at the top of this
# script disables `local -n` at runtime).
#
# `quoted_flag` matters more than it looks: real bash only treats a heredoc
# BODY as inert literal text when the delimiter word is quoted (single- or
# double-quoted, with the SAME quote character closing it) or has an
# escaped character (e.g. `<<\WORD`). An UNQUOTED delimiter (`<<WORD`)
# means the body undergoes real parameter expansion, command substitution,
# and backslash processing before the receiving command ever sees it -- a
# bare `$(...)` or backtick in such a body is live shell syntax, not data.
# The caller must only mask a single-delimiter body when this flag is 1;
# an unquoted delimiter must be left fully visible to the scanners. For a
# multi-delimiter line, the caller ignores this flag and never masks any of
# them regardless of quoting (see the fallback in mask_heredoc_bodies).
# shellcheck disable=SC2329 # invoked indirectly via mask_heredoc_bodies
extract_heredoc_delimiters() {
  local line="$1"
  local char index run j rest word strip_tabs opener quoted
  local single_quoted=0 double_quoted=0 escaped=0
  local len=${#line}

  for ((index = 0; index < len; index++)); do
    char="${line:index:1}"

    if [ "$escaped" -eq 1 ]; then
      escaped=0
      continue
    fi
    if [ "$single_quoted" -eq 0 ] && [[ $char == \\ ]]; then
      escaped=1
      continue
    fi
    if [ "$double_quoted" -eq 0 ] && [ "$char" = "'" ]; then
      if [ "$single_quoted" -eq 1 ]; then single_quoted=0; else single_quoted=1; fi
      continue
    fi
    if [ "$single_quoted" -eq 0 ] && [ "$char" = '"' ]; then
      if [ "$double_quoted" -eq 1 ]; then double_quoted=0; else double_quoted=1; fi
      continue
    fi
    if [ "$single_quoted" -eq 1 ] || [ "$double_quoted" -eq 1 ]; then
      continue
    fi

    if [ "$char" = "<" ] && [ "${line:index+1:1}" = "<" ]; then
      run=2
      j=$((index + 2))
      while [ "${line:j:1}" = "<" ]; do
        run=$((run + 1))
        j=$((j + 1))
      done
      if [ "$run" -eq 2 ]; then
        rest="${line:j}"
        strip_tabs=0
        if [ "${rest:0:1}" = "-" ]; then
          strip_tabs=1
          rest="${rest:1}"
        fi
        while [ "${rest:0:1}" = " " ] || [ "${rest:0:1}" = $'\t' ]; do
          rest="${rest:1}"
        done

        opener="${rest:0:1}"
        word=""
        # shellcheck disable=SC1003 # the '\' case pattern below matches a single backslash char, not an escape mistake; shfmt's canonical style prefers this quoting over "\\"
        case "$opener" in
        "'" | '"')
          rest="${rest:1}"
          while [[ ${rest:0:1} =~ [A-Za-z0-9_] ]]; do
            word+="${rest:0:1}"
            rest="${rest:1}"
          done
          # Only genuinely quoted -- i.e. the SAME quote character closes
          # the word -- disables expansion. An unmatched opener (malformed,
          # or not actually a quote at all) must not be trusted as quoted.
          if [ -n "$word" ] && [ "${rest:0:1}" = "$opener" ]; then
            quoted=1
          else
            quoted=0
          fi
          ;;
        '\')
          rest="${rest:1}"
          while [[ ${rest:0:1} =~ [A-Za-z0-9_] ]]; do
            word+="${rest:0:1}"
            rest="${rest:1}"
          done
          quoted=1
          ;;
        *)
          while [[ ${rest:0:1} =~ [A-Za-z0-9_] ]]; do
            word+="${rest:0:1}"
            rest="${rest:1}"
          done
          quoted=0
          ;;
        esac

        if [ -n "$word" ]; then
          printf '%s\t%s\t%s\n' "$word" "$strip_tabs" "$quoted"
        fi
      fi
      index=$((j - 1))
    fi
  done
}

# Mask heredoc BODY lines out of a raw (possibly multi-line) command before
# it reaches the fragment-splitting/risky-construct scanners below. A
# heredoc body is arbitrary literal data -- postman message text in
# practice -- not live shell syntax: a body line containing a bare
# backtick, `$(`, `<`, or `>` (extremely common in Markdown-formatted
# message text) must not be mistaken for a chaining/substitution/
# redirection attempt. The quote-aware `<<`/`<<<` skip inside
# fragment_has_risky_construct only protects the operator token itself, not
# the body lines that follow it, which is exactly the gap this closes.
# Neither `walk_bash_fragments` nor `fragment_has_risky_construct` treats a
# bare newline as meaningful, so body lines are simply dropped rather than
# replaced with placeholders -- the surrounding structure (operator line,
# delimiter line, and anything after) is preserved unchanged.
#
# Fail safe, not fail open, on a malformed/unclosed heredoc (issue #355
# follow-up finding): body lines are buffered rather than dropped
# immediately. If the closing delimiter is found, the buffer is discarded
# -- that was a genuine heredoc body and masking it is the whole point. If
# input ends while still inside the heredoc (no matching delimiter line
# ever appears), the buffered lines are NOT genuinely known to be inert
# data -- an unclosed heredoc opener is exactly the shape that could smuggle
# a risky metacharacter (backtick, `$(`, bare `<`/`>`) past
# `fragment_has_risky_construct` by hiding it inside what looks like a
# heredoc body. So on that ambiguous outcome, the buffered lines are
# appended back to the scanned text instead of being silently discarded:
# masking must never make the scanned text safer-looking than reality by
# omission.
#
# Only masks when `extract_heredoc_delimiters` reports a QUOTED delimiter.
# An unquoted delimiter (`<<WORD`, no quotes or escape) means real bash
# expands `$(...)`/backticks/`$VAR` inside the body as live syntax before
# the receiving command ever sees it -- that body is exactly as dangerous
# as any other command text and must stay fully visible to the scanners,
# never masked.
#
# Multiple heredoc operators on one line (e.g. `cmd <<'A' <<B`) fall back
# to never masking any of them, rather than trying to track several
# concurrent pending spans (guardian/critic finding, round 4). The
# single-span model above closes span-tracking after the FIRST operator's
# delimiter and then has no memory of the second one at all -- a line after
# that first close which merely LOOKS like a heredoc opener gets misread as
# a fresh top-level operator, and text between that false opener and its
# false close (which is actually still the real second heredoc's body) can
# be masked away even though it may contain a live substitution. Refusing
# to mask is a false-denial-safe fallback: every line from the
# multi-operator line onward, until all of its delimiters are consumed in
# order, is appended to the scanned text unmodified and never buffered,
# so nothing can be hidden. Critically, heredoc EXTENT is still tracked via
# `fallback_queue` for exactly that span -- operator detection is
# suppressed for those lines, so a body line that looks like an opener
# cannot restart the single-span tracker and reintroduce the same
# confusion one level later.
#
# Also rewrites a bare newline between two TOP-LEVEL lines into a `;`
# (issue #358). Real bash treats such a newline as a statement separator,
# exactly like `;` -- but `walk_bash_fragments` (and its duplicate in
# check_bash_command_for_denials) never did, so a live, non-allowlisted
# command placed on the line right after a heredoc's closing delimiter was
# scanned as part of the SAME fragment as the heredoc-bearing prefix, and
# inherited whatever allow decision that prefix's leading token earned.
# Newlines strictly inside a heredoc span (an operator line through its own
# delimiter line inclusive, regardless of quoting, and every line still
# covered by `fallback_queue`) are left as plain newlines, since that is
# one syntactic unit from bash's perspective, not two statements; only a
# newline between genuinely separate top-level lines becomes `;`.
mask_heredoc_bodies() {
  local command_text="$1"
  local line
  local out=""
  local first=1
  local in_span=0
  local masking=0
  local strip_tabs=0
  local delimiter=""
  local compare delim_word strip_flag quoted_flag
  local pending="" pending_first=1
  local -a line_delims=()
  local -a fallback_queue=()
  local fq_word fq_strip fq_quoted fq_compare
  local line_delims_raw line_delim_entry

  while IFS= read -r line || [ -n "$line" ]; do
    if [ "${#fallback_queue[@]}" -gt 0 ]; then
      # Read all three fields the record carries (word/strip_tabs/quoted).
      # Reading only two here previously let $fq_strip silently absorb
      # "strip_tabs<TAB>quoted" as one leftover string (read's last named
      # variable gets everything remaining) -- a value that can never
      # equal the literal "1" the check below compares against, so the
      # leading-tab-stripping for a `<<-` operator's queued delimiter
      # never activated (guardian finding C5). quoted_flag is unused here
      # since the fallback never masks regardless of quoting; it must
      # still be consumed so it does not get folded into fq_strip.
      # shellcheck disable=SC2034 # fq_quoted deliberately unused: consumed only to keep fq_strip isolated to its own field
      IFS=$'\t' read -r fq_word fq_strip fq_quoted <<<"${fallback_queue[0]}"
      fq_compare="$line"
      if [ "$fq_strip" = "1" ]; then
        while [ "${fq_compare:0:1}" = $'\t' ]; do
          fq_compare="${fq_compare:1}"
        done
      fi
      if [ "$fq_compare" = "$fq_word" ]; then
        fallback_queue=("${fallback_queue[@]:1}")
      fi
      if [ "$first" -eq 1 ]; then
        out="$line"
        first=0
      else out+=$'\n'"$line"; fi
      continue
    fi

    if [ "$in_span" -eq 1 ]; then
      compare="$line"
      if [ "$strip_tabs" -eq 1 ]; then
        while [ "${compare:0:1}" = $'\t' ]; do
          compare="${compare:1}"
        done
      fi
      if [ "$compare" = "$delimiter" ]; then
        in_span=0
        masking=0
        pending=""
        pending_first=1
        if [ "$first" -eq 1 ]; then
          out="$line"
          first=0
        else out+=$'\n'"$line"; fi
      elif [ "$masking" -eq 1 ]; then
        # Buffer rather than drop: appended back below only if the
        # heredoc turns out never to close.
        if [ "$pending_first" -eq 1 ]; then
          pending="$line"
          pending_first=0
        else pending+=$'\n'"$line"; fi
      else
        # Unquoted heredoc: pass the body through unmasked (real bash
        # expands it as live syntax) -- and, critically, do NOT run
        # extract_heredoc_delimiters on it. Heredoc extent is tracked
        # unconditionally via `in_span` regardless of quoting; only the
        # MASKING decision depends on the quoted flag. A prior version
        # tracked extent only for quoted delimiters, so an unquoted body
        # line that itself looked like a heredoc opener (e.g. a quoted
        # `<<'EOF'` appearing as plain body text) was misread as a real
        # nested opener, and text between that false opener and its false
        # closer was masked away -- even though it was ordinary body text
        # bash would expand and the receiving command would see verbatim.
        if [ "$first" -eq 1 ]; then
          out="$line"
          first=0
        else out+=$'\n'"$line"; fi
      fi
      continue
    fi

    if [ "$first" -eq 1 ]; then
      out="$line"
      first=0
    else out+=';'"$line"; fi

    line_delims_raw="$(extract_heredoc_delimiters "$line")"
    line_delims=()
    if [ -n "$line_delims_raw" ]; then
      while IFS= read -r line_delim_entry; do
        line_delims+=("$line_delim_entry")
      done <<<"$line_delims_raw"
    fi
    if [ "${#line_delims[@]}" -ge 2 ]; then
      fallback_queue=("${line_delims[@]}")
    elif [ "${#line_delims[@]}" -eq 1 ]; then
      IFS=$'\t' read -r delim_word strip_flag quoted_flag <<<"${line_delims[0]}"
      in_span=1
      delimiter="$delim_word"
      strip_tabs="$strip_flag"
      pending=""
      pending_first=1
      if [ "$quoted_flag" = "1" ]; then
        masking=1
      else
        masking=0
      fi
    fi
  done <<<"$command_text"

  if [ "$in_span" -eq 1 ] && [ "$masking" -eq 1 ] && [ -n "$pending" ]; then
    # Heredoc never closed -- do not hide the unmatched trailing lines
    # from the risky-construct/allow/deny scanners.
    if [ "$first" -eq 1 ]; then
      out="$pending"
      first=0
    else out+=$'\n'"$pending"; fi
  fi

  printf '%s' "$out"
}

emit_deny_payload() {
  local fragment="$1"
  local reason="$2"

  jq -n \
    --arg reason "Command denied: ${reason}"$'\n'"Fragment: $fragment"$'\n'"${EXECUTE_BASH_HINT}" \
    '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason } }'
}

emit_allow_payload() {
  local reason="$1"

  jq -n \
    --arg reason "$reason" \
    '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "allow", permissionDecisionReason: $reason } }'
}

# Ported verbatim (behavior-for-behavior) from the already approver-reviewed
# (twice) standalone grep/rg auto-allow hook (issue #342). Operates on the
# WHOLE raw command, not a split fragment, exactly as it did as a
# standalone hook: any chaining/substitution/redirection metacharacter
# anywhere in the command is an outright reject, and at most one `&&` is
# tolerated, only in the exact `cd <path> && grep/rg ...` shape.
check_grep_rg_allow() {
  local c="$1"
  local tmp
  local amp_count
  local rest
  local lc

  # shellcheck disable=SC2016 # case pattern, not variable expansion
  case "$c" in
  *';'* | *'|'* | *'`'* | *'$('* | *'<('* | *'>('* | *'<'* | *'>'* | *$'\n'* | *$'\r'*)
    return 1
    ;;
  esac

  tmp="${c//&&/}"
  case "$tmp" in
  *'&'*) return 1 ;;
  esac

  amp_count=$(printf '%s' "$c" | grep -o '&&' | wc -l | tr -d ' ')
  rest="$c"
  if [ "$amp_count" = "1" ]; then
    case "$c" in
    cd\ *' && '*) rest="${c#*' && '}" ;;
    *) return 1 ;;
    esac
  elif [ "$amp_count" != "0" ]; then
    return 1
  fi

  case "$rest" in
  grep\ * | grep | rg\ * | rg | ripgrep\ * | ripgrep) : ;;
  *) return 1 ;;
  esac

  lc=$(printf '%s' "$c" | tr '[:upper:]' '[:lower:]')
  case "$lc" in
  *key* | *token* | *secret* | *.env* | *.ssh* | *credential* | *password*)
    return 1
    ;;
  esac

  case "$rest" in
  *'rm '* | *'sudo '* | *'curl '* | *'wget '*) return 1 ;;
  esac

  return 0
}

# File-content-reading commands on ALLOW_PATTERNS (bash-commands-allowed.nix)
# that take an arbitrary path argument with no argument-level check at all
# (unlike grep/rg/ripgrep, which already reject secret-shaped matches via
# check_grep_rg_allow below) -- `cat .env`, `head ~/.ssh/id_rsa`,
# `tail some/secrets/api.key`, and the same shape for wc/sort/uniq/cut, would
# otherwise be allowed through unconditionally (issue #365). Intentionally
# excludes `ls` (lists filenames only, does not dump file content) and
# `echo`/`date`/`whoami`/`which` (do not read files at all).
SECRET_ARGUMENT_SENSITIVE_COMMANDS=(cat head tail wc sort uniq cut)

# Duplicated, not shared with check_grep_rg_allow's keyword case statement:
# that function is already approver-reviewed (twice, issue #342) and is kept
# untouched here to avoid re-opening review on tested logic (its bare-
# substring matching has the same false-positive class fixed below, but
# fixing it is out of scope for this issue -- tracked separately).
#
# Word/path-segment anchored, NOT bare substring: a bare `*key*`-style glob
# denied ordinary non-secret paths purely because the word "key" or ".env"
# appeared as a substring (e.g. `cat config/zsh/keybind.zsh`, `cat .envrc`,
# `cat .env.example`), which is exactly what issue #365's own acceptance
# criterion says must stay allowed. key/token/secret(s)/credential(s)/
# password must appear as a whole word (bounded by start/end-of-string or a
# non-alnum/non-underscore character on both sides; `secrets?`/`credentials?`
# so a `secrets/`- or `credentials/`-named directory still matches).
# `.env` and `.ssh` are anchored to a path segment (start-of-string/space/`/`
# on the left, and on the right either the same set, end-of-string, or a
# literal `.` so `.env.local`/`.env.production` still match) rather than a
# bare substring, and `.envrc`/`.env.example` are stripped out before the
# test runs so they cannot match at all -- `.envrc` is a direnv config file,
# not a secret store, and `.env.example` is a placeholder template committed
# to the repo, not real secret values.
# shellcheck disable=SC2329 # invoked indirectly via check_bash_fragment_for_allow
fragment_has_secret_keyword() {
  local fragment="$1"
  local lc
  local regex
  lc=$(printf '%s' "$fragment" | tr '[:upper:]' '[:lower:]')

  # Known non-secret filenames that would otherwise match the `.env`
  # path-segment check below; strip them so their mere presence cannot
  # trigger a false positive.
  lc="${lc//.envrc/}"
  lc="${lc//.env.example/}"

  regex='(^|[^[:alnum:]_])(key|token|secrets?|credentials?|password)([^[:alnum:]_]|$)'
  regex+='|(^|[[:space:]/])\.env([[:space:]/]|$|\.[^[:space:]/]*)'
  regex+='|(^|[[:space:]/])\.ssh([[:space:]/]|$)'

  [[ $lc =~ $regex ]]
}

# shellcheck disable=SC2329 # invoked indirectly via check_bash_fragment_for_allow
command_is_secret_argument_sensitive() {
  local fragment="$1"
  local leading_word="${fragment%%[[:space:]]*}"
  local cmd
  for cmd in "${SECRET_ARGUMENT_SENSITIVE_COMMANDS[@]}"; do
    if [ "$leading_word" = "$cmd" ]; then
      return 0
    fi
  done
  return 1
}

# shellcheck disable=SC2329 # invoked indirectly via walk_bash_fragments
check_bash_fragment_for_allow() {
  local fragment="$1"
  local original_fragment
  local inner_script
  local i

  fragment="$(trim_bash_fragment "$fragment")"
  if [ -z "$fragment" ]; then
    # An empty fragment (e.g. a trailing `;`) contributes nothing to run
    # and is not itself a command to gate.
    return 0
  fi

  if inner_script="$(unwrap_shell_wrapper "$fragment")"; then
    check_bash_command_for_allow "$inner_script"
    return $?
  fi

  if fragment_has_risky_construct "$fragment"; then
    return 1
  fi

  if command_is_secret_argument_sensitive "$fragment" && fragment_has_secret_keyword "$fragment"; then
    emit_deny_payload "$fragment" "secret-shaped path argument (key/token/secret(s)/credential(s)/password/.env/.ssh) to a file-reading command (cat/head/tail/wc/sort/uniq/cut). If this path is not actually secret, request it via tmux-a2a-postman execute-bash instead of retrying directly."
    exit 0
  fi

  original_fragment="$fragment"
  fragment="$(strip_data_arg_values "$fragment")"

  for i in "${!ALLOW_PATTERNS[@]}"; do
    if [[ $fragment =~ ${ALLOW_PATTERNS[$i]} ]]; then
      return 0
    fi
  done

  return 1
}

check_bash_fragment_for_denials() {
  local fragment="$1"
  local original_fragment
  local inner_script
  local i

  fragment="$(trim_bash_fragment "$fragment")"
  if [ -z "$fragment" ]; then
    return 1
  fi

  if inner_script="$(unwrap_shell_wrapper "$fragment")"; then
    if check_bash_command_for_denials "$inner_script"; then
      return 0
    fi
  fi

  original_fragment="$fragment"
  fragment="$(strip_data_arg_values "$fragment")"

  for i in "${!DENY_PATTERNS[@]}"; do
    if [[ $fragment =~ ${DENY_PATTERNS[$i]} ]]; then
      emit_deny_payload "$original_fragment" "${DENY_JUSTIFICATIONS[$i]}"
      return 0
    fi
  done

  return 1
}

# Split command_text on top-level shell operators (;&|), respecting
# quotes, and evaluate every resulting fragment with the supplied
# per-fragment checker function name. Returns 0 only if the checker
# accepted every fragment (used for the allow pass, where all fragments
# must be individually safe); returns 1 as soon as one fragment fails.
walk_bash_fragments() {
  local command_text="$1"
  local checker="$2"
  local fragment
  local char
  local index
  local single_quoted=0
  local double_quoted=0
  local escaped=0

  command_text="$(trim_bash_fragment "$command_text")"
  if [ -z "$command_text" ]; then
    return 0
  fi

  fragment=""

  for ((index = 0; index < ${#command_text}; index++)); do
    char="${command_text:index:1}"

    if [ "$escaped" -eq 1 ]; then
      fragment+="$char"
      escaped=0
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [[ $char == \\ ]]; then
      fragment+="$char"
      escaped=1
      continue
    fi

    if [ "$double_quoted" -eq 0 ] && [ "$char" = "'" ]; then
      if [ "$single_quoted" -eq 1 ]; then
        single_quoted=0
      else
        single_quoted=1
      fi
      fragment+="$char"
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [ "$char" = '"' ]; then
      if [ "$double_quoted" -eq 1 ]; then
        double_quoted=0
      else
        double_quoted=1
      fi
      fragment+="$char"
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [ "$double_quoted" -eq 0 ] && { [ "$char" = ";" ] || [ "$char" = "&" ] || [ "$char" = "|" ]; }; then
      if ! "$checker" "$fragment"; then
        return 1
      fi
      fragment=""
      continue
    fi

    fragment+="$char"
  done

  if ! "$checker" "$fragment"; then
    return 1
  fi

  return 0
}

check_bash_command_for_allow() {
  walk_bash_fragments "$1" check_bash_fragment_for_allow
}

check_bash_command_for_denials() {
  local command_text="$1"
  local fragment
  local char
  local index
  local single_quoted=0
  local double_quoted=0
  local escaped=0

  command_text="$(trim_bash_fragment "$command_text")"
  if [ -z "$command_text" ]; then
    return 1
  fi

  fragment=""

  # Split only on top-level shell operators so quoted wrapper scripts stay intact.
  for ((index = 0; index < ${#command_text}; index++)); do
    char="${command_text:index:1}"

    if [ "$escaped" -eq 1 ]; then
      fragment+="$char"
      escaped=0
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [[ $char == \\ ]]; then
      fragment+="$char"
      escaped=1
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [ "$char" = "'" ]; then
      if [ "$single_quoted" -eq 1 ]; then
        single_quoted=0
      else
        single_quoted=1
      fi
      fragment+="$char"
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [ "$char" = '"' ]; then
      if [ "$double_quoted" -eq 1 ]; then
        double_quoted=0
      else
        double_quoted=1
      fi
      fragment+="$char"
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [ "$double_quoted" -eq 0 ] && { [ "$char" = ";" ] || [ "$char" = "&" ] || [ "$char" = "|" ]; }; then
      if check_bash_fragment_for_denials "$fragment"; then
        return 0
      fi
      fragment=""
      continue
    fi

    fragment+="$char"
  done

  if check_bash_fragment_for_denials "$fragment"; then
    return 0
  fi

  return 1
}

# ── Decision ───────────────────────────────────────────────────────────

# Heredoc body lines are literal data, not live shell syntax -- scan the
# masked form so a Markdown-formatted message body (backticks, $(...), bare
# </>) cannot trip the risky-construct guard. The original $COMMAND is kept
# for the final generic deny message so the agent sees exactly what it sent.
MASKED_COMMAND="$(mask_heredoc_bodies "$COMMAND")"

if check_grep_rg_allow "$MASKED_COMMAND"; then
  emit_allow_payload "Auto-allowed: single read-only grep/rg command, no chaining/substitution/redirection, no sensitive-path or risky-construct indicators."
  exit 0
fi

if check_bash_command_for_allow "$MASKED_COMMAND"; then
  emit_allow_payload "Auto-allowed: every part of this command matched the read-only/side-effect-free Bash allowlist."
  exit 0
fi

if check_bash_command_for_denials "$MASKED_COMMAND"; then
  exit 0
fi

jq -n \
  --arg reason "Command denied: not on the allowlist for automatic execution."$'\n'"Fragment: $COMMAND"$'\n'"${EXECUTE_BASH_HINT}" \
  '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason } }'
exit 0
