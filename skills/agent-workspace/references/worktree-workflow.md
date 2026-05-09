# Worktree Workflow

Full reference for git worktree lifecycle in this repo.
Migrated from `skills/using-git-worktrees/SKILL.md`.

## 1. Core Defaults

- Prefer repo wrappers before generic `git worktree` or `vde-worktree` creation
  flows.
- Treat `config/vde/worktree/config.yml` as the local worktree policy source of
  truth.
- Assume the managed root is `.worktrees`, even if generic tool help mentions a
  different default.
- Report the final worktree path and branch in handoff or status messages.
- Keep this reference focused on workspace isolation and inspection, not runtime
  activation or Nix switching.

## 2. Primary Repo Flows

### Issue Execution

Run `issue-worktree-create <issue_number>` from the repo. Expect it to:

- fetch `origin`
- refresh `main`
- reuse `origin/issue-<number>` when present, otherwise reuse the first
  `origin/issue-<number>-*` branch when present
- set existing remote issue branches as upstream
- rely on `push.autoSetupRemote=true` for new local issue branches, so the first
  plain `git push` creates and records `origin/<branch>`
- create a new linked worktree when needed
- copy `.envrc` when available
- run `repo-setup` when available

### PR Review

Run `pr-worktree-create <pr_number>` from the repo. Expect it to:

- fetch `origin`
- refresh `main`
- resolve the PR head branch from GitHub
- keep the local review branch name equal to the PR head branch name
- use a review directory named
  `.worktrees/pr-<number>-<head-branch-with-slashes-replaced>/`
- keep the local review branch connected to the PR source branch as upstream
- fast-forward an existing local review branch to the PR source branch when safe
- refuse to rewrite an existing local review branch that is ahead of or diverged
  from the PR source branch
- create or reuse a linked review worktree
- copy `.envrc` when available
- run `repo-setup` when available
- exit nonzero and avoid the all-ready success message when any requested PR is
  invalid, skipped, refused, or otherwise fails

Both scripts register the worktree path with `zoxide add "$worktree_path"` as
their final step.

## 3. Re-Entry Navigation

After worktree creation, navigate to the worktree via:

- `z <branch-name>` — zoxide wrapper; calls `__z_cd()` →
  `__z_tmux_rename_for_dir()`
- `^g` (`__zoxide_zi_widget`) — fzf picker merging zoxide + ghq sources; calls
  `__z_tmux_rename_for_dir()` directly at `config/zsh/zoxide.zsh:71`, bypassing
  `__z_cd()` entirely
- `zi [keywords...]` — interactive fzf version of `z`

Session rename mechanics on re-entry: `__z_tmux_rename_for_dir` detects
`/.worktrees/` in the path and renames the tmux session to `<repo>-<worktree>`
(e.g., `dotfiles-feature-foo`).

Do not use raw `zoxide` alone as the outermost worktree selector; use the repo
`z` or `zi` wrapper functions that keep navigation in the current shell.

## 4. Supporting Generic Tooling

Use `vde-worktree` only as supporting generic tooling after checking whether the
wrapper flow already covers the task.

- Inspect all worktrees: `vde-worktree list --json`
- Inspect one worktree: `vde-worktree status [branch] --json`
- Inspect likely stale worktrees: `vde-worktree gone --json`
- Resolve a branch to its absolute path: `vde-worktree path <branch> [--json]`
- Delete a confirmed linked worktree: `vde-worktree del <branch>`
- List merged cleanup candidates across ghq repositories:
  `worktree-cleanup-merged --dry-run`
- Delete those candidates after an explicit prompt: `worktree-cleanup-merged`
- Pick a worktree path directly from the generic backend:
  `cd "$(vde-worktree cd)"`
- Reuse or create a branch worktree as a generic fallback:
  `vde-worktree switch <branch>`

Do not use `vde-worktree` as the primary issue or PR entrypoint in this repo.

## 5. Baseline Verification

After entering the chosen worktree, run the cheapest checks that prove you are
in the right place before changing files:

```bash
pwd
git branch --show-current
git status --short
```

For broader worktree visibility:

```bash
git worktree list --porcelain
vde-worktree list --json
```

## 6. Repo Fit Notes

- Cleanup should be explicit: inspect with `vde-worktree list`, `status`, or
  `gone`, then delete confirmed linked worktrees with `vde-worktree del`.
- The repo may contain detached linked worktrees; do not assume every linked
  worktree is a simple branch-only case.
- If the task is about changing worktree scripts or config, read those files in
  full and treat that as a code-change task, not a normal use of this reference.

## 7. Do Not Do These By Default

- Do not ask the user to choose an arbitrary worktree directory.
- Do not teach or rely on `vde-worktree extract`, `absorb`, `unabsorb`, or
  `adopt` as part of the normal repo flow.
- Do not edit `.gitignore`, `config/vde/worktree/config.yml`, or the wrapper
  scripts unless the task is explicitly about those files.
