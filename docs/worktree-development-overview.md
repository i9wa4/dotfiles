# Worktree Development Overview

This document summarizes the overall worktree-based development approach used
in this repository. For command-level details, see
`docs/worktree-development.md`.

## 1. Core Idea

The main checkout stays as the stable base for repository maintenance, while
feature work, issue work, and PR review happen in linked worktrees under the
same repository. Each worktree has its own branch and working tree, so one task
can be edited, tested, paused, or reviewed without disturbing another task.

The approach is wrapper-first. Humans provide issue numbers or PR numbers, and
repo scripts translate those numbers into branches, worktree paths, bootstrap
steps, and navigation entries. Native `git worktree` remains the backend, but
the normal user interface is the repository's checked-in commands.

## 2. Operating Model

The workflow has five recurring phases:

1. Start from a task identifier.
   For implementation work, create or choose the GitHub issue first, then run
   `issue-worktree-create <issue_number>` and develop inside that issue
   worktree. Use `pr-worktree-create <pr_number>` for PR review.
2. Create or reuse a linked worktree.
   Managed worktrees live under repo-local `.worktrees/`, with branches and
   directory names derived from the issue or PR.
3. Bootstrap the task environment.
   New worktrees copy `.envrc` when available, run `repo-setup` when available,
   and register the final path with `zoxide`. `repo-setup` attempts to install
   the repo devshell hooks and generated per-worktree pre-commit config. If
   `.envrc` is missing in a flake checkout, `repo-setup` creates it with
   `use flake` and runs `direnv allow`. If Nix or devshell setup fails, it
   warns and continues; re-run `repo-setup` or enter the devshell before
   pushing so `.pre-commit-config.yaml` is generated. Allowing a pre-existing
   `.envrc` stays opt-in; pass `--allow-direnv` to the creation command only
   after reviewing the file.
4. Re-enter quickly.
   Use `z <keyword>`, `zi [keywords...]`, or Ctrl-G to jump back to a repo or
   worktree from normal shell use. Inside tmux, re-entry also keeps session
   naming aligned with the selected repo or worktree.
5. Clean up explicitly.
   Use `worktree-remove` to inspect managed worktrees, confirm deletion, and
   remove clean, unlocked, merged worktrees through native Git cleanup.

## 3. Why This Shape Works

The design keeps the boring parts boring and the policy parts reviewable.
Native Git owns the linked-checkout mechanics, while repo scripts own local
policy:

- issue and PR lookup through `gh`
- branch reuse and upstream tracking
- cross-repository PR review support
- `.envrc`, devshell hook, and `repo-setup` bootstrap, with automatic trust only
  for the generated `use flake` file and explicit review for pre-existing
  `.envrc`
- zoxide registration for fast re-entry
- tmux-aware session naming
- explicit cleanup checks before removal

That split keeps the workflow portable across machines without adding another
worktree backend package or hidden per-machine state.

## 4. Day-to-Day Practice

Keep the base checkout clean enough to launch and maintain worktrees. Do active
task edits inside the task worktree, not by stacking unrelated changes in the
base checkout.

Use issue and PR numbers as the stable human entrypoints. Avoid ad hoc branch
or directory naming when a repository wrapper already covers the task.

Use `z` and `zi` for re-entry instead of raw `zoxide` calls, because the repo
wrappers keep the current shell and tmux session state aligned.

Before removing a worktree, inspect the candidate through `worktree-remove` or
`git worktree list --porcelain`. Delete only when the worktree is clean,
unlocked, and merged or otherwise confirmed obsolete.

## 5. Related Files

- `docs/worktree-development.md`
- `docs/worktree-tool-evaluation.md`
- `bin/issue-worktree-create`
- `bin/pr-worktree-create`
- `bin/worktree-remove`
- `config/zsh/zoxide.zsh`
- `skills/agent-workspace/SKILL.md`
