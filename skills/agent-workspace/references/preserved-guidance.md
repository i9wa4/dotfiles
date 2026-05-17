# Preserved Guidance

Original SKILL.md guidance before Waza compaction. Use this reference when the
concise skill needs domain-specific details.

~~~~~~~~~~~~markdown
---
name: agent-workspace
license: MIT
description: |
  Boot and manage agent tmux workspaces using the vde-layout va preset,
  issue-first worktree creation and re-entry, session naming, and pane
  operations.
---

# Agent Workspace

Use this skill to boot, navigate, and manage agent workspaces in tmux: session
creation, vde-layout preset boot, worktree lifecycle, and pane operations.

## 1. Boot Procedure

### Agent-Driven Boot (9 steps)

For a `tmux-a2a-postman` agent session, the expected end-user flow is:

```text
new tmux session -> z tmux-a2a-postman -> va
```

When driving that flow from another agent pane, resolve `va` from the repo's
current configuration, then send the expanded vde-layout command directly. Do
not rely on interactive snippet injection from non-interactive shells, and do
not trust hardcoded examples in this skill over the config files.

Resolution order for `va`:

1. Inspect `config/zsh/snippet.zsh` and find the snippet whose keyword is `va`.
2. Inspect `config/vde/layout.yml` for every `vde-layout <preset>` referenced
   by that snippet.
3. Send the snippet command exactly as resolved, unless the user requested a
   different preset.

After resolving `va`, boot the session:

1. Create session and capture pane id:

   ```bash
   PANE_ID=$(tmux new-session -d -P -F '#{pane_id}' -s <session-name>)
   ```

2. Wait 5s minimum for zsh init, zoxide.zsh, and snippet widgets to fully
   initialize in the new pane. (Empirically confirmed: 2s is insufficient; see
   `references/boot-failure-modes.md`)
3. Navigate to the postman workspace, or to the target repo for non-postman
   workspaces:

   ```bash
   tmux send-keys -t "$PANE_ID" "z tmux-a2a-postman" Enter
   # or, for a non-postman workspace:
   tmux send-keys -t "$PANE_ID" "z <repo-basename-or-dir>" Enter
   ```

4. Wait 3-4s for the chpwd hook and `__z_tmux_rename_for_dir` to fire.
5. Verify pwd:

   ```bash
   tmux send-keys -t "$PANE_ID" "pwd" Enter
   sleep 1 && tmux capture-pane -t "$PANE_ID" -p | tail -5
   ```

6. Verify session rename:

   ```bash
   tmux display-message -t "$PANE_ID" -p '#{session_name}'
   ```

7. Execute the resolved `va` end state by sending the expanded vde-layout
   command directly. As of the current config this is:

   ```bash
   tmux send-keys -t "$PANE_ID" \
     'vde-layout messenger-codex && vde-layout preset-a' Enter
   ```

8. Wait 8-12s for vde-layout to materialize all panes.
9. Verify topology:

   ```bash
   tmux list-windows -t <session>
   tmux list-panes -t <session> -a -F "#{window_index} #{pane_title} #{pane_current_command}"
   ```

### Human-Driven Boot

The human types `va` + Space in interactive zsh. `snippet-magic-space` expands
to `vde-layout messenger-codex && vde-layout preset-a`, then Enter executes it.
Both paths arrive at identical end state.

Source: `config/zsh/snippet.zsh`, `config/vde/layout.yml`
See also: `references/boot-failure-modes.md`

## 2. Current va Preset

| Aspect            | va flow                                                  |
| ----------------- | -------------------------------------------------------- |
| Snippet expansion | `vde-layout messenger-codex && vde-layout preset-a`      |
| Messenger         | codex gpt-5.5, medium                                    |
| Grid              | 3x2, new window                                          |
| orchestrator      | codex gpt-5.5 xhigh                                      |
| worker            | codex gpt-5.5 xhigh                                      |
| worker-alt        | codex gpt-5.5 xhigh                                      |
| guardian          | codex gpt-5.5 xhigh                                      |
| critic            | claude sonnet xhigh                                      |
| boss              | codex gpt-5.5 xhigh                                      |
| Engine mix        | preset-a: 5 codex + 1 claude; messenger: codex           |
| Description       | "codex-featured team"                                   |

Config source: `dotfiles/config/vde/layout.yml`; zsh snippets:
`dotfiles/config/zsh/snippet.zsh`. See also:
`references/vde-layout-internals.md`

## 3. Session Naming

`__z_tmux_rename_for_dir` is defined in `config/zsh/zoxide.zsh`.

Trigger paths:

- `z <dir>` calls `__z_cd()` which calls `__z_tmux_rename_for_dir()`
- `^g` (`__zoxide_zi_widget`) calls `__z_tmux_rename_for_dir()` directly at
  `zoxide.zsh:71`, bypassing `__z_cd()` entirely

Rename rules:

- Normal repo: session renamed to repo basename (e.g., `dotfiles`)
- Worktree path (`/.worktrees/` detected): renamed to `<repo>-<worktree>` (e.g.,
  `dotfiles-feature-foo`)
- Dots replaced with dashes: `i9wa4.github.io` becomes `i9wa4-github-io`
- Only fires when `$TMUX` is set

Note for agent callers: use the dash form (not dot form) when referencing a
session by name in tmux commands.

## 4. Worktree Lifecycle

Primary creation entrypoints: `bin/issue-worktree-create [--allow-direnv]
<issue_number>` and `bin/pr-worktree-create [--allow-direnv] <pr_number>`. For
interactive cleanup in the current repository, use `bin/worktree-remove` to
choose one managed worktree under the repo's `.worktrees/` directory with
`fzf`, validate safety gates, and delete through native `git worktree` cleanup.

For issue implementation, agents must create or choose the GitHub issue first,
then use `issue-worktree-create <issue_number>`. Do not create issue branches
or worktrees manually. Before editing, verify `pwd`,
`git branch --show-current`, and
`git status --short --branch`. Before asking a human to push, verify upstream
with `git rev-parse --abbrev-ref --symbolic-full-name @{u}`. Stop and report
`BLOCKED` if an issue branch tracks `origin/main`.

Both scripts:

- Copy `.envrc` from repo root when available
- Run `repo-setup` if available to attempt devshell hook installation and
  generate per-worktree `.pre-commit-config.yaml`. Issue worktrees keep the
  trusted default: if `.envrc` is missing in a flake checkout, `repo-setup`
  creates it with `use flake` and runs `direnv allow`. PR review worktrees
  preserve the trust gate by creating the generated `.envrc` without allowing
  it unless `pr-worktree-create --allow-direnv` is used after review. If Nix or
  devshell setup fails, `repo-setup` warns and continues; re-run `repo-setup`
  or enter the devshell before pushing.
- Register path with `zoxide add "$worktree_path"` as the last step

Issue worktrees use the issue branch name as the worktree directory name.
Existing remote issue branches are configured as upstream; new local issue
branches rely on `push.autoSetupRemote=true` so the first plain `git push`
creates and records `origin/<branch>`. PR worktrees keep the local branch name
equal to the PR head branch, but use a directory name like
`.worktrees/pr-<number>-<head-branch-with-slashes-replaced>/`.

Re-entry after creation: `z <branch>` or `^g` (`__zoxide_zi_widget`).

See `references/worktree-workflow.md` for full command reference including
inspection, cleanup, and baseline verification.

## 5. Navigation Primitives

- `z <keyword>` — zoxide wrapper (`config/zsh/zoxide.zsh`); triggers session
  rename on cd
- `^g` / `__zoxide_zi_widget` — fzf picker merging zoxide + ghq sources; calls
  `__z_tmux_rename_for_dir` directly at `zoxide.zsh:71`
- `zi [keywords...]` — interactive fzf version of `z`
- `worktree-remove` — repo-root `.worktrees/` `fzf` selector for confirmed
  single worktree deletion, with compact status, upstream status, and branch
  rows

## 6. Common tmux Pane Operations

For pane send-keys, capture-pane, hook-bypass via load-buffer + paste-buffer,
and monitoring patterns, see `references/tmux-pane-operations.md`.

Key rules:

- Add `sleep 1` between consecutive `send-keys` calls
- Always use pane IDs (`%N` format) for reliable targeting
- For hook-blocked content: write to file, then
  `tmux load-buffer <file> && tmux paste-buffer -t %N && tmux send-keys -t %N Enter`

## 7. Postman Integration Caveats

- Freshly-booted sessions may not appear in `tmux-a2a-postman get-status` even
  when tmux topology is correct; wait briefly and retry status
- `tmux list-sessions` is authoritative for session existence; postman routing
  may lag
- WAL bloat (`~/.codex/logs_2.sqlite-wal`) accumulates in multi-pane Codex
  sessions; see `skills/agent-harness-engineering/references/codex-cli.md` WAL
  runbook (do not duplicate here)
~~~~~~~~~~~~
