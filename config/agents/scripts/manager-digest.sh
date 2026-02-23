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

# 2026 Japanese national holidays — verified from Cabinet Office CSV
# Source: https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv
# Count: 18 dates (16 national holidays + 2 振替休日)
HOLIDAYS=(
  "20260101" # 元日 (New Year's Day)
  "20260112" # 成人の日 (Coming of Age Day)
  "20260211" # 建国記念の日 (Foundation Day)
  "20260223" # 天皇誕生日 (Emperor's Birthday)
  "20260320" # 春分の日 (Vernal Equinox Day)
  "20260429" # 昭和の日 (Showa Day)
  "20260503" # 憲法記念日 (Constitution Day)
  "20260504" # みどりの日 (Greenery Day)
  "20260505" # こどもの日 (Children's Day)
  "20260506" # 振替休日 (Substitute Holiday — Children's Day cluster)
  "20260720" # 海の日 (Marine Day)
  "20260811" # 山の日 (Mountain Day)
  "20260921" # 敬老の日 (Respect for the Aged Day)
  "20260922" # 振替休日 (Substitute Holiday — Respect for the Aged Day)
  "20260923" # 秋分の日 (Autumnal Equinox Day)
  "20261012" # スポーツの日 (Sports Day)
  "20261103" # 文化の日 (Culture Day)
  "20261123" # 勤労感謝の日 (Labor Thanksgiving Day)
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
