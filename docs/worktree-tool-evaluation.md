# Worktree Tool Evaluation

This document records the repo decision for `#116`.

The current repository wrappers and checked-in config are the source of truth:

- `issue-worktree-create`
- `pr-worktree-create`
- `worktree-remove`
- `z` and `zi`

## 1. Current Repo Constraints

- Human entrypoints are issue and PR numbers, not free-form branch names.
- Managed worktrees live under repo-local `.worktrees/`.
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
  - cleanup is explicit and requires confirmation
  - dirty, locked, and unmerged branch worktrees are refused by
    `worktree-remove`
  - linked worktrees stay under repo-local `.worktrees/`

## 2. Evaluation

| Candidate                      | Installation Feasibility                                             | Workflow Fit                                                                                   | Safety Fit                                                                      | Complexity vs Benefit                                                 | Decision            |
| ------------------------------ | -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ------------------- |
| Native `git worktree` wrappers | Already available through Git. No extra Node/npm global is required. | Strong fit because issue, PR, cleanup, and navigation behavior already lives in repo wrappers. | Good fit when wrappers centralize clean, locked, merged, and path-scope checks. | Lowest moving parts and no shell-startup-adjacent package dependency. | Use as the backend. |
| Extra worktree CLI package     | Adds another global tool and a second worktree policy surface.       | Weak fit because the repo still needs the existing issue, PR, zoxide, and tmux wrappers.       | Depends on the package, but duplicates checks the wrappers can do directly.     | Extra dependency for behavior that is already covered locally.        | Do not adopt now.   |

## 3. Decision

- Keep the current architecture:
  - repo wrappers for issue and PR entry
  - `z` and `zi` for human re-entry
  - native `git worktree` commands as the backend
- Do not add a generic worktree CLI as the normal human interface.
- Keep `skills/agent-workspace/SKILL.md` as the canonical workspace skill for
  repo-local worktree policy because it preserves the wrapper-first policy.

## 4. Why This Decision Is Narrow

- Generic worktree tools are not bad tools. They are a poor primary fit here
  because this repo already has checked-in wrapper scripts, tmux-aware re-entry,
  and issue/PR-specific branch creation.
- The backend should stay boring. The behavior that matters belongs in the
  wrapper scripts where it can be reviewed with the rest of the dotfiles.

## 5. Revisit Triggers

Revisit this decision only if one of these becomes true:

- the wrapper scripts are removed and the repo wants direct tool usage as the
  normal human interface
- the repo wants one generic multi-repo worktree CLI instead of wrapper-first
  issue and PR flows
- native Git lacks a safety or inspection feature that the wrappers cannot
  reasonably provide

## 6. Related Files

- `docs/worktree-development.md`
- `bin/issue-worktree-create`
- `bin/pr-worktree-create`
- `bin/worktree-remove`
- `nix/home-manager/modules/npm.nix`
- `skills/agent-workspace/SKILL.md`
