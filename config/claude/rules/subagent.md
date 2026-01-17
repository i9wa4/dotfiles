# Subagent Rules

Rules for launching and behaving as subagents.

## 1. When This Applies

These rules apply when:

- You see `[SUBAGENT ...]` header at prompt start (behaving as subagent)
- You need to launch subagents via Task tool or codex exec (launching subagents)

## 2. Common Rules

### 2.1. Header Format

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

### 2.2. Capability

Refer to orchestrator skill Section 1.2 "Capability"
for READONLY/WRITABLE rules.

### 2.3. Always Skip

- Skip mood status updates (no tmux access in exec/sandbox mode)
- Focus only on the assigned task
- Return results concisely

## 3. Task Tool (Claude Code)

### 3.1. Launching

```text
[SUBAGENT capability=READONLY]

{task content}

Output: .i9wa4/{timestamp}-cc-{role}-{id}.md
```

### 3.2. Behavior

- Write output to specified path in `.i9wa4/`
- Use Edit/Write tools for file creation

## 4. Codex CLI

### 4.1. Sandbox Settings

| Capability | Sandbox Option                        | Write Scope      |
| ---------- | ------------------------------------- | ---------------- |
| READONLY   | `--sandbox workspace-write -C .i9wa4` | .i9wa4/ and /tmp |
| WRITABLE   | `--sandbox danger-full-access`        | Full access      |

### 4.2. Launching

Use `-o` option to capture output reliably:

```bash
# READONLY with -o (recommended)
codex exec --sandbox workspace-write -C .i9wa4 \
  -o ".i9wa4/${TS}-cx-${ROLE}-${ID}.md" \
  "[SUBAGENT capability=READONLY] {task content}" &
wait
```

```bash
# WRITABLE
codex exec --sandbox danger-full-access \
  -o ".i9wa4/${TS}-cx-${ROLE}-${ID}.md" \
  "[SUBAGENT capability=WRITABLE] {task content}" &
wait
```

NOTE: `-o` path is relative to caller's directory (not affected by `-C`).

### 4.3. Behavior

When launched via `codex exec -o`:

- Return results directly as your response (do NOT create files)
- The `-o` option captures your final message automatically
- File creation is unnecessary and unreliable in exec mode
