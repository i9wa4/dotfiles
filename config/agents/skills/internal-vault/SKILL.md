---
name: internal-vault
description: |
  Day-to-day CRUD operations in the i9wa4/internal Obsidian vault.
  Use when manually creating, updating, or querying individual vault notes —
  meeting notes, decisions, action items, daily notes, or digests.
  NOT for raw transcript processing (use transcript-processor for that).
  Triggers: "create meeting note", "add action item", "log decision",
  "add to vault", "internal vault note", "create decision record",
  "check open action items", "vault note"
---

# internal-vault Skill

Vault root: `~/ghq/github.com/i9wa4/internal/`
Schema: `docs/schema/frontmatter-schema.md`

## Vault Structure

| Directory      | type value | Notes                            |
| -------------- | ---------- | -------------------------------- |
| docs/meetings/ | meeting    | One file per meeting             |
| decisions/     | decision   | Architecture / process decisions |
| action-items/  | log        | Tracked action items             |
| digests/       | log        | Periodic summary digests         |
| notes/         | log        | Daily notes and scratch          |
| moc/           | moc        | Map of Content index files       |

## Filename Patterns

| Type     | Pattern                | Example                    |
| -------- | ---------------------- | -------------------------- |
| meeting  | `YYYY-MM-DD-<slug>.md` | `2026-02-24-infra-sync.md` |
| decision | `YYYY-MM-DD-<slug>.md` | `2026-02-24-choose-db.md`  |
| log      | `YYYY-MM-DD-<slug>.md` | `2026-02-24-setup-ci.md`   |
| daily    | `YYYY-MM-DD.md`        | `2026-02-24.md`            |

## Required Frontmatter by Type

### meeting

```yaml
---
type: meeting
date: YYYY-MM-DD
title: ""
people: []
status: active
tags: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

### decision

```yaml
---
type: decision
date: YYYY-MM-DD
title: ""
decisions: []
status: active
tags: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

### action item (log)

```yaml
---
type: log
date: YYYY-MM-DD
title: ""
status: active
tags: [action-item]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

## Creating a Note

1. Determine type from context
2. Choose directory and filename pattern
3. Write frontmatter using template above
4. Add body content
5. Verify with: `grep -r "type: <type>" <dir> | head -5`

## Common Queries

```sh
# All active action items
grep -rl "status: active" action-items/

# Meetings in last 7 days (compare only YYYY-MM-DD prefix of filename)
WEEK_AGO=$(date -d "7 days ago" +%Y-%m-%d) && ls docs/meetings/ | awk -v w="$WEEK_AGO" '{if (substr($0,1,10) >= w) print}'

# All decisions
ls decisions/
```
