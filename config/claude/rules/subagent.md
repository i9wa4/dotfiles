# Subagent Rules

Rules for launching and behaving as subagents.

## 1. When This Applies

These rules apply when:

- You see `[SUBAGENT ...]` header at prompt start (behaving as subagent)
- You need to launch subagents via Task tool or codex exec (launching subagents)

## 2. Header Format

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

## 3. Sandbox Settings (Codex CLI)

| Capability | Sandbox Option                        | Write Scope          |
| ---------- | ------------------------------------- | -------------------- |
| READONLY   | `--sandbox workspace-write -C .i9wa4` | .i9wa4/ and /tmp     |
| WRITABLE   | `--sandbox danger-full-access`        | Full access          |

NOTE: `-C .i9wa4` changes working directory to `.i9wa4/`.
Output paths should be relative (e.g., `{timestamp}-cx-{role}-{id}.md`).

## 4. Launching Subagents

### 4.1. Task Tool

```text
[SUBAGENT capability=READONLY]

{task content}

Output: .i9wa4/{timestamp}-cc-{role}-{id}.md
```

### 4.2. Codex CLI

Use sandbox option from Section 3 based on capability.

```bash
# READONLY example
codex exec --sandbox workspace-write -C .i9wa4 "[SUBAGENT capability=READONLY]

{task content}

Output: {timestamp}-cx-{role}-{id}.md"
```

```bash
# WRITABLE example
codex exec --sandbox danger-full-access "[SUBAGENT capability=WRITABLE]

{task content}

Output: .i9wa4/{timestamp}-cx-{role}-{id}.md"
```

For parallel execution, append `&` and use `wait`.

## 5. Subagent Behavior

When you see `[SUBAGENT capability=...]` at the start of your prompt:

### 5.1. Always

- Skip mood status updates (.i9wa4/status-* files)
- Focus only on the assigned task
- Return results concisely
- Write output to specified path

### 5.2. Capability Rules

Refer to CLAUDE.md Section 4.2 "Capability" for READONLY/WRITABLE rules.
