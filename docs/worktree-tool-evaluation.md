# Worktree Tool Evaluation

This document records the repo decision for `#116`.

The current repository wrappers and checked-in config are the source of truth:

- `issue-worktree-create`
- `pr-worktree-create`
- `z` and `zi`
- `config/vde/worktree/config.yml`

## 1. Current repo constraints

- Human entrypoints are issue and PR numbers, not free-form branch names.
- Managed worktrees live under repo-local `.worktrees/`.
- `vde-worktree` already exists as the backend and read model for managed
  worktrees.
- The repo already depends on wrapper behavior that generic tools do not
  provide by themselves:
  - `gh` issue and PR lookups
  - cross-repo PR fetch support
  - `.envrc` copy
  - `repo-setup`
  - `zoxide` registration
  - tmux re-entry through `z` and `zi`
- Safety defaults in current scripts are already opinionated:
  - off-main flows do not rewrite local `main`
  - cleanup is performed explicitly through `vde-worktree` inspection and
    deletion commands
  - linked worktrees stay under repo-local state paths

## 2. Evaluation

| Candidate           | Installation Feasibility                                              | Workflow Fit                                                                         | Safety Fit                                                                                 | Complexity vs Benefit                                                                 | Decision                       |
| ------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------- | ------------------------------ |
| `vde-worktree`      | Already installable in this repo today via `nix/home-manager/modules/npm.nix` global npm activation. Upstream requires Node.js 22+, pnpm 10+, and `fzf` for `cd`. | Strong fit as the backend. Current wrappers already use `vde-worktree path`, `get`, `switch`, and `list --json`. | Strong fit. Upstream exposes stable JSON, repo locking, hooks, and unsafe overrides that are explicit instead of implicit. | Low migration cost because the repo already runs on it. The remaining work is wrapper and doc polish, not backend replacement. | Keep as the backend.           |
| `git-wt`            | Feasible to install. It exists in `nixpkgs`, and upstream ships a Go binary plus Homebrew install path. | Weak fit as a primary tool here. Its shell integration wraps `git()`, while this repo already uses `issue-worktree-create`, `pr-worktree-create`, `z`, and `zi` as the human interface. | Good local safety defaults, but it does not provide the repo-specific issue/PR workflow, `gh` metadata fetch, or current `vde-worktree` state model by itself. | Medium to high migration cost for little user benefit because it would duplicate current wrapper behavior instead of replacing only one small gap. | Do not adopt now.              |
| `vw-worktree-ops` skill | No packaging cost by itself, but adopting it would add a second worktree policy surface next to the existing repo-local skill. | Weak fit as-is. It teaches direct `vw` operation, while this repo deliberately keeps repo wrappers as the primary entrypoints. | Good safety discipline, but broader than this repo wants. It teaches direct cleanup and generic maintenance flows that the local skill intentionally does not teach by default. | Extra cognitive load without solving a current repo problem. The local `using-git-worktrees` skill already matches this repo better. | Do not adopt as-is.            |

## 3. Decision

- Keep the current architecture:
  - repo wrappers for issue and PR entry
  - `z` and `zi` for human re-entry
  - `vde-worktree` as the backend and generic inspection tool
- Do not replace the current flow with `git-wt`.
- Do not import `vw-worktree-ops` as the primary skill for this repo.
- Keep `nix/home-manager/agents/skills/using-git-worktrees/SKILL.md` as the
  canonical repo-local skill because it preserves the wrapper-first policy.

## 4. Why this decision is narrow

- `git-wt` is not a bad tool. It is simply a poor primary fit for a repo that
  already has checked-in wrapper scripts, tmux-aware re-entry, and a live
  `vde-worktree` state model.
- `vde-worktree` is also not the human-facing interface here. The repo has
  already decided to put a small repo-specific layer on top of it.
- The upstream `vw-worktree-ops` skill contains useful ideas, especially JSON
  verification and lock awareness, but the repo should borrow ideas only when
  the checked-in wrappers expose those operations cleanly.

## 5. Revisit triggers

Revisit this decision only if one of these becomes true:

- the repo wants to remove npm-managed globals from the worktree stack
- the repo wants one generic multi-repo worktree CLI instead of wrapper-first
  issue and PR flows
- the wrapper scripts are removed and the repo wants direct tool usage as the
  normal human interface

## 6. Related files

- `docs/worktree-development.md`
- `bin/issue-worktree-create`
- `bin/pr-worktree-create`
- `config/vde/worktree/config.yml`
- `nix/home-manager/modules/npm.nix`
- `nix/home-manager/agents/skills/using-git-worktrees/SKILL.md`
