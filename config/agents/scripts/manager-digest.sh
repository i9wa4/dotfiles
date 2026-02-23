#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

# manager-digest.sh — Cron wrapper for the manager-digest subagent
#
# Intended cron entry (weekdays at 09:00 JST):
#   0 9 * * 1-5 /path/to/manager-digest.sh >> ~/.agents/data/manager-digest-cron.log 2>&1
#
# Prerequisites:
#   - JIRA_URL and ANTHROPIC_API_KEY must be set (checked at startup)
#   - ~/.claude/agent-memory/manager-digest/ must exist (created by human before first run)
#   - Subagent: ~/.claude/agents/manager-digest.md
#   - Team wrapper: ~/.agents/skills/daily-report/scripts/get-team-activities.sh (after home-manager switch)

# NOTE: HOLIDAYS array is a placeholder structure.
# Step 6 (#13) will replace these entries with verified 2026 Cabinet Office dates.
HOLIDAYS=(
  "20260101" # placeholder — Step 6 fills verified Cabinet Office dates
  "20260102" # placeholder
  "20260103" # placeholder
  "20260111" # placeholder
  "20260211" # placeholder
  "20260223" # placeholder
  "20260320" # placeholder
  "20260429" # placeholder
  "20260503" # placeholder
  "20260504" # placeholder
  "20260505" # placeholder
  "20260720" # placeholder
  "20260811" # placeholder
  "20260921" # placeholder
  "20261012" # placeholder
  "20261103" # placeholder
  "20261123" # placeholder
)

# --- Environment variable checks ---

if [ -z "${JIRA_URL:-}" ]; then
  echo "ERROR: JIRA_URL is not set. Exiting." >&2
  exit 1
fi

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "ERROR: ANTHROPIC_API_KEY is not set. Exiting." >&2
  exit 1
fi

# --- Deduplication via flock ---

LOCK_FILE="/tmp/manager-digest.lock"
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  echo "INFO: Another instance of manager-digest.sh is running. Exiting." >&2
  exit 0
fi

# --- Holiday check ---

TODAY=$(date +%Y%m%d)
for holiday in "${HOLIDAYS[@]}"; do
  if [ "$TODAY" = "$holiday" ]; then
    echo "INFO: Today ($TODAY) is a Japanese national holiday. Skipping digest." >&2
    exit 0
  fi
done

# --- Cost log setup ---

COST_LOG="${HOME}/.agents/data/manager-digest-cost.log"
mkdir -p "${HOME}/.agents/data"

# --- Invoke manager-digest subagent ---

TODAY_ISO=$(date +%Y-%m-%d)
START_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "INFO: Starting manager-digest run for ${TODAY_ISO} at ${START_TIME}"

# claude invocation: manager-digest subagent with today's date
# --max-turns 20: cap agentic turns to prevent runaway loops
# --max-tokens 5000: cap output tokens per response to control cost
claude \
  --max-turns 20 \
  --max-tokens 5000 \
  -p "Run the manager-digest subagent for date=${TODAY_ISO}. Read team members from ~/.claude/agent-memory/manager-digest/team-members.txt if available. Produce a full digest and write it to ~/ghq/github.com/i9wa4/internal/digests/${TODAY_ISO}-manager-digest.md. Update rolling memory at the end."

END_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- Cost logging ---

{
  echo "---"
  echo "date: ${TODAY_ISO}"
  echo "start: ${START_TIME}"
  echo "end: ${END_TIME}"
  echo "status: completed"
} >>"$COST_LOG"

echo "INFO: manager-digest run complete. Cost log appended to ${COST_LOG}"
