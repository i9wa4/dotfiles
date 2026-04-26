---
name: using-git-worktrees
description: |
  User-level git worktree workflow for isolated workspaces. Use when creating
  issue or PR worktrees, re-entering with `z` or `zi`, inspecting worktree
  status or path with `vde-worktree`, or cleaning up linked worktrees with
  `worktree-remove`. In this repo, prefer `issue-worktree-create` and
  `pr-worktree-create` as the primary entrypoints.
---

# Using Git Worktrees

Use this skill to work in an isolated workspace without guessing the repo's
entrypoint.

## 1. Core Defaults

- Prefer repo wrappers before generic `git worktree` or `vde-worktree`
  creation flows.
- Treat `config/vde/worktree/config.yml` as the local worktree policy source of
  truth.
- Assume the managed root is `.worktrees`, even if generic tool help mentions a
  different default.
- Report the final worktree path and branch in handoff or status messages.
- Keep this skill focused on workspace isolation and inspection, not runtime
  activation or Nix switching.

## 2. Primary Repo Flows

### Issue execution

- Run `issue-worktree-create <issue_number>` from the repo.
- Expect it to:
  - fetch `origin`
  - refresh `main`
  - reuse an existing matching branch when present
  - create a new linked worktree when needed
  - copy `.envrc` when available
  - run `repo-setup` when available

### PR review

- Run `pr-worktree-create <pr_number>` from the repo.
- Expect it to:
  - fetch `origin`
  - refresh `main`
  - resolve the PR head branch from GitHub
  - create or reuse a linked review worktree
  - copy `.envrc` when available
  - run `repo-setup` when available

### Cleanup

- Run `worktree-remove <path>` for linked-worktree cleanup.
- Accepted path styles:
  - ghq-style path
  - absolute path
  - relative path
- Expect it to remove only linked worktrees, not a regular repository clone.

## 3. Supporting Generic Tooling

Use `vde-worktree` only as supporting generic tooling after checking whether the
wrapper flow already covers the task.

- Inspect all worktrees:
  - `vde-worktree list --json`
- Inspect one worktree:
  - `vde-worktree status [branch] --json`
- Resolve a branch to its absolute path:
  - `vde-worktree path <branch> [--json]`
- Re-enter a linked worktree or repo through the zoxide wrapper flow:
  - `z <keyword>`
  - `zi [keywords...]`
- Pick a worktree path directly from the generic backend when needed:
  - `cd "$(vde-worktree cd)"`
- Reuse or create a branch worktree as a generic fallback:
  - `vde-worktree switch <branch>`

Do not use `vde-worktree` as the primary issue or PR entrypoint in this repo.
Do not use raw `zoxide` alone as the outermost worktree selector here; use the
repo `z` or `zi` wrapper functions that keep navigation in the current shell.

## 4. Baseline Verification

After entering the chosen worktree, run the cheapest checks that prove you are
in the right place before changing files.

- `pwd`
- `git branch --show-current`
- `git status --short`

Use one of these when the lane needs broader worktree visibility:

- `git worktree list --porcelain`
- `vde-worktree list --json`

## 5. Repo Fit Notes

- This repo already exposes cleanup ergonomics through shell snippets, so keep
  cleanup guidance aligned with `worktree-remove`.
- The repo may contain detached linked worktrees, so do not assume every linked
  worktree is a simple branch-only case.
- If the task is actually about changing worktree scripts or config, read those
  files in full and treat that as a code-change task, not a normal use of this
  skill.

## 6. Do Not Do These By Default

- Do not ask the user to choose an arbitrary worktree directory.
- Do not teach or rely on `vde-worktree extract`, `absorb`, `unabsorb`,
  `adopt`, or `gone` as part of the normal repo flow.
- Do not edit `.gitignore`, `config/vde/worktree/config.yml`, or the wrapper
  scripts unless the task is explicitly about those files.
