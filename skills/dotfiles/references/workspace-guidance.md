# Agent Workspace

Use this skill to boot, navigate, and manage agent workspaces in tmux: session
creation, vde-layout preset boot, worktree lifecycle, and pane operations.

## 1. Boot Procedure

### 1.1. Agent-Driven Boot (9 steps)

For a `tmux-a2a-postman` agent session, the expected end-user flow is:

```text
new tmux session -> z tmux-a2a-postman -> <boot snippet>
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

7. Execute the resolved snippet end state by sending the expanded vde-layout
   command directly. For the codex-featured team (`vp`) this is currently:

   ```bash
   tmux send-keys -t "$PANE_ID" \
     'vde-layout messenger-codex && vde-layout preset-p' Enter
   ```

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

| Snippet | Expansion                                            | Team                |
| ------- | ---------------------------------------------------- | ------------------- |
| `vp`    | `vde-layout messenger-codex && vde-layout preset-p`  | codex-featured team |
| `vw`    | `vde-layout messenger-claude && vde-layout preset-w` | claude team         |

Per-pane models and reasoning efforts are defined in
`config/vde/layout.yml` and change often; resolve them from the config at
boot time instead of trusting any snapshot here. Zsh snippets:
`config/zsh/snippet.zsh`. See also: `workspace-vde-layout-internals.md`

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

Primary creation entrypoints:
`scripts/bin/issue-worktree-create [--allow-direnv|--no-allow-direnv] <issue_number>`
and `scripts/bin/pr-worktree-create [--allow-direnv] <pr_number>`. For cleanup
inspection in the current repository, use `scripts/bin/worktree-status` to list
every registered worktree with issue/PR state when the naming rules expose a
number, plus local Git state. The command is read-only; use native
`git worktree remove` manually after inspection.

For issue implementation, agents must create or choose the GitHub issue first,
then use `issue-worktree-create <issue_number>`. Do not create issue branches
or worktrees manually, and do not use the generic worktree tool
(`EnterWorktree`) as the entrypoint for issue implementation or PR review.
Before editing, verify `pwd`,
`git branch --show-current`, and
`git status --short --branch`. Before asking a human to push, verify upstream
with `git rev-parse --abbrev-ref --symbolic-full-name @{u}`. Stop and report
`BLOCKED` if an issue branch tracks `origin/main`, `origin/dev`, or another
non-issue upstream. First publication must use the explicit same-name
destination refspec:
`git push --set-upstream origin HEAD:refs/heads/<same-branch-name>`.
GitHub rulesets or branch protection must protect shared remote branches such
as `main` and `dev`.

Both scripts:

- Copy `.envrc` from repo root when available and the checked-out branch did not
  already provide one, including for non-Nix repositories
- Run `repo-setup` if available to attempt devshell hook installation and
  generate per-worktree `.pre-commit-config.yaml`. Newly created issue
  worktrees allow copied source-checkout `.envrc` files by default and evaluate
  them once with `direnv exec <worktree-root> true`. If no `.envrc` exists and
  the worktree has `flake.nix`, default setup lets `repo-setup` create, allow,
  and evaluate the generated `use flake` fallback once; use
  `issue-worktree-create --no-allow-direnv` to opt out. Issue-branch-provided
  `.envrc` files are left unchanged and not allowed by default; review and run
  `repo-setup --allow-direnv` manually or pass `--allow-direnv` explicitly.
  Re-running an existing issue worktree can remediate `direnv allow` only when
  invoked from a distinct source checkout and the existing worktree `.envrc`
  still matches that source checkout `.envrc`, unless `--allow-direnv` is passed
  explicitly after review. Re-running from inside the issue worktree itself does
  not make that branch-owned `.envrc` trusted. PR review worktrees preserve the
  trust gate by creating the generated `.envrc` without allowing it unless
  `pr-worktree-create --allow-direnv` is used after review. When `.envrc` is
  explicitly allowed, `repo-setup` evaluates it once with
  `direnv exec <worktree-root> true`. If the one-shot direnv load, Nix, or
  devshell setup fails, `repo-setup` warns and continues; re-run `repo-setup`
  or enter the devshell before pushing.
- Register path with `zoxide add "$worktree_path"` as the last step

Issue worktrees use the issue branch name as the worktree directory name.
Existing remote issue branches are configured as upstream. New local issue
branches intentionally have no upstream until explicit same-name publication.
PR worktrees keep the local branch name equal to the PR head branch, but use a
directory name like
`.worktrees/pr-<number>-<head-branch-with-slashes-replaced>/`.

Re-entry after creation: `z <branch>` or `^g` (`__zoxide_zi_widget`).

See `workspace-worktree-workflow.md` for full command reference including
inspection, cleanup, and baseline verification.

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
  `__z_tmux_rename_for_dir` directly at `zoxide.zsh:71`
- `zi [keywords...]` — interactive fzf version of `z`
- `worktree-status` — read-only inventory of every worktree registered to the
  current repository, with issue/PR state when available from naming rules,
  local flags, dirty state, upstream status, branch, HEAD, and path

## 7. Common tmux Pane Operations

For pane send-keys, capture-pane, hook-bypass via load-buffer + paste-buffer,
and monitoring patterns, see `workspace-tmux-pane-operations.md`.

Key rules:

- Add `sleep 1` between consecutive `send-keys` calls
- Always use pane IDs (`%N` format) for reliable targeting
- For hook-blocked content: write to file, then
  `tmux load-buffer <file> && tmux paste-buffer -t %N && tmux send-keys -t %N Enter`

## 8. Postman Integration Caveats

- Freshly-booted sessions may not appear in `tmux-a2a-postman get-status` even
  when tmux topology is correct; wait briefly and retry status
- `tmux list-sessions` is authoritative for session existence; postman routing
  may lag
- Codex logs WAL bloat was fixed upstream in 0.142.0; see
  `skills/dotfiles/references/codex-optimization-tracking.md` §1.2 for the
  resolution
  note and the archived runbook pointer

## 9. Reference Index

- [Worktree Workflow](workspace-worktree-workflow.md)
- [Worktree Development](worktree-development.md)
- [Worktree Development Overview](worktree-development-overview.md)
- [Pane Operations](workspace-tmux-pane-operations.md)
- [Boot Failure Modes](workspace-boot-failure-modes.md)
- [VDE Layout Internals](workspace-vde-layout-internals.md)
