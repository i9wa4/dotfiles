#!/usr/bin/env bash
# codex-posttooluse-review.sh - Feedback-only Bash output reviewer for Codex CLI
#
# Hook: PostToolUse | Matcher: Bash
# Purpose: add concise remediation after deterministic verifier/build commands
# fail, without pretending to enforce or rewrite the already-completed command.
set -o errexit
set -o nounset
set -o pipefail
set -o posix

INPUT_JSON=$(cat)

[ -z "$INPUT_JSON" ] && exit 0

COMMAND=$(printf '%s' "$INPUT_JSON" | jq -r '.tool_input.command // empty' 2>/dev/null) || true
[ -z "$COMMAND" ] && exit 0

is_deterministic_command() {
  case "$1" in
  git\ commit* | \
    git\ diff\ --check* | \
    nix\ build* | \
    nix\ run* | \
    nix\ flake\ check* | \
    home-manager\ switch* | \
    bash\ -n* | \
    shellcheck* | \
    statix* | \
    treefmt* | \
    ruff* | \
    rumdl* | \
    pre-commit*)
    return 0
    ;;
  *)
    return 1
    ;;
  esac
}

has_failure_text() {
  printf '%s\n' "$1" | awk '
    BEGIN {
      IGNORECASE = 1
      found = 0
    }
    {
      sanitized = tolower($0)
      gsub(/(^|[^[:alnum:]])0[[:space:]]+failed([^[:alnum:]]|$)/, " ", sanitized)
      gsub(/(^|[^[:alnum:]])zero[[:space:]]+failed([^[:alnum:]]|$)/, " ", sanitized)
      gsub(/(^|[^[:alnum:]])0[[:space:]]+failures?([^[:alnum:]]|$)/, " ", sanitized)
      gsub(/(^|[^[:alnum:]])0[[:space:]]+errors?([^[:alnum:]]|$)/, " ", sanitized)
      gsub(/failures?:[[:space:]]*0([^[:digit:]]|$)/, " ", sanitized)
      gsub(/errors?:[[:space:]]*0([^[:digit:]]|$)/, " ", sanitized)
      if (sanitized ~ /permission denied|traceback/) {
        found = 1
      }
      if (sanitized ~ /(^|[^[:alnum:]])(error|errors|failed|failure|failures)([^[:alnum:]]|$)/) {
        found = 1
      }
    }
    END {
      exit(found ? 0 : 1)
    }
  '
}

is_deterministic_command "$COMMAND" || exit 0

TOOL_RESPONSE_TEXT=$(
  printf '%s' "$INPUT_JSON" | jq -r '
    def render:
      if . == null then
        ""
      elif type == "string" then
        .
      elif type == "object" then
        [
          .stdout? // empty,
          .stderr? // empty,
          .output? // empty,
          .message? // empty,
          (.messages[]? // empty)
        ]
        | map(select(. != ""))
        | join("\n")
      elif type == "array" then
        map(tostring) | join("\n")
      else
        tostring
      end;
    .tool_response | render
  ' 2>/dev/null
) || true

EXIT_CODE=$(printf '%s' "$INPUT_JSON" | jq -r '
  .tool_response as $r
  | if ($r | type) == "object" then
      ($r.exit_code // $r.exitCode // $r.code // empty)
    else
      empty
    end
' 2>/dev/null) || true

FAILED_CHECKS=$(
  printf '%s\n' "$TOOL_RESPONSE_TEXT" |
    awk '/Failed$/ {print $1}' |
    paste -sd ', ' -
) || true

FAILED=no
if [ -n "$EXIT_CODE" ] && [ "$EXIT_CODE" != "0" ]; then
  FAILED=yes
elif has_failure_text "$TOOL_RESPONSE_TEXT"; then
  FAILED=yes
fi

[ "$FAILED" = "yes" ] || exit 0

MESSAGE=""

case "$COMMAND" in
git\ commit*)
  MESSAGE="Deterministic Bash feedback: git commit failed in pre-commit. Fix the first hook marked Failed, rerun git commit once, and only escalate if the second pass still fails."
  if [ -n "$FAILED_CHECKS" ]; then
    MESSAGE="$MESSAGE Current failed checks: $FAILED_CHECKS."
  fi
  ;;
nix\ build* | nix\ run* | nix\ flake\ check* | home-manager\ switch*)
  MESSAGE="Deterministic Bash feedback: this Nix verification step failed. Fix the first explicit error line the tool reported, rerun the same command once, and only escalate after a second explicit failure."
  ;;
*)
  MESSAGE="Deterministic Bash feedback: this cheap verifier failed. Apply the smallest repair named by the tool output, rerun the same command once, and only escalate to deep review or human attention if the second pass still fails."
  ;;
esac

if printf '%s\n' "$TOOL_RESPONSE_TEXT" | grep -Fq 'Permission denied'; then
  MESSAGE="$MESSAGE If the failure came from a repo hook script under nix/home-manager/agents/scripts/, verify the executable bit in git and rebuild."
fi

jq -n \
  --arg message "$MESSAGE" \
  '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: $message
    }
  }'
