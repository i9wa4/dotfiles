#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

# get-team-activities.sh — Fetch GitHub activity for a list of team members
#
# Usage:
#   get-team-activities.sh --team-members alice,bob,carol --from YYYY-MM-DD --to YYYY-MM-DD
#
# Known limitation: `gh search` lacks per-comment timestamp filtering (issue-level date only).
# Comments cannot be filtered by exact timestamp; only issues/PRs updated within the range
# are returned. This is a limitation of the `gh search` API surface.

TEAM_MEMBERS=""
FROM=""
TO=""

while [ $# -gt 0 ]; do
  case "$1" in
  --team-members)
    TEAM_MEMBERS="$2"
    shift
    ;;
  --from)
    FROM="$2"
    shift
    ;;
  --to)
    TO="$2"
    shift
    ;;
  *)
    echo "Unknown option: $1" >&2
    exit 1
    ;;
  esac
  shift
done

if [ -z "$TEAM_MEMBERS" ]; then
  echo "Error: --team-members is required (e.g. --team-members alice,bob,carol)" >&2
  exit 1
fi

if [ -z "$FROM" ] || [ -z "$TO" ]; then
  echo "Error: --from and --to are required (ISO8601 date, e.g. 2026-02-01)" >&2
  exit 1
fi

# Convert comma-separated members to array
IFS=',' read -ra MEMBERS <<<"$TEAM_MEMBERS"

for member in "${MEMBERS[@]}"; do
  echo "## ${member}"
  echo ""

  TEMP_FILE=$(mktemp)
  trap 'rm -f "$TEMP_FILE"' EXIT

  {
    # Authored PRs
    gh search prs \
      --author="${member}" \
      --sort=updated \
      --limit 50 \
      --json repository,number,title,url,updatedAt,state \
      2>/dev/null |
      jq -r --arg from "${FROM}" --arg to "${TO}" '
.[] |
select(.updatedAt >= $from and .updatedAt <= $to) |
"- [PR/" + .state + "] " + .repository.nameWithOwner + " #" + (.number | tostring) + ": " + .title + " (" + .url + ")"
'

    # Reviewed PRs
    gh search prs \
      --reviewed-by="${member}" \
      --sort=updated \
      --limit 50 \
      --json repository,number,title,url,updatedAt,state \
      2>/dev/null |
      jq -r --arg from "${FROM}" --arg to "${TO}" '
.[] |
select(.updatedAt >= $from and .updatedAt <= $to) |
"- [Reviewed] " + .repository.nameWithOwner + " #" + (.number | tostring) + ": " + .title + " (" + .url + ")"
'

    # Authored Issues
    gh search issues \
      --author="${member}" \
      --sort=updated \
      --limit 50 \
      --json repository,number,title,url,updatedAt,state \
      2>/dev/null |
      jq -r --arg from "${FROM}" --arg to "${TO}" '
.[] |
select(.updatedAt >= $from and .updatedAt <= $to) |
"- [Issue/" + .state + "] " + .repository.nameWithOwner + " #" + (.number | tostring) + ": " + .title + " (" + .url + ")"
'
  } >>"$TEMP_FILE"

  if [ -s "$TEMP_FILE" ]; then
    sort -u "$TEMP_FILE"
  else
    echo "(no activity in range ${FROM} to ${TO})"
  fi

  echo ""
  rm -f "$TEMP_FILE"
done
