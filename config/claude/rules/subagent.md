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

## 3. Launching Subagents

### 3.1. Task Tool

```text
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

### 4.2. Capability Rules

Refer to CLAUDE.md Section 4.2 "Capability" for READONLY/WRITABLE rules.
