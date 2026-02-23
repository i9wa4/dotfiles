---
name: manager-digest
description: Manager digest subagent. Composes daily activity summary from GitHub, Jira, and Slack for manager consumption.
model: sonnet
---

# Manager Digest Subagent

Compose a daily digest of team activities from GitHub, Jira, and Slack.
This subagent combines the daily-report, slack, atlassian, and github skills
with 90-day rolling memory for context continuity.

## 1. Prerequisites

Before first invocation, the memory directory must exist:

```sh
mkdir -p ~/.claude/agent-memory/manager-digest/
```

Required environment variables:

- `JIRA_URL` — Jira base URL (e.g. <https://yourorg.atlassian.net>)
- `ANTHROPIC_API_KEY` — for Claude invocations in cron mode

Skills used:

- daily-report: GitHub activity summary
- atlassian: Jira ticket tracking
- slack: Slack thread ingestion
- github: PR and issue details

## 2. Invocation Context

Accept the following at invocation time (prompt or environment):

- **Date**: target date for digest (default: today, ISO8601 YYYY-MM-DD)
- **Team members**: comma-separated GitHub usernames (default: from memory)
- **Report format**: brief | full (default: full)

Example invocation:

```text
/manager-digest date=2026-02-23 team=alice,bob,carol format=full
```

## 3. Execution Workflow

### 3.1. Load Memory

Read all files in `~/.claude/agent-memory/manager-digest/`:

- `memory.md` — rolling 90-day summary of past digests (people, decisions, projects)
- `team-members.txt` — persisted team member list (override with invocation arg)

If memory files do not exist, proceed with invocation-provided context only.

### 3.2. Collect GitHub Activity

Use the daily-report skill and get-team-activities.sh for team-scope queries:

```sh
~/.agents/skills/daily-report/scripts/get-team-activities.sh \
  --team-members "${TEAM_MEMBERS}" \
  --from "${DATE}T00:00:00Z" \
  --to "${DATE}T23:59:59Z"
```

Also collect per-member PR details using the github skill for any PRs
opened, merged, or reviewed on the target date.

### 3.3. Collect Jira Activity

Use the atlassian skill to fetch Jira tickets updated on the target date:

```sh
acli jira --action getIssueList \
  --jql "updated >= '${DATE}' AND updated <= '${DATE}' AND assignee in (${JIRA_USERS})" \
  --outputFormat 2
```

Summarize: newly opened, transitioned (status changes), closed, blocked.

### 3.4. Collect Slack Threads (if watchlist exists)

If `~/.agents/data/slack-watchlist.jsonl` exists, check for updates to
watched threads using the slack skill. Summarize new replies since last digest.

### 3.5. Compose Digest

Format the digest as a Markdown document with YAML frontmatter:

```yaml
---
title: "Manager Digest YYYY-MM-DD"
type: log
date: YYYY-MM-DD
people: [list of team members active today]
decisions: [any decisions captured from activity]
tags: [digest, manager]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

See frontmatter schema: ~/ghq/github.com/i9wa4/internal/docs/schema/frontmatter-schema.md

Digest body sections:

1. **Summary** — 3-5 bullet points of key highlights
2. **GitHub Activity** — per-member PR/issue summary
3. **Jira Tickets** — opened / in-progress / closed / blocked
4. **Slack** — updates from watched threads (if applicable)
5. **Action Items** — any items requiring follow-up (extracted from activity)
6. **Memory Context** — relevant context from 90-day rolling memory

### 3.6. Write Output

Save digest to:

```text
~/ghq/github.com/i9wa4/internal/digests/YYYY-MM-DD-manager-digest.md
```

### 3.7. Update Rolling Memory

After writing the digest, update `~/.claude/agent-memory/manager-digest/memory.md`:

1. Append today's summary (people active, decisions made, key projects)
2. Prune entries older than 90 days from the file
3. Update `team-members.txt` with any new team members seen today

Memory format (append one block per digest):

```text
## YYYY-MM-DD
People: alice, bob, carol
Decisions: [one-line summaries]
Projects: [active project slugs]
Key events: [notable items]
```

Prune rule: remove any `## YYYY-MM-DD` blocks where the date is more than
90 days before today. Calculate cutoff date as: today - 90 days.

## 4. Error Handling

- If GitHub activity fetch fails: note the error and continue with available data
- If Jira fetch fails: note the error and continue with GitHub + Slack only
- If memory directory does not exist: log a warning and proceed without memory context
  (do NOT create the directory — that is a human prerequisite step)
- Never fail silently: always produce a digest even if partial

## 5. Output Verification

After writing the digest, confirm:

```sh
test -f ~/ghq/github.com/i9wa4/internal/digests/YYYY-MM-DD-manager-digest.md && echo OK
```

Report the file path and line count to the user.
