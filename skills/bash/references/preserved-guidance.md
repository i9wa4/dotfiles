# Preserved Guidance

Original SKILL.md guidance before Waza compaction. Use this reference when the
concise skill needs domain-specific details.

~~~~~~~~markdown
---
name: bash
license: MIT
description: |
  Bash scripting for this repo: writing scripts, worker pane discipline, interactive prompt avoidance, hook denial handling, stall diagnosis
---

# Bash Rules

## 1. Bash Tool Syntax

- NEVER: Do not use subshells `()`; use braces `{ }` instead
- YOU MUST: Wrap pipe `|` commands in braces `{ }` when redirecting
- YOU MUST: Split complex operations across multiple Bash tool calls
- YOU MUST: Use HEREDOC (`cat << 'EOF'`) for multi-line file creation

## 2. Non-Interactive Agent Discipline

- Non-messenger postman panes must avoid interactive prompts
- Do not use explicit sandbox-disable flags
- Do not retry denied commands silently
- On hook or permission block, report `BLOCKED:` to orchestrator
- If a Bash tool stalls past the role idle boundary, suspect prompt deadlock

Example (brace group with pipe):

```sh
FILE=$(mkmd --dir tmp --label output) && { git branch -r | grep issue; } > "$FILE" 2>&1
```
~~~~~~~~
