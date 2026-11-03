# Agent Workspace

Use this skill to boot, navigate, and manage agent workspaces in tmux: session
creation, vde-layout preset boot, worktree lifecycle, and pane operations.

## 1. Boot Procedure

### 1.1. Agent-Driven Boot (9 steps)

For a vde-layout workspace, the expected end-user flow is:

```text
new tmux session -> target directory -> <boot snippet>
```

The boot snippet is a short zsh keyword (currently `vp` for the codex-featured
team and `vw` for the claude team). When driving that flow from another agent
pane, resolve the snippet from the repo's current configuration, then send the
expanded vde-layout command directly. Do not rely on interactive snippet
injection from non-interactive shells, and do not trust hardcoded examples in
this skill over the config files.

Resolution order for the boot snippet:

1. Inspect `config/zsh/snippet.zsh` and find the `vde-layout` snippets
   (keywords such as `vp` and `vw`).
2. Inspect `config/vde/layout.yml` for every `vde-layout <preset>` referenced
   by the chosen snippet.
3. Send the snippet command exactly as resolved, unless the user requested a
   different preset.

After resolving the snippet, boot the session:

1. Create session and capture pane id:

   ```bash
   PANE_ID=$(tmux new-session -d -P -F '#{pane_id}' -s <session-name>)
   ```

2. Wait 5s minimum for zsh init, zoxide.zsh, and snippet widgets to fully
   initialize in the new pane. (Empirically confirmed: 2s is insufficient; see
   `workspace-boot-failure-modes.md`)
3. Navigate to the target directory:

   ```bash
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

7. Execute the resolved snippet end state by sending the expanded vde-layout
   command directly. For the codex-featured team (`vp`) this is currently:

   ```bash
   tmux send-keys -t "$PANE_ID" \
     'vde-layout preset-p' Enter
   ```

   Each team preset already includes its messenger and starts clients directly
   without an initial role message. Read common/role instructions in complete
   POP archives. Do not prepend a second messenger preset.
   Postman configuration is independent of this launcher and is authored in
   `tmux-a2a-postman help config`.
8. Wait 8-12s for vde-layout to materialize all panes.
9. Verify topology:

   ```bash
   tmux list-windows -t <session>
   tmux list-panes -t <session> -a -F "#{window_index} #{pane_title} #{pane_current_command}"
   ```

### 1.2. Human-Driven Boot

The human types the snippet keyword (for example `vp`) + Space in interactive
zsh. `snippet-magic-space` expands it to the full vde-layout command, then
Enter executes it. Both paths arrive at identical end state.

Source: `config/zsh/snippet.zsh`, `config/vde/layout.yml`
See also: `workspace-boot-failure-modes.md`

## 2. Current Boot Snippets

| Snippet | Expansion             | Team                |
| ------- | --------------------- | ------------------- |
| `vp`    | `vde-layout preset-p` | codex-featured team |
| `vw`    | `vde-layout preset-w` | claude team         |

Per-pane models and reasoning efforts are defined in
`config/vde/layout.yml` and change often; resolve them from the config at
boot time instead of trusting any snapshot here. Zsh snippets:
`config/zsh/snippet.zsh`. See also: `workspace-vde-layout-internals.md`

## 3. Session Naming

`__z_tmux_rename_for_dir` is defined in `config/zsh/zoxide.zsh`.

Trigger paths:

- `z <dir>` calls `__z_cd()` which calls `__z_tmux_rename_for_dir()`
- `^g` (`__zoxide_zi_widget`) calls `__z_tmux_rename_for_dir()` directly,
  bypassing `__z_cd()`

Rename rules:

- Normal repo: session renamed to repo basename (e.g., `dotfiles`)
- Worktree path (`/.worktrees/` detected): renamed to `<repo>-<worktree>` (e.g.,
  `dotfiles-feature-foo`)
- Dots replaced with dashes: `i9wa4.github.io` becomes `i9wa4-github-io`
- Only fires when `$TMUX` is set

Note for agent callers: use the dash form (not dot form) when referencing a
session by name in tmux commands.

## 4. Worktree Lifecycle

Read [Worktree Workflow](workspace-worktree-workflow.md) before issue/PR
worktree creation, reuse, bootstrap, publication preparation or cleanup. It
alone owns commands, invoking-checkout/base selection, upstream invariants,
envrc trust and hook readiness. Use its wrapper-first entry, including for small
changes; never replace issue/PR isolation with a generic worktree tool or shared
index.

[Worktree Architecture and History](worktree-development-overview.md) explains
the design without a competing procedure. A path returned by a wrapper does not
prove devshell/hook setup succeeded. Stop for unsafe upstream configuration;
retain explicit inspection before any cleanup. Runtime activation remains
outside this lifecycle.

## 5. Git Lock Diagnostics

Use `scripts/bin/git-locks` when a Git command reports an existing lock such as
`.git/index.lock`.

For the common ghq-wide update case, run `ghq-repo-repair` before
`ghq get --update --parallel`. It scans every ghq-managed repository, removes
stale PID-backed locks, removes sufficiently old PID-less lock files, and
prunes stale worktree administrative entries. The `up` zsh snippet expands to
`ghq-repo-repair && ghq list | ghq get --update --parallel && ghq-repo-status`.
Use `ghq-repo-repair --dry-run` to inspect the cleanup candidates without
changing files.

`git-locks` inspects the current repository with `GIT_OPTIONAL_LOCKS=0`, so the
diagnostic read should not create optional index locks. By default it scans the
current worktree git-dir plus the shared common git-dir. Pass
`--all-worktrees` to also inspect every linked worktree registered by
`git worktree list --porcelain`.

The command understands Git's `core.lockfilePid` PID sidecar format. With that
Git setting enabled, a lock such as `index.lock` may have a sibling
`index~pid.lock` containing `pid <value>`. `git-locks` reports the lock age,
PID, whether the PID is still alive, and the cleanup action it would take.

Default mode is read-only:

```bash
git-locks
git-locks --all-worktrees
```

Only use cleanup mode for stale locks whose PID is no longer alive:

```bash
git-locks --clean-stale
git-locks --all-worktrees --clean-stale
```

Cleanup removes only locks with a valid PID sidecar whose process is not
running. `--clean-unknown` also removes PID-less or invalid-PID locks after the
configured age floor; this is intended for old, clearly abandoned locks such as
failed ghq-wide updates, not for active repositories. The default cleanup age
floor is 5 seconds; override it only for tests or when you have just verified
the race is impossible:

```bash
git-locks --clean-stale --min-age 0
```

Do not use `git-locks` as a substitute for worktree isolation. If multiple
agents or panes need to make Git index changes concurrently, split the work into
separate issue or PR worktrees first.

## 6. Navigation Primitives

- `z <keyword>` — zoxide wrapper (`config/zsh/zoxide.zsh`); triggers session
  rename on cd
- `^g` / `__zoxide_zi_widget` — fzf picker merging zoxide + ghq sources; calls
  `__z_tmux_rename_for_dir` directly
- `zi [keywords...]` — interactive fzf version of `z`
- `worktree-status` — read-only inventory of every worktree registered to the
  current repository, with issue/PR state when available from naming rules,
  local flags, dirty state, upstream status, branch, HEAD, and path

`z` and `zi` are current-shell wrappers, including inside tmux; they do not
switch sessions. `zi` merges zoxide order with missing `ghq list -p` paths into
plain fzf rows. `z` without arguments opens `zi`; `z -` is `cd -`; a directory
argument jumps directly, otherwise keyword lookup falls back to `zi` when
needed. Ctrl-G runs the same picker and directory/session-name path. Worktree
creation registers paths with zoxide; raw zoxide is not the outer navigation
command.

## 7. Common tmux Pane Operations

For pane send-keys, capture-pane, hook-bypass via load-buffer + paste-buffer,
and monitoring patterns, see `workspace-tmux-pane-operations.md`.

Key rules:

- Add `sleep 1` between consecutive `send-keys` calls
- Always use pane IDs (`%N` format) for reliable targeting
- For hook-blocked content: write to file, then
  `tmux load-buffer <file> && tmux paste-buffer -t %N && tmux send-keys -t %N Enter`

## 8. Runtime Notes

- Codex logs WAL bloat was fixed upstream in 0.142.0; see
  `skills/dotfiles/references/codex-optimization-tracking.md` §1.3 for the
  resolution
  note and the archived runbook pointer

## 9. Reference Index

- [Worktree Workflow](workspace-worktree-workflow.md)
- [Worktree Development Overview](worktree-development-overview.md)
- [Pane Operations](workspace-tmux-pane-operations.md)
- [Boot Failure Modes](workspace-boot-failure-modes.md)
- [VDE Layout Internals](workspace-vde-layout-internals.md)
