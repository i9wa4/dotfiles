# Subagent Rules

Rules for launching and behaving as subagents.

## 1. When This Applies

These rules apply when:

- You see `[SUBAGENT ...]` header at prompt start (behaving as subagent)
- You need to launch subagents via Task tool or codex exec (launching subagents)

### 1.1. Who Can Use Subagents

| Role         | Can Launch Subagent | Use Case                    |
| ------------ | ------------------- | --------------------------- |
| Orchestrator | Yes                 | Review only (parallel)      |
| Worker claude| Yes                 | Investigation during impl   |
| Worker codex | No                  | Direct execution preferred  |
| Subagent     | No                  | No nested subagents         |

## 2. Common Rules

### 2.1. Header Format

Include capability in header when launching subagents:

```text
[SUBAGENT capability=READONLY]
{task content}
```

Subagents are READONLY only. Use Worker for WRITABLE tasks.

### 2.2. Capability

See: `skills/orchestrator/SKILL.md` (Architecture Concepts > Capability section)

Subagents operate in READONLY mode only:

| Capability | Description                              | Tools                              |
| ---------- | ---------------------------------------- | ---------------------------------- |
| READONLY   | Investigation, review, analysis          | Read, Glob, Grep, Bash (read-only) |

Writing to `.i9wa4/` for reports is allowed.

### 2.3. Always Skip

- Skip mood status updates (no tmux access in exec/sandbox mode)
- Focus only on the assigned task
- Return results concisely

## 3. Task Tool (Claude Code)

### 3.1. Launching

```text
[SUBAGENT capability=READONLY]

{task content}

Output: .i9wa4/reviews/cc-{role}.md (for reviews)
```

### 3.2. Behavior

- Write output to specified path in `.i9wa4/`
- Use Edit/Write tools for file creation

## 4. Codex CLI

### 4.1. Sandbox Settings

Subagents use READONLY sandbox only:

| Sandbox Option                        | Write Scope      |
| ------------------------------------- | ---------------- |
| `--sandbox workspace-write -C .i9wa4` | .i9wa4/ and /tmp |

### 4.2. Launching

Use `-o` option to capture output reliably:

```bash
# READONLY with -o (recommended)
codex exec --sandbox workspace-write -C .i9wa4 \
  -o ".i9wa4/reviews/cx-${ROLE}.md" \
  "[SUBAGENT capability=READONLY] {task content}" &
wait
```

NOTE: `-o` path is relative to caller's directory (not affected by `-C`).

### 4.3. Behavior

When launched via `codex exec -o`:

- Return results directly as your response (do NOT create files)
- The `-o` option captures your final message automatically
- File creation is unnecessary and unreliable in exec mode
