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
- Use `worktree-remove` from a repository to list that repo's managed
  worktrees under `.worktrees/`, choose one with `fzf`, type `yes`, and delete
  it through `git worktree remove`.
- Use `z <keyword>` for the normal zoxide-backed jump flow.
- Use `zi [keywords...]` for explicit interactive selection.
- Treat `z` and `zi` as shell-local navigation helpers that `cd` the current
  shell into a selected repository or worktree path.
- In current code, `z` and `zi` are custom wrappers from
  `config/zsh/zoxide.zsh`, not the default `zoxide` commands.
- Keep issue numbers and PR numbers as the primary human input. Do not replace
  them with free-form naming schemes.

## 2. Current layout and backend

- Managed worktrees live under repo-local `.worktrees/`.
- The checked-in wrappers use native `git worktree` commands directly.
- There is no separate worktree backend package or repo-local backend state.
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
5. If `origin/issue-<number>` or a remote branch matching
   `origin/issue-<number>-*` already exists, it reuses that branch name.
6. Otherwise it tries to generate a short kebab-case slug with `claude`.
   If Claude is unavailable or returns nothing usable, it falls back to
   `issue-<number>`.
7. Existing remote issue branches are configured as upstream. New local issue
   branches rely on `push.autoSetupRemote=true`, so the first plain `git push`
   creates `origin/<branch>` and records upstream.
8. It resolves an existing branch worktree with `git worktree list
   --porcelain`. If no worktree exists, it creates one under `.worktrees/`
   with `git worktree add`.
9. On a newly created worktree, it copies `.envrc` when present and runs
   `repo-setup` when available.
10. It adds the final worktree path to the `zoxide` database when `zoxide`
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
5. It keeps the local review branch name equal to the PR head branch name.
6. It derives the worktree directory name as
   `.worktrees/pr-<number>-<headRefName with slashes replaced by dashes>`.
7. It checks for an existing worktree attached to the PR head branch.
8. It fetches the PR head into a remote-tracking branch and sets the local
   review branch upstream to the PR source branch, so `git pull` works from the
   review worktree. If the local review branch already exists, it
   fast-forwards that branch to the freshly fetched PR head when safe. If the
   local branch is ahead of or diverged from the PR head, it refuses to rewrite
   the branch automatically.
9. It creates the review worktree at the derived PR directory path when needed.
10. On a newly created worktree, it copies `.envrc` when present and runs
    `repo-setup` when available.
11. It adds the final worktree path to the `zoxide` database when `zoxide`
    exists.
12. If any requested PR is invalid, skipped, refused, or otherwise fails, the
    command exits nonzero and does not print the all-ready success message.

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

## 6. How Native Worktree Support Fits

- `git worktree` is the backend and canonical read model for managed worktree
  paths.
- `z` and `zi` are zoxide-first navigation wrappers in zsh.
- Inside tmux, `z` and `zi` stay in the current pane and change the shell's
  working directory like normal `cd`.
- Their merged candidate set is built from the current `zoxide` database and
  `ghq list -p`.
- In this repository, current scripts actively use `git worktree list
  --porcelain`, `git worktree add`, and `git worktree remove`.
- Do not use a generic worktree package as the primary issue or PR entrypoint
  here.
- Use `git worktree list --porcelain` and `worktree-remove` when
  inspecting stale linked worktrees.

## 7. Removal and repository hygiene

- Keep linked worktrees under repo-local `.worktrees/`.
- Inspect cleanup candidates with `worktree-remove` or
  `git worktree list --porcelain`.
- For interactive deletion in the current repository, run `worktree-remove`.
  It lists only secondary managed worktrees under the repo's `.worktrees/`,
  categorizes candidates as issue-origin, PR-origin, or miscellaneous, shows
  fzf preview context for issue/PR status and branch upstream tracking when
  detectable, requires typing `yes`, and removes clean, unlocked, merged branch
  worktrees with `git worktree remove` plus local branch deletion.
- Treat clean merged `pr-*` worktrees as normal deletion candidates.
- Treat clean `issue-*` worktrees as deletion candidates only after confirming
  the issue is closed and the branch is merged or otherwise obsolete.
- Delete confirmed linked worktrees with `worktree-remove` or
  `git worktree remove` after the same clean, unlocked, merged checks.
- If a path was added to zoxide manually and still appears after deletion,
  remove it with `zoxide remove <path>`.
- Preserve `.envrc` copy behavior and `repo-setup` bootstrap when changing the
  backend or jump layer.
- Notification or daemon behavior is outside this document. That belongs to
  `tmux-a2a-postman`.

## 8. Recent changes reflected here

- Managed worktrees live under repo-root `.worktrees/`.
- The zsh jump commands now live in `config/zsh/zoxide.zsh` and are sourced from
  `nix/home-manager/modules/zsh.nix`.
- `zi` now shows zoxide paths plus missing ghq repositories as plain path rows.
- `z` and `zi` now change the current shell directory even inside tmux instead
  of switching tmux sessions.
- Off-main issue and PR flows now keep local `main` unchanged instead of
  rewriting it in place.
- PR review now supports cross-repository heads by fetching from the PR source
  repository directly.
- `worktree-remove` now provides a repo-root `.worktrees/` `fzf` selector for
  confirmed single-worktree deletion with issue, PR, and miscellaneous preview
  context.
- Worktree scripts now use native `git worktree` commands directly; the
  npm-managed worktree backend package was removed.
- The old “approved target after migration” framing was removed from this page
  because the current code and recent commits are the source of truth.

## 9. Related files

- `bin/issue-worktree-create`
- `bin/pr-worktree-create`
- `bin/worktree-remove`
- `config/zsh/zoxide.zsh` for the zsh jump flow
- `config/zsh/zinit.zsh`
- `nix/home-manager/modules/zsh.nix`
- `nix/home-manager/modules/npm.nix`
- `docs/dotfiles-operating-concepts.md`
- `docs/worktree-tool-evaluation.md`
