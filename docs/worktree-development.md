# Worktree Development

This document describes the current worktree workflow in this repository.
Recent commits and the checked-in scripts are the source of truth. If this page
and the code disagree, fix the page to match the code.

For the adoption decision behind the current tool stack, see
`docs/worktree-tool-evaluation.md`.

## 1. Stable entrypoints

- Use `issue-worktree-create <issue_number> [issue_number2 ...]` to start
  issue work.
- Use `pr-worktree-create <pr_number> [pr_number2 ...]` to start PR review.
- Use `z <keyword>` for the normal jump flow.
- Use `zi [keywords...]` for explicit interactive selection.
- Treat `z` and `zi` as the human-facing repo/worktree entrypoints in zsh.
- In current code, `z` and `zi` are custom wrappers from
  `config/zsh/jump.zsh`, not the default `zoxide` commands.
- Use `worktree-remove <branch-or-path>` to remove linked worktrees safely.
- Keep issue numbers and PR numbers as the primary human input. Do not replace
  them with free-form naming schemes.

## 2. Current layout and backend

- Managed worktrees live under repo-local `.worktrees/`. This comes from
  `config/vde/worktree/config.yml`, which sets `worktreeRoot: .worktrees`.
- `vde-worktree` is the shared backend. Current scripts rely on
  `vde-worktree path`, `vde-worktree get`, `vde-worktree switch`, and
  `vde-worktree list --json`.
- `.vde/` is intentional runtime state for `vde-worktree`.
- Treat sibling layouts such as `../dotfiles-issue-123` as legacy behavior.
  Current tooling is aligned around repo-root `.worktrees/`.

## 3. Current issue workflow

1. `issue-worktree-create` fetches `origin` first.
2. If the current branch is `main`, it runs `git pull --ff-only origin main`.
   Otherwise it keeps local `main` unchanged while another branch is checked
   out.
3. It can process multiple issue numbers in one run.
4. For each issue, it fetches `title`, `body`, and `comments` with
   `gh issue view --json title,body,comments`.
5. If a remote branch matching `origin/issue-<number>-*` already exists, it
   reuses that branch name.
6. Otherwise it tries to generate a short kebab-case slug with `claude`.
   If Claude is unavailable or returns nothing usable, it falls back to
   `issue-<number>`.
7. It resolves the worktree through `vde-worktree`:
   - existing managed path via `vde-worktree path`
   - remote branch via `vde-worktree get`
   - existing local branch or new local branch via `vde-worktree switch`
8. On a newly created worktree, it copies `.envrc` when present and runs
   `repo-setup` when available.
9. It adds the final worktree path to the `zoxide` database when `zoxide`
   exists.

## 4. Current PR review workflow

1. `pr-worktree-create` fetches `origin` first. If the current branch is
   `main`, it runs `git pull --ff-only origin main`. Otherwise it keeps local
   `main` unchanged while another branch is checked out.
2. It can process multiple PR numbers in one run.
3. For each PR, it reads `headRefName`, `headRepositoryOwner`,
   `headRepository`, and `isCrossRepository` with `gh pr view`.
4. If the PR comes from another repository, it fetches that head branch
   directly from `https://github.com/<owner>/<repo>.git`. Otherwise it fetches
   the head branch from `origin`.
5. It derives a local review branch name as
   `pr-<number>-<headRefName with slashes replaced by dashes>`.
6. It checks for an existing managed worktree path with
   `vde-worktree path "<derived-local-branch>"`.
7. When no managed worktree exists yet, it fetches the PR head directly into
   that local review branch and reports whether the local review branch was
   created or refreshed.
8. It resolves the review worktree with `vde-worktree switch
   "<derived-local-branch>"`.
9. On a newly created worktree, it copies `.envrc` when present and runs
   `repo-setup` when available.
10. It adds the final worktree path to the `zoxide` database when `zoxide`
    exists.

## 5. Current re-entry flow

1. `ghq + fzf` is still the explicit repository browser when the user wants to
   choose a repository first.
2. For one-step repo or worktree entry, use `z` or `zi`.
3. `zi [keywords...]` merges three candidate sources:
   - `zoxide query --list --score`
   - `ghq list -p`
   - managed worktree paths from `vde-worktree list --json`
4. Worktree discovery is repo-aware. The zsh helper asks each `ghq` repository
   that has `config/vde/worktree/config.yml` for `vde-worktree list --json`
   instead of scanning `.worktrees/` directly.
5. `zi` shows `score`, `source`, and `path` columns in `fzf`, keeps first-seen
   path order, and preserves `zoxide` scores when available.
6. `z` with no arguments opens `zi`.
7. `z -` still means `cd -`.
8. `z <directory>` jumps directly to that directory.
9. `z <keyword>` first tries `zoxide query --exclude "$PWD" -- "$keyword"`.
   When that direct lookup fails, it falls back to `zi <keyword>`.
10. Inside tmux, `z` and `zi` resolve the selected path's git root when
    available, fall back to the selected path otherwise, derive a session name
    from that resolved path, create the session when missing, and switch the
    tmux client to it.
11. Outside tmux, `z` and `zi` change directory through the wrapper functions.
12. `zeno-ghq-cd` still exists through the zeno key binding. Its tmux post-hook
    renames sessions from the selected path. For worktree paths under
    `/.worktrees/`, the session name uses the repository name plus the full
    worktree directory name with dots replaced by dashes.

## 6. How `vde-worktree` fits

- `vde-worktree` is the shared backend, the generic inspection tool, and the
  canonical read model for managed worktree paths.
- `z` and `zi` are the human-facing re-entry layer in zsh.
- Inside tmux, `z` and `zi` use plain tmux session lookup/create/switch logic
  from `config/zsh/jump.zsh`.
- Their merged candidate set is built from the current `zoxide` database,
  `ghq list -p`, and managed worktree paths from `vde-worktree list --json`.
- In this repository, current scripts actively use `list --json`, `path`,
  `get`, and `switch`.
- Do not use `vde-worktree` as the primary issue or PR entrypoint here.
- Do not use `vde-worktree` alone as the outermost global selector from an
  arbitrary directory.
- Do not teach `extract`, `absorb`, `unabsorb`, `adopt`, or `gone` as normal
  flow commands for this repository.

## 7. Removal and repository hygiene

- Keep linked worktrees and tool state under repo-local paths such as
  `.worktrees/` and `.vde/`.
- Treat `.vde/` as intentional `vde-worktree` runtime state, not as a tracked
  repository file tree.
- `worktree-remove` prefers managed branch names such as `issue-123-...` and
  `pr-456-...`, then repo-local `.worktrees/...` or absolute linked-worktree
  paths. ghq-relative paths are fallback only when they already point at an
  existing linked worktree.
- `worktree-remove` only removes linked worktrees (`.git` is a file), not
  regular repositories.
- It resolves the target branch, runs `vde-worktree init` on demand from the
  main repository, then deletes through `vde-worktree del`.
- That managed delete path intentionally keeps Git's dirty-worktree refusal
  from `#128`, but still allows normal issue/PR cleanup without requiring the
  branch to be merged or pushed first.
- When possible, it also removes the path from `zoxide`.
- Preserve `.envrc` copy behavior and `repo-setup` bootstrap when changing the
  backend or jump layer.
- Notification or daemon behavior is outside this document. That belongs to
  `tmux-a2a-postman`.

## 8. Recent changes reflected here

- Managed worktrees now live under repo-root `.worktrees/` through
  `config/vde/worktree/config.yml`.
- The zsh jump commands now live in `config/zsh/jump.zsh` and are sourced from
  `nix/home-manager/modules/zsh.nix`.
- `zi` now shows merged `zoxide` / `ghq` / `worktree` rows with score and
  source metadata.
- tmux worktree session naming now uses the full worktree directory name with
  dots normalized to dashes.
- Off-main issue and PR flows now keep local `main` unchanged instead of
  rewriting it in place.
- PR review now supports cross-repository heads by fetching from the PR source
  repository directly.
- `worktree-remove` now relies on Git's safe default refusal for dirty
  worktrees instead of forcing deletion.
- The old “approved target after migration” framing was removed from this page
  because the current code and recent commits are the source of truth.

## 9. Related files

- `bin/issue-worktree-create`
- `bin/pr-worktree-create`
- `config/zsh/jump.zsh` for the zsh jump flow and tmux session switching
- `config/zsh/zinit.zsh`
- `bin/worktree-remove`
- `config/vde/worktree/config.yml`
- `nix/home-manager/modules/zsh.nix`
- `docs/dotfiles-operating-concepts.md`
- `docs/worktree-tool-evaluation.md`
