---
name: daily-report
description: |
  Daily report creation skill. Summarizes GitHub and Jira activities,
  creates a draft, and posts as an Issue.
  Use when:
  - Asked to "create daily report" or "write daily report"
  - Asked to "summarize today's activities"
  - Requested to create a daily report or journal
---

# Daily Report Skill

Summarize @i9wa4's GitHub and Jira activities and post as a GitHub Issue.

## 1. Prerequisites

- gh CLI installed
- jq installed
- acli installed (for Jira)

## 2. Workflow

### 2.1. Get GitHub Activities

Use dedicated script to fetch activities.
Defaults to fetching 24 hours of activities from current time
(calculated in UTC).

#### 2.1.1. Script Location

```text
${CLAUDE_CONFIG_DIR}/skills/daily-report/scripts/get-activities.sh
```

#### 2.1.2. Command Examples

```bash
# Default: 24 hours ago to now (local repos only via ghq list)
${CLAUDE_CONFIG_DIR}/skills/daily-report/scripts/get-activities.sh --no-url

# Specify hours: N hours ago to now
${CLAUDE_CONFIG_DIR}/skills/daily-report/scripts/get-activities.sh --hours 48 --no-url

# Specify datetime directly (ISO8601, UTC)
${CLAUDE_CONFIG_DIR}/skills/daily-report/scripts/get-activities.sh --from 2025-12-16T15:00:00Z --to 2025-12-17T15:00:00Z --no-url
```

#### 2.1.3. Options

| Option             | Description                                              |
| ------------------ | -------------------------------------------------------- |
| --no-url           | Output without URLs (prevents mention notifications)     |
| --hours N          | Fetch activities from N hours ago to now                 |
| --from             | Start datetime (ISO8601, e.g., 2025-12-17T00:00:00Z)     |
| --to               | End datetime (ISO8601, e.g., 2025-12-17T23:59:59Z)       |
| --hostname         | GitHub Enterprise Server hostname                        |
| --exclude-owner    | Exclude repos by owner (comma-separated, default: i9wa4) |
| --include-personal | Include personal repos (overrides --exclude-owner)       |

#### 2.1.4. Output Format

```markdown
### repository-owner/repository-name

- [Issue] Issue title
- [IssueComment] Issue title
- [PullRequest] PR title
- [PullRequestComment] PR title
- [ReviewedPR] PR title (PRs reviewed by me, excludes my own PRs)
```

Note: Use `--no-url` option to omit URLs and prevent mention notifications.
Note: Personal repos (i9wa4/\*) are excluded by default.

### 2.2. Get Jira Activities

Use acli to fetch Jira activities.

```sh
# Today's activities
acli jira workitem search \
    --jql "updated >= startOfDay() AND (assignee = currentUser() OR reporter = currentUser()) ORDER BY updated DESC" \
    --fields "key,summary,status"

# Specific date range
acli jira workitem search \
    --jql "updated >= 'YYYY-MM-DD' AND updated < 'YYYY-MM-DD' AND (assignee = currentUser() OR reporter = currentUser()) ORDER BY updated DESC" \
    --fields "key,summary,status"
```

### 2.3. Get Meetings from Google Calendar

Fetch today's meetings from Google Calendar via Slack DM.

#### 2.3.1. Prerequisites

Environment variables required:

```sh
export SLACK_GCAL_DM_URL="https://app.slack.com/client/E.../D..."
export SLACK_MCP_XOXC_TOKEN="xoxc-..."
export SLACK_MCP_XOXD_TOKEN="xoxd-..."
```

#### 2.3.2. Fetch Messages from Last 24 Hours

```sh
# Extract channel ID from URL
CHANNEL=$(echo "$SLACK_GCAL_DM_URL" | sed -n 's|.*/client/[^/]*/\([^/]*\).*|\1|p')

# Fetch messages
FILE=$(mkoutput --dir tmp --label output)
curl -s -X POST "https://slack.com/api/conversations.history" \
  -H "Authorization: Bearer $SLACK_MCP_XOXC_TOKEN" \
  -H "Cookie: d=$SLACK_MCP_XOXD_TOKEN" \
  -d "channel=${CHANNEL}" \
  -d "limit=200" > "$FILE"

# Filter messages from last 24 hours
NOW=$(date +%s)
YESTERDAY=$((NOW - 86400))
jq -r --argjson yesterday "$YESTERDAY" \
  '.messages[] | select(.ts | tonumber > $yesterday)' "$FILE"
```

#### 2.3.3. Extract Today's Schedule

Look for the "Today" summary message in 24-hour messages.
This message contains all meetings for the day in attachments array.

Key indicators:

- Message text starts with `*Today*-<!date^...`
- Attachments contain meeting info with Unix timestamps

#### 2.3.4. Parse Meeting Times from Timestamps

Meetings use Unix timestamp format: `<!date^UNIX_TIMESTAMP^{time}|...>`

Convert timestamps to local time:

```sh
date -r UNIX_TIMESTAMP "+%H:%M"
```

#### 2.3.5. Output Format

Extract from attachments:

- Meeting title: From link text (e.g., `|Meeting Name>*`)
- Start/End time: Convert Unix timestamps to HH:MM format
- Skip cancelled meetings (indicated by strike-through in separate messages)

Format as: `- Meeting name (HH:MM-HH:MM)`

### 2.4. Get dotfiles Changes

Fetch commits from the dotfiles repository in the last 24 hours.

```sh
cd ~/ghq/github.com/i9wa4/dotfiles && git log --oneline --since="24 hours ago" --author="$(git config user.name)" --name-only
```

Summarize changes by file/feature (not individual commits).

### 2.5. Create Draft

Create file:

```bash
FILE=$(mkoutput --dir tmp --label "daily-$(whoami)")
```

NOTE: Keep command blocks in "Today's AI Activities" section.
Execute commands and paste results below the command block.

Template:

````markdown
---
title: "YYYY-MM-DD $(whoami)"
labels:
  - name: "日報"
    color: "0887b9"
---

## 1. Today's Activities

### 1.1. GitHub

Organize gh-furik output. Classify as follows:

#### 1.1.1. Created Issues

- [repo-name] Issue title

#### 1.1.2. Created PRs

- [repo-name] PR title
- [repo-name] PR title (merged)
  - Add supplementary comments indented

#### 1.1.3. Reviewed PRs

- [repo-name] PR title

#### 1.1.4. Commented Issues/PRs

- [repo-name] Issue/PR title

### 1.2. Jira

- [KEY-123] Issue summary (status)

### 1.3. Meetings

- Meeting name
  - Supplementary comments

## 2. Today's AI Activities

### 2.1. Claude Code

```console
ccusage --compact --since $(date +%Y%m%d)
```

| Date | Models | Input | Output | Cost (USD) |
| ---- | ------ | ----- | ------ | ---------- |

### 2.2. Codex CLI

```console
ccusage-codex --compact --since $(date +%Y%m%d)
```

| Date | Models | Input | Output | Cost (USD) |
| ---- | ------ | ----- | ------ | ---------- |

### 2.3. dotfiles

- Changed file or feature summary
- Another change summary

## 3. Reflection
````

### 2.6. Wait for User Edit

Display draft and wait for user edits. User adds reflections.

### 2.7. Post Issue

Post with `gh issue create`:

```bash
gh issue create --title "YYYY-MM-DD $(whoami)" --label "日報" --body "$(cat <<'EOF'
[body]
EOF
)"
```

Display Issue URL after posting.

## 3. Important Rules

1. No direct links: Do not link PRs/Issues directly (triggers mentions),
   use titles only
2. PR/Issue numbers: Use `(# 123)` with space, not `(#123)`.
   Without space, GitHub auto-links to unintended repos.
3. Draft review: Always show draft to user and wait for edits
4. Issue posting: Post after user confirms draft is ready

## 4. Output Type Classification

Classify script output as follows:

| Output Type        | Classification       |
| ------------------ | -------------------- |
| Issue              | Created Issues       |
| PullRequest        | Created PRs          |
| ReviewedPR         | Reviewed PRs         |
| IssueComment       | Commented Issues/PRs |
| PullRequestComment | Commented Issues/PRs |

Note: Consolidate multiple comments on same Issue/PR into one.
Note: ReviewedPR only includes PRs authored by others (my own PRs excluded).
