# Worktree Workflow

Full reference for git worktree lifecycle in this repo.
Migrated from `skills/using-git-worktrees/SKILL.md`.

## 1. Core Defaults

- Prefer repo wrappers before generic `git worktree` creation flows.
- Assume the managed root is `.worktrees`, even if generic tool help mentions a
  different default.
- Report the final worktree path and branch in handoff or status messages.
- Keep this reference focused on workspace isolation and inspection, not runtime
  activation or Nix switching.

## 2. Primary Repo Flows

### Issue Execution

Run `issue-worktree-create [--allow-direnv] <issue_number>` from the repo.
Expect it to:

- fetch `origin`
- refresh `main`
- reuse `origin/issue-<number>` when present, otherwise reuse the first
  `origin/issue-<number>-*` branch when present
- set existing remote issue branches as upstream
- rely on `push.autoSetupRemote=true` for new local issue branches, so the first
  plain `git push` creates and records `origin/<branch>`
- create a new linked worktree when needed
- copy `.envrc` when available
- run `repo-setup` when available to attempt devshell hook installation and
  generate per-worktree `.pre-commit-config.yaml`, or
  `repo-setup --allow-direnv` when the explicit `--allow-direnv` flag is
  passed. If Nix or devshell setup fails, `repo-setup` warns and continues;
  re-run `repo-setup` or enter the devshell before pushing.

For GitHub issue implementation, use this wrapper flow. Do not create issue
branches or issue worktrees manually, and do not use raw `git worktree add` as
the issue entrypoint.

After entering the issue worktree and before editing or asking a human to push,
verify the current branch and upstream:

```bash
pwd
git branch --show-current
git status --short --branch
git rev-parse --abbrev-ref --symbolic-full-name @{u}
git rev-list --left-right --count HEAD...@{u}
```

For a reused remote issue branch, the upstream must be
`origin/issue-<number>` or `origin/issue-<number>-*`. Stop if an issue branch
tracks `origin/main` or another non-issue upstream. New local issue branches
created by the wrapper may have no upstream until the first plain `git push`;
verify they started from current `main` before editing.

### PR Review

Run `pr-worktree-create [--allow-direnv] <pr_number>` from the repo. Expect it
to:

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
- run `repo-setup` when available to attempt devshell hook installation and
  generate per-worktree `.pre-commit-config.yaml`, or
  `repo-setup --allow-direnv` when the explicit `--allow-direnv` flag is
  passed. If Nix or devshell setup fails, `repo-setup` warns and continues;
  re-run `repo-setup` or enter the devshell before pushing.
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

Use native Git only after checking whether the wrapper flow already covers the
task.

- Inspect all worktrees: `git worktree list --porcelain`
- Resolve a branch to its absolute path:
  `git worktree list --porcelain` and match `branch refs/heads/<branch>`
- Select and delete one managed worktree under the current repo's
  `.worktrees/` directory:
  `worktree-remove`

Do not use raw `git worktree add` as the primary issue or PR entrypoint in this
repo.

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
```

## 6. Repo Fit Notes

- Cleanup should be explicit: inspect current-repo worktrees with
  `worktree-remove` or `git worktree list --porcelain`, then delete selected
  linked worktrees with the wrapper flow.
- `worktree-remove` keeps the selector focused on compact issue/PR status,
  upstream status, and branch rows. Path and upstream-branch details stay hidden
  in selection data for safety checks.
- `worktree-remove` treats both ancestry-merged branches and matching
  squash-merged GitHub PR branches as merged when `gh` can resolve the merged
  PR by head branch.
- The repo may contain detached linked worktrees; do not assume every linked
  worktree is a simple branch-only case.
- If the task is about changing worktree scripts or config, read those files in
  full and treat that as a code-change task, not a normal use of this reference.
- If a worktree has shared Git hooks but lacks `.pre-commit-config.yaml`, run
  `repo-setup` in that worktree before pushing.

## 7. Do Not Do These By Default

- Do not ask the user to choose an arbitrary worktree directory.
- Do not teach raw `git worktree add` as the issue or PR creation path.
- Do not edit `.gitignore` or the wrapper scripts unless the task is explicitly
  about those files.
