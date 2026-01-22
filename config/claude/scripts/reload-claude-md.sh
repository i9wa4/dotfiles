#!/usr/bin/env bash
# reload-claude-md.sh
#
# Hook script to remind Claude to re-read CLAUDE.md after compaction/resume.
# Uses JSON additionalContext so Claude can see the reminder.

cat <<'JSONEOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Session resumed after compaction. Re-read CLAUDE.md: @~/ghq/github.com/i9wa4/dotfiles/config/claude/CLAUDE.md"
  }
}
JSONEOF
