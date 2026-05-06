# Claude Workspace Trust

Use this workflow when Claude Code `PreToolUse` hooks from
`~/.claude/settings.json` are silently skipped in interactive mode.

The known failure mode is that `~/.claude/.claude.json` can keep
`hasTrustDialogAccepted` set to `false` for project entries. `claude -p`
non-interactive mode bypasses the workspace trust check, so hooks may appear to
work in `-p` mode while interactive sessions skip them.

Confirmed on Claude Code v2.1.69 in March 2026. The relevant upstream issues
were closed by a stale bot without a confirmed fix:

- `anthropics/claude-code` issue 12100
- `anthropics/claude-code` issue 13288

## When To Use

- `PreToolUse` hooks are not firing in interactive mode.
- Hooks work in `claude -p` mode but not in interactive sessions.
- A user says "fix workspace trust" or "hooks not working".
- Claude Code is being set up on a new machine.
- New projects were added to Claude Code and hooks stopped firing there.

## Fix Procedure

This mutates local runtime state. Use it only when the task is to repair the
local Claude Code workspace trust state.

1. Back up the current file.
2. Set `hasTrustDialogAccepted: true` for every project entry.
3. Verify the result.
4. Restart running Claude Code sessions.

```sh
cp ~/.claude/.claude.json ~/.claude/.claude.json.bak
```

```sh
python3 -c '
import json
import pathlib

p = pathlib.Path.home() / ".claude" / ".claude.json"
data = json.loads(p.read_text())
count = 0
for key in data.get("projects", {}):
    project = data["projects"][key]
    if not project.get("hasTrustDialogAccepted", False):
        project["hasTrustDialogAccepted"] = True
        count += 1
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"Fixed {count} project entries")
'
```

```sh
python3 -c '
import json
import pathlib

p = pathlib.Path.home() / ".claude" / ".claude.json"
data = json.loads(p.read_text())
projects = data.get("projects", {})
false_count = sum(
    1 for project in projects.values()
    if not project.get("hasTrustDialogAccepted", False)
)
true_count = sum(
    1 for project in projects.values()
    if project.get("hasTrustDialogAccepted", False)
)
print(f"Total: {len(projects)} | true: {true_count} | false: {false_count}")
'
```

Expected verification result: `false: 0`.

## Important Notes

- `~/.claude/.claude.json` is local to each machine. It is not managed by this
  dotfiles repository or Nix.
- New Claude projects can default to `hasTrustDialogAccepted: false`, so rerun
  the fix after adding projects if interactive hooks stop firing.
- Running Claude Code sessions must be restarted to pick up the changed trust
  state.

## Diagnosis

If hooks still do not fire after applying the fix:

1. Clear `/tmp/deny-debug.log`.
2. Attempt an Edit in Claude Code interactive mode.
3. If the debug log remains empty, hooks are not being invoked at all.
4. Test non-interactive mode with `claude -p`.
5. If `claude -p` fires hooks but interactive mode does not, re-check
   `hasTrustDialogAccepted`.
