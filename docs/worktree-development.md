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
- Use `worktree-cleanup-merged` to list merged cleanup candidates across ghq
  repositories and delete them only after typing `yes`.
- Use `z <keyword>` for the normal zoxide-backed jump flow.
- Use `zi [keywords...]` for explicit interactive selection.
- Treat `z` and `zi` as shell-local navigation helpers that `cd` the current
  shell into a selected repository or worktree path.
- In current code, `z` and `zi` are custom wrappers from
  `config/zsh/zoxide.zsh`, not the default `zoxide` commands.
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
4. If the PR comes from another repository, it adds or refreshes a PR-specific
   remote pointing at `https://github.com/<owner>/<repo>.git`. Otherwise it
   uses `origin`.
5. It derives a local review branch name as
   `pr-<number>-<headRefName with slashes replaced by dashes>`.
6. It checks for an existing managed worktree path with
   `vde-worktree path "<derived-local-branch>"`.
7. It fetches the PR head into a remote-tracking branch and sets the local
   review branch upstream to the PR source branch, so `git pull` works from the
   review worktree.
8. It resolves the review worktree with `vde-worktree switch
   "<derived-local-branch>"`.
9. On a newly created worktree, it copies `.envrc` when present and runs
   `repo-setup` when available.
10. It adds the final worktree path to the `zoxide` database when `zoxide`
    exists.

## 5. Current re-entry flow

1. `ghq + fzf` is still the explicit repository browser when the user wants to
   choose a repository first.
2. For one-step navigation into a repo or worktree path, use `z` or `zi`.
3. `zi [keywords...]` merges two candidate sources:
   - `zoxide query --list`
   - `ghq list -p`
4. Worktree paths appear through zoxide because the worktree creation commands
   add them with `zoxide add`.
5. `zi` shows paths in `fzf`, preserving zoxide order first and appending ghq
   repositories that were not already present.
6. `z` with no arguments opens `zi`.
7. `z -` still means `cd -`.
8. `z <directory>` jumps directly to that directory.
9. `z <keyword>` first tries `zoxide query --exclude "$PWD" -- "$keyword"`.
   When that direct lookup fails, it falls back to `zi <keyword>`.
10. Inside tmux, `z` and `zi` now behave like normal shell directory changes
    and `cd` the current pane into the selected path.
11. Outside tmux, `z` and `zi` also change directory through the wrapper
    functions.
12. Ctrl-G uses the zoxide-side `zoxide-zi-widget`. It runs `zi`, changes the
    current shell directory, and renames tmux sessions from the selected path.
    For worktree paths under `/.worktrees/`, the session name uses the
    repository name plus the full worktree directory name with dots replaced by
    dashes.

## 6. How `vde-worktree` fits

- `vde-worktree` is the shared backend, the generic inspection tool, and the
  canonical read model for managed worktree paths.
- `z` and `zi` are zoxide-first navigation wrappers in zsh.
- Inside tmux, `z` and `zi` stay in the current pane and change the shell's
  working directory like normal `cd`.
- Their merged candidate set is built from the current `zoxide` database and
  `ghq list -p`.
- In this repository, current scripts actively use `list --json`, `path`,
  `get`, and `switch`.
- Do not use `vde-worktree` as the primary issue or PR entrypoint here.
- Do not use `vde-worktree` alone as the outermost global selector from an
  arbitrary directory.
- Use `vde-worktree list --json`, `status`, and `gone --json` as inspection
  helpers before deleting stale linked worktrees.
- Do not teach `extract`, `absorb`, `unabsorb`, or `adopt` as normal flow
  commands for this repository.

## 7. Removal and repository hygiene

- Keep linked worktrees and tool state under repo-local paths such as
  `.worktrees/` and `.vde/`.
- Treat `.vde/` as intentional `vde-worktree` runtime state, not as a tracked
  repository file tree.
- Inspect cleanup candidates with `vde-worktree list --json`,
  `vde-worktree status <branch> --json`, and `vde-worktree gone --json`.
- For host-wide cleanup, run `worktree-cleanup-merged`. It scans `ghq list -p`,
  collects candidates with `vde-worktree gone --json`, shows the full list, and
  deletes only after explicit confirmation.
- Treat clean merged `pr-*` worktrees as normal deletion candidates.
- Treat clean `issue-*` worktrees as deletion candidates only after confirming
  the issue is closed and the branch is merged or otherwise obsolete.
- Delete confirmed linked worktrees with `vde-worktree del <branch>`.
- If a path was added to zoxide manually and still appears after deletion,
  remove it with `zoxide remove <path>`.
- Preserve `.envrc` copy behavior and `repo-setup` bootstrap when changing the
  backend or jump layer.
- Notification or daemon behavior is outside this document. That belongs to
  `tmux-a2a-postman`.

## 8. Recent changes reflected here

- Managed worktrees now live under repo-root `.worktrees/` through
  `config/vde/worktree/config.yml`.
- The zsh jump commands now live in `config/zsh/zoxide.zsh` and are sourced from
  `nix/home-manager/modules/zsh.nix`.
- `zi` now shows zoxide paths plus missing ghq repositories as plain path rows.
- `z` and `zi` now change the current shell directory even inside tmux instead
  of switching tmux sessions.
- Off-main issue and PR flows now keep local `main` unchanged instead of
  rewriting it in place.
- PR review now supports cross-repository heads by fetching from the PR source
  repository directly.
- The standalone cleanup wrapper was removed; cleanup now uses explicit
  `vde-worktree` inspection and deletion commands.
- The old “approved target after migration” framing was removed from this page
  because the current code and recent commits are the source of truth.

## 9. Related files

- `bin/issue-worktree-create`
- `bin/pr-worktree-create`
- `bin/worktree-cleanup-merged`
- `config/zsh/zoxide.zsh` for the zsh jump flow
- `config/zsh/zinit.zsh`
- `config/vde/worktree/config.yml`
- `nix/home-manager/modules/zsh.nix`
- `docs/dotfiles-operating-concepts.md`
- `docs/worktree-tool-evaluation.md`
