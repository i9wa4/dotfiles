---
name: agent-memory
description: |
  Agent memory skill. Save and recall work context.
  Use when:
  - User says "remember this" or "memorize"
  - User says "recall" or "what did we discuss about X"
  - User says "記憶して" or "覚えておいて"
  - User says "思い出して" or "メモ確認して"
  - Need to persist investigation results or decisions
---

# Agent Memory Skill

Save and recall work context across sessions.

## 1. Storage Location

```text
~/.claude/skills/agent-memory/memories/
```

Flat structure with descriptive filenames.

## 2. File Format

### 2.1. Filename

Use descriptive kebab-case names with repository prefix:

- `dotfiles-issue-123-investigation.md`
- `myproject-feature-x-design.md`
- `data-pipeline-architecture-decision.md`

### 2.2. Frontmatter

```yaml
---
summary: Brief one-line description for search
created_at: 2026-01-10T00:43:47+0900
last_accessed_at: 2026-01-10T00:43:47+0900
---
```

Format: ISO 8601 (`YYYY-MM-DDTHH:MM:SS+ZZZZ`)

### 2.3. Body

Free-form markdown content.

## 3. Operations

### 3.1. Save ("remember", "memorize")

1. Ask user for brief summary if not provided
2. Generate descriptive filename
3. Create file with frontmatter and content
4. Confirm save location to user

### 3.2. Recall ("recall", "remember about X")

1. Search memories/ with ripgrep on summary lines
2. Show matching summaries to user
3. Read selected file(s)
4. Update `last_accessed_at` to today

### 3.3. Search Command

```bash
rg "^summary:" ~/.claude/skills/agent-memory/memories/ -A 0
```

## 4. Cleanup Policy

Files with `last_accessed_at` older than 30 days are candidates for deletion.
User can run cleanup manually.

### 4.1. Find Old Memories

```bash
fd -e md --changed-before 30d . ~/.claude/skills/agent-memory/memories/
```

Or check `last_accessed_at` in frontmatter.

## 5. Important Rules

1. Always update `last_accessed_at` when reading a memory
2. Keep summaries concise (under 80 chars) for search efficiency
3. Use descriptive filenames for easy identification
4. Do not save sensitive information (credentials, secrets)
