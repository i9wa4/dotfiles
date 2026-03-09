---
name: vault-management
description: |
  Internal vault file organization and naming conventions.
  Use when:
  - Placing a new file in the vault (internal repo)
  - Moving or renaming existing vault files
  - Deciding whether a file belongs in vault or mkoutput
  - Deprecating a plan or tracking document
  - Promoting an mkoutput draft to permanent vault storage
---

# Vault Management Skill

Authority: `docs/vault-conventions.md` in `~/ghq/github.com/i9wa4/internal/`

Vault base: `~/ghq/github.com/i9wa4/internal/`

---

## 1. Directory Map

| Directory             | Content type                                                  |
| --------------------- | ------------------------------------------------------------- |
| `decisions/`          | Decision records (YYYY-MM-DD-{slug}.md)                       |
| `docs/tracking/`      | Issue plans, checklists, roadmaps, investigations, deprecated |
| `docs/prerequisites/` | Vault reference values, config snippets for ongoing tasks     |
| `docs/meetings/`      | Meeting notes and event notes                                 |
| `docs/adr/`           | ADR archive (legacy, NNNN-{slug}.md)                          |
| `docs/design/`        | Design stubs for deferred issues                              |
| `docs/schema/`        | Data schema specifications                                    |
| `notes/`              | Session logs, Slack threads, dated research, personal memos   |
| `notes/slack/`        | Saved Slack threads                                           |
| `action-items/`       | Action items (YYYY-MM-DD-{slug}.md)                           |
| `digests/`            | Agent-generated digests                                       |
| `agent-data/`         | Agent runtime data (memory, watchlists) — git-tracked         |
| `moc/`                | Map of Content index files (Dataview dashboards)              |
| `people/`             | Person profiles for 1:1 management                            |
| `sprints/`            | Sprint planning records                                       |

**NEVER use `projects/`** — legacy directory, not in convention. Migrate files on contact.

---

## 2. Naming Conventions

### 2.1. Issue tracking files (in `docs/tracking/`)

Pattern: `{issue-slug}-{type}.md` — lowercase, hyphenated, no date prefix.

| File type          | Suffix                   | Example                          |
| ------------------ | ------------------------ | -------------------------------- |
| Active plan        | `-plan-final.md`         | `usdt-647-plan-final.md`         |
| Checklist          | `-checklist.md`          | `usdt-647-checklist.md`          |
| Roadmap            | `-roadmap.md`            | `usdt-647-roadmap.md`            |
| Investigation      | `-{topic}.md`            | `usdt-647-repo-investigation.md` |
| GitHub issues plan | `-github-issues-plan.md` | `usdt-647-github-issues-plan.md` |
| Deprecated plan v1 | `-plan-v1-deprecated.md` | `usdt-647-plan-v1-deprecated.md` |
| Deprecated plan vN | `-plan-vN-deprecated.md` | `usdt-647-plan-v2-deprecated.md` |

### 2.2. Prerequisites / vault references (in `docs/prerequisites/`)

Pattern: `{issue-slug}-{topic}.md`

Example: `usdt-647-b5-allowed-tools.md` — a specific config value used by plan steps.

### 2.3. Session logs and dated research (in `notes/`)

Pattern: `YYYY-MM-DD-{issue-slug}-{topic}.md`

Example: `2026-03-05-usdt-647-session-log.md`

### 2.4. Other typed files

| Type        | Directory      | Pattern                        |
| ----------- | -------------- | ------------------------------ |
| meeting     | docs/meetings/ | `YYYY-MM-DD-{slug}.md`         |
| decision    | decisions/     | `YYYY-MM-DD-{slug}.md`         |
| digest      | digests/       | `YYYY-MM-DD-manager-digest.md` |
| action item | action-items/  | `YYYY-MM-DD-{slug}.md`         |
| daily note  | notes/         | `YYYY-MM-DD.md`                |
| ADR         | docs/adr/      | `NNNN-{slug}.md`               |
| MOC         | moc/           | `{topic}.md`                   |
| person      | people/        | `{slug}.md`                    |

---

## 3. Rule: Type-Based, Not Project-Based

**DO NOT** create per-project subdirectories (e.g., `docs/tracking/USDT-647/`).

All vault directories are organized by content type. Use `project:` frontmatter to associate a file with a project zone:

```yaml
project: genda # or: pivot, admin, personal
```

Filter by project in Dataview:

```dataview
TABLE file.name, status FROM "docs/tracking"
WHERE project = "genda"
```

Project zones:

| Slug     | Description                      |
| -------- | -------------------------------- |
| genda    | GENDA full-time work             |
| pivot    | PIVOT freelance work             |
| admin    | Tax filing, invoicing, contracts |
| personal | Career, housing, private life    |

---

## 4. Deprecation Pattern

When a document is superseded:

1. Rename in-place: add `-v{N}-deprecated` suffix to filename
   - `usdt-647-plan.md` → `usdt-647-plan-v2-deprecated.md`
2. Update frontmatter:
   - `status: deprecated`
   - `superseded-by: usdt-647-plan-final.md`
3. Keep in the same directory — do not move to an archive subdirectory
4. Do not delete unless the file has zero informational value

---

## 5. Promotion Workflow (mkoutput → vault)

Only promote when the document is curated and intended as a permanent reference.

```
1. Draft in mkoutput:
   FILE=$(mkoutput --dir plans --label "usdt-647-plan")

2. Get user/orchestrator approval on content

3. Check docs/vault-conventions.md for the correct target directory and naming pattern

4. Write the finalized version directly to the vault target path (no intermediate copy)
   - Target example: ~/ghq/github.com/i9wa4/internal/docs/tracking/usdt-647-plan-final.md

5. Verify the file exists at the destination
```

**NEVER write directly to vault without approval.**
**NEVER skip the mkoutput draft step for significant documents.**

---

## 6. Do-Not-Vault List

These file types must NOT be placed in the vault:

- Raw investigation dumps from mkoutput (use `mkoutput --dir research`)
- Temporary outputs, throwaway scripts, intermediate drafts
- Evidence files (mkoutput artifacts like `evidence-*.md`, `evidence-*.json`)
- Any file whose only purpose was to support a single session and will never be referenced again
- Agent working files (`session-*.md`, `context-*.md` from agent sessions)

If a file of this type already exists in the vault, move it to `/tmp/` on contact.

---

## 7. Quick Reference: Where Does This File Go?

| I have a...                      | Put it in...                           |
| -------------------------------- | -------------------------------------- |
| New migration plan               | `docs/tracking/`                       |
| Checklist for an ongoing task    | `docs/tracking/`                       |
| Config value referenced by plan  | `docs/prerequisites/`                  |
| Old plan replaced by a new one   | `docs/tracking/` (renamed, deprecated) |
| Session work log                 | `notes/` (with date prefix)            |
| Investigation dump from mkoutput | Do not vault — keep in mkoutput        |
| Decision (architecture, tooling) | `decisions/`                           |
| Meeting notes                    | `docs/meetings/`                       |
