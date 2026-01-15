# Subagent Rules

Rules for launching subagents via Task tool or codex exec.

## 1. Subagent Prefix

Add this prefix when launching any subagent:

```text
[SUBAGENT MODE] You are running as a subagent.
- Do NOT update .i9wa4/status-* files (mood status)
- Focus only on the assigned task
```

## 2. Subagent Prompt Template

Common template for both Task tool and codex exec:

```text
{PREFIX from "Subagent Prefix"}

{TASK_CONTENT}
```

## 3. Launching Subagents

### 3.1. Task Tool

```text
Task tool prompt parameter:
{SUBAGENT_PROMPT_TEMPLATE with TASK_CONTENT filled}
```

### 3.2. Codex CLI

```bash
codex exec --sandbox danger-full-access "{SUBAGENT_PROMPT_TEMPLATE with TASK_CONTENT filled}"
```

For parallel execution, append `&` and use `wait`.

## 4. Mood Status Update

- Main session: Update `.i9wa4/status-<tty>-<agent>` as needed
- Subagent: NEVER update mood status (skip this rule)

## 5. Subagent Behavior

When you see `[SUBAGENT MODE]` at the start of your prompt:

- YOU MUST: Skip mood status updates
- YOU MUST: Focus only on the assigned task
- YOU MUST: Return results concisely
