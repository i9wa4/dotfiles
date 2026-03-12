---
name: claude-workspace-trust-fix
description: |
  Fix for Claude Code PreToolUse hooks being silently skipped in interactive mode.
  Sets hasTrustDialogAccepted: true for all project entries in ~/.claude/.claude.json.
  Use when:
  - PreToolUse hooks are not firing in interactive mode
  - Hooks work in `-p` mode but not interactive
  - User says "fix workspace trust" or "hooks not working"
  - Setting up Claude Code on a new machine
  - After adding new projects to Claude Code
---

# Claude Workspace Trust Fix

Workaround for a known bug where PreToolUse hooks in `~/.claude/settings.json`
are silently skipped in interactive mode. The root cause is that
`~/.claude/.claude.json` defaults `hasTrustDialogAccepted` to `false` for each
project entry, and the trust dialog itself does not set the flag correctly.

`-p` (non-interactive) mode bypasses the workspace trust check, so hooks appear
to work there but not in interactive sessions.

## Affected Versions

Confirmed on v2.1.69 (March 2026). The upstream issues were closed by stale bot
without a real fix:

- `anthropics/claude-code` issue 12100
- `anthropics/claude-code` issue 13288

## Fix Procedure

1. Back up the current file
2. Set `hasTrustDialogAccepted: true` for every project entry
3. Verify the result
4. Instruct user to restart Claude Code sessions

```sh
# 1. Backup
cp ~/.claude/.claude.json ~/.claude/.claude.json.bak

# 2. Apply fix
python3 -c "
import json, pathlib
p = pathlib.Path.home() / '.claude' / '.claude.json'
data = json.loads(p.read_text())
count = 0
for key in data.get('projects', {}):
    if not data['projects'][key].get('hasTrustDialogAccepted', False):
        data['projects'][key]['hasTrustDialogAccepted'] = True
        count += 1
p.write_text(json.dumps(data, indent=2) + '\n')
print(f'Fixed {count} project entries')
"

# 3. Verify
python3 -c "
import json, pathlib
p = pathlib.Path.home() / '.claude' / '.claude.json'
data = json.loads(p.read_text())
projects = data.get('projects', {})
false_count = sum(1 for v in projects.values() if not v.get('hasTrustDialogAccepted', False))
true_count = sum(1 for v in projects.values() if v.get('hasTrustDialogAccepted', False))
print(f'Total: {len(projects)} | true: {true_count} | false: {false_count}')
"
```

## Important Notes

- This file (`~/.claude/.claude.json`) is local to each machine -- it is not
  managed by dotfiles or Nix
- New projects added later will also default to `false`, so rerun the fix
  periodically or after adding new projects
- Running Claude Code sessions must be restarted to pick up the change

## Diagnosis

If hooks still do not fire after applying the fix:

1. Clear `/tmp/deny-debug.log` and attempt an Edit in interactive mode
2. If the debug log remains empty, hooks are not being invoked at all
3. Test with `-p` mode: `claude -p 'Edit README.md add <!-- test -->'`
4. If `-p` fires hooks but interactive does not, re-check `hasTrustDialogAccepted`

## Reference

See related vault note for background investigation details.
