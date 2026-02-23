---
name: transcript-processor
description: |
  Process raw meeting transcript text into structured i9wa4/internal vault entries.
  Extracts meeting metadata, decisions, and action items; creates MULTIPLE vault files.
  Use when INPUT IS a raw transcript (text blob, file, or Slack thread to parse).
  NOT for manually creating a single note (use internal-vault for that).
  Triggers: "process transcript", "meeting transcript",
  "extract action items from transcript", "transcript", "文字起こし処理"
---

# transcript-processor Skill

Vault root: `~/ghq/github.com/i9wa4/internal/`

## Workflow

### Step 1: Read Input

- Accept raw transcript text (paste, file path, or Slack thread)
- Identify: meeting title, date, people (attendees)

### Step 2: Extract Meeting Metadata

From transcript, identify:

- Date (explicit or inferred from context)
- People / attendees (names mentioned)
- Meeting purpose / topic

### Step 3: Extract Decisions

Scan for:

- Explicit decisions ("we decided", "agreed to", "will use")
- Architectural or process choices made

### Step 4: Extract Action Items

Scan for:

- Tasks assigned ("X will do Y", "action: Z", "TODO:")
- Owner, due date if mentioned

### Step 5: Create Vault Files

#### Meeting note (`docs/meetings/YYYY-MM-DD-<slug>.md`)

```yaml
---
type: meeting
date: YYYY-MM-DD
title: "<meeting title>"
people: [name1, name2]
status: active
tags: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

## Summary

<1-3 sentence summary>

## Decisions

- <decision 1>

## Action Items

- [ ] <action> (owner: <name>)
```

#### Decision records (one per decision, `decisions/YYYY-MM-DD-<slug>.md`)

```yaml
---
type: decision
date: YYYY-MM-DD
title: "<decision title>"
decisions: []
status: active
tags: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

## Context

<why this decision was needed>

## Decision

<what was decided>

## Consequences

<impact>
```

#### Action items (one per item, `action-items/YYYY-MM-DD-<slug>.md`)

```yaml
---
type: log
date: YYYY-MM-DD
title: "<action description>"
status: active
tags: [action-item]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
Owner: <name>
Due: <date or TBD>
```

### Step 6: Review and Commit

- Show created file list to user
- Ask permission before committing (per git-github.md rules)
- Commit message: `feat(vault): process <meeting-title> transcript`
