---
name: vault-digest
description: |
  Create a structured digest of recent i9wa4/internal vault activity —
  meetings, decisions, and action items — for a specified time period.
  Complements daily-report (which covers GitHub/Jira); this covers vault-native content.
  Use when: "vault digest", "manager digest", "weekly digest",
  "summarize vault activity", "what happened this week in the vault"
---

# vault-digest Skill

Vault root: `~/ghq/github.com/i9wa4/internal/`
Output dir: `digests/`

## Workflow

### Step 1: Determine Date Range

Default: last 7 days (weekly digest).
Accept explicit range if provided (e.g., "2026-02-17 to 2026-02-24").

### Step 2: Scan Vault

```sh
# Meetings in range
ls docs/meetings/ | grep "^<YYYY-MM-DD>"

# Decisions in range
ls decisions/ | grep "^<YYYY-MM-DD>"

# Active action items
grep -rl "status: active" action-items/
```

### Step 3: Read Content

For each file found, read frontmatter and body.
Summarize: title, date, key points.

### Step 4: Compose Digest

Output file: `digests/YYYY-MM-DD-manager-digest.md`

```yaml
---
type: log
date: YYYY-MM-DD
title: "Manager Digest YYYY-MM-DD"
status: active
tags: [digest]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

## Meetings (N)

- YYYY-MM-DD: <title> — <1-line summary>

## Decisions (N)

- YYYY-MM-DD: <title> — <decision summary>

## Open Action Items (N)

- [ ] <title> (owner: <name>, since: YYYY-MM-DD)

## Notes

<anything notable not captured above>
```

### Step 5: Review and Commit

- Show digest to user for review
- Ask permission before committing (per git-github.md rules)
- Commit message: `feat(vault): manager digest <date>`
