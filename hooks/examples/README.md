# hooks/examples/

Example Claude Code hook configurations for `~/.claude/settings.json`.

These are templates only — copy the relevant `hooks` section into your
`~/.claude/settings.json`. Hooks are per-machine and not tracked by dotfiles.

## Hook Behavior

- Exit 0: allow the tool call
- Exit 2: block the tool call (output shown to Claude as error)
- Other non-zero: warning shown, tool call proceeds

## Prerequisites

PreToolUse hooks may be silently skipped if workspace trust is not set.
Run `/claude-workspace-trust-fix` to resolve this. See:
`agents/skills/claude-workspace-trust-fix/SKILL.md`
