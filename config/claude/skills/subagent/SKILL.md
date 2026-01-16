---
name: subagent
description: |
  Subagent launch skill. Rules for Task tool and codex exec.
  Use when:
  - Launching parallel reviewers or workers
  - Using Task tool for subtasks
  - Using codex exec for background tasks
---

# Subagent Skill

Rules for launching subagents via Task tool or codex exec.

Refer to CLAUDE.md Section 4 "Architecture Concepts" for capability definitions.

## 1. Header Format

Include capability in header when launching subagents:

```text
[SUBAGENT capability=READONLY]
{task content}
```

```text
[SUBAGENT capability=WRITABLE]
{task content}
```

Default: READONLY (for investigation, review, analysis)
Explicit: WRITABLE (for implementation, modification)

## 2. Prompt Template

```text
[SUBAGENT capability={CAPABILITY}]

{TASK_CONTENT}

Output: {OUTPUT_PATH}
```

Variables:

- `CAPABILITY`: READONLY or WRITABLE
- `TASK_CONTENT`: Task description, agent reference, etc.
- `OUTPUT_PATH`: `.i9wa4/{timestamp}-{source}-{role}-{id}.md`

## 3. Launching Subagents

### 3.1. Task Tool

```text
Task tool prompt parameter:
[SUBAGENT capability=READONLY]

{task content}

Output: .i9wa4/{timestamp}-cc-{role}-{id}.md
```

### 3.2. Codex CLI

```bash
codex exec --sandbox danger-full-access "[SUBAGENT capability=READONLY]

{task content}

Output: .i9wa4/{timestamp}-cx-{role}-{id}.md"
```

For parallel execution, append `&` and use `wait`.

## 4. Subagent Behavior

When you see `[SUBAGENT capability=...]` at the start of your prompt:

### 4.1. Always

- Skip mood status updates (.i9wa4/status-* files)
- Focus only on the assigned task
- Return results concisely
- Write output to specified path

### 4.2. READONLY Mode

- NEVER: Edit, Write, NotebookEdit (project files)
- ALLOWED: Read, Glob, Grep, Bash (read-only commands)
- ALLOWED: Write to `.i9wa4/` for reports

### 4.3. WRITABLE Mode

- All tools allowed
- Can modify project files
- Can execute any Bash commands
