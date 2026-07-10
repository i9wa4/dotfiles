# Worktree Development

This document describes the current worktree workflow in this repository.
Recent commits and the checked-in scripts are the source of truth. If this page
and the code disagree, fix the page to match the code.

For the overall concept and day-to-day practice, see
`skills/dotfiles/references/worktree-development-overview.md`.

For the adoption decision behind the current tool stack, see
the worktree-tool evaluation decision record (private vault).

## 1. Stable entrypoints

- For implementation work, create or choose a GitHub issue before editing, then
  run the issue worktree command and develop inside that linked worktree.
- Use `issue-worktree-create [--allow-direnv|--no-allow-direnv] <issue_number>
  [issue_number2 ...]` to start issue work.
- Use `pr-worktree-create [--allow-direnv] <pr_number> [pr_number2 ...]` to
  start PR review.
- For deliberately no-issue branch work, create a dedicated worktree under
  `.worktrees/` with native `git worktree add` before editing or committing.
- Use `worktree-status` from a repository to list every registered worktree for
  that repo. It is read-only; for worktrees matching this repo's issue/PR
  naming rules, it also resolves GitHub issue or PR state.
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
7. Existing same-name remote issue branches are configured as upstream. New
   local issue branches are created from the currently checked-out branch in the
   invoking checkout. Git resolves that invoking checkout from the current
   working directory, so running the command from a subdirectory still uses that
   checkout's root and current branch. Running it from inside an existing linked
   worktree uses that linked worktree's root and current branch, and any new
   issue worktree is created under that linked worktree's own `.worktrees/`
   directory. Run the command from the checkout whose branch and managed
   worktree root you intend to use. The wrapper enforces the issue branch
   upstream invariant after branch preparation: a branch may track
   `origin/<same-branch-name>` only when that remote branch exists; otherwise it
   starts without an upstream. If local Git configuration or a stale branch
   setting makes a new or reused local issue branch track `origin/main`,
   `origin/dev`, or another non-matching upstream, the wrapper clears that
   upstream before reporting the worktree ready. First publication through
   lazygit is the expected happy path when lazygit publishes to `origin` with
   the same branch name. The equivalent command-line shape is:
   `git push --set-upstream origin HEAD:refs/heads/<same-branch-name>`.
8. It resolves an existing branch worktree with `git worktree list
   --porcelain`. If no worktree exists, it creates one under `.worktrees/`
   with `git worktree add`. If the worktree already exists, re-running the
   command can remediate a missing `direnv allow` only when invoked from a
   distinct source checkout and the existing worktree `.envrc` still matches
   that source checkout `.envrc`; otherwise review the worktree file and run
   `repo-setup --allow-direnv` manually. Re-running from inside the issue
   worktree itself does not make that branch-owned `.envrc` trusted.
9. On a newly created worktree, it copies the source checkout's `.envrc` when
   present and the checked-out issue branch did not already provide `.envrc`,
   including for non-Nix repositories, and runs `repo-setup` when available.
   `repo-setup` attempts to install the repo devshell hooks and generated
   `.pre-commit-config.yaml` by default. Newly created issue worktrees allow a
   copied source-checkout `.envrc` by default and evaluate it once with
   `direnv exec <worktree-root> true`. If no `.envrc` exists and the worktree
   has `flake.nix`, default setup lets `repo-setup` create, allow, and
   evaluate the generated `use flake` fallback once. Use
   `issue-worktree-create --no-allow-direnv` to copy or generate `.envrc`
   without allowing it. If the issue branch already provides `.envrc`, the file
   is left unchanged and default setup does not allow it; review the file and
   run `repo-setup --allow-direnv` manually or pass `--allow-direnv`
   explicitly. For any other pre-existing `.envrc`, run
   `repo-setup --allow-direnv` only after reviewing the file. If the one-shot
   direnv load, Nix, or devshell setup fails, `repo-setup` warns and continues;
   re-run `repo-setup` or enter the devshell before pushing so
   `.pre-commit-config.yaml` is generated.
10. It adds the final worktree path to the `zoxide` database when `zoxide`
   exists.

Before asking a human to publish an issue branch, verify that the current
branch is the intended feature branch, that any existing upstream is either
absent or `origin/<same-branch-name>`, and that the remote destination is
neither `refs/heads/main` nor `refs/heads/dev`.

```sh
git branch --show-current
git status --short --branch
git rev-parse --abbrev-ref --symbolic-full-name @{u}
```

For a brand-new local issue branch, the upstream command should fail with "no
upstream configured" until first publication. In lazygit, check the branch panel
or status header before publishing: the branch should show no upstream, or it
should show `origin/<same-branch-name>` for an already existing remote issue
branch.

Local Git config is only a safety default, not a remote trust boundary. Protect
shared remote branches such as `main` and `dev` with GitHub rulesets or branch
protection so direct pushes to those refs are blocked or require the reviewed
path.

Before creating a PR, verify that `origin/<feature-branch>` exists, the PR base
is the intended base branch, and the PR head is the feature branch. Do not
create a PR from an unverified local-only branch or mismatched base/head pair.

## 4. Current no-issue branch workflow

Use this flow only when there is deliberately no issue or PR number for the
task. Small docs-only and single-line changes still need a dedicated worktree if
they may become commits.

For a new no-issue branch:

```sh
branch_name=<short-branch-name>
git worktree add -b "$branch_name" ".worktrees/$branch_name" main
cd ".worktrees/$branch_name"
pwd
git branch --show-current
git status --short --branch
```

For an existing branch that is not currently attached to a worktree:

```sh
branch_name=<existing-branch-name>
git worktree add ".worktrees/$branch_name" "$branch_name"
cd ".worktrees/$branch_name"
pwd
git branch --show-current
git status --short --branch
```

Do not use this native branch flow when an issue or PR number exists. Use
`issue-worktree-create` or `pr-worktree-create` instead so branch naming,
upstream safety, `.envrc` handling, `repo-setup`, and zoxide registration stay
consistent.

## 5. Current PR review workflow

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
10. On a newly created worktree, it copies the source checkout's `.envrc` when
    present, including for non-Nix repositories, and runs `repo-setup` when
    available. `repo-setup` attempts to install the repo devshell hooks and
    generated `.pre-commit-config.yaml` by default. If no `.envrc` was copied
    and the checkout has `flake.nix`, the default PR review path creates
    `use flake` but does not run `direnv allow`; pass `--allow-direnv` when
    creating the worktree only after reviewing the PR branch `.envrc` and
    `flake.nix`. When `.envrc` is explicitly allowed, `repo-setup` evaluates it
    once with `direnv exec <worktree-root> true`. If the one-shot direnv load,
    Nix, or devshell setup fails, `repo-setup` warns and continues; re-run
    `repo-setup` or enter the devshell before pushing so
    `.pre-commit-config.yaml` is generated.
11. It adds the final worktree path to the `zoxide` database when `zoxide`
    exists.
12. If any requested PR is invalid, skipped, refused, or otherwise fails, the
    command exits nonzero and does not print the all-ready success message.

## 6. Current re-entry flow

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

## 7. How Native Worktree Support Fits

- `git worktree` is the backend and canonical read model for managed worktree
  paths.
- `z` and `zi` are zoxide-first navigation wrappers in zsh.
- Inside tmux, `z` and `zi` stay in the current pane and change the shell's
  working directory like normal `cd`.
- Their merged candidate set is built from the current `zoxide` database and
  `ghq list -p`.
- In this repository, current scripts actively use `git worktree list
  --porcelain` and `git worktree add`. Removal is manual with native
  `git worktree remove` after inspection.
- Do not use a generic worktree package as the primary issue or PR entrypoint
  here.
- Native `git worktree add` is the documented fallback only for deliberately
  no-issue branch work.
- Use `git worktree list --porcelain` and `worktree-status` when
  inspecting stale linked worktrees.

## 8. Removal and repository hygiene

- Keep linked worktrees under repo-local `.worktrees/`.
- Inspect cleanup candidates with `worktree-status` or
  `git worktree list --porcelain`.
- For cleanup inspection in the current repository, run `worktree-status`. It
  lists every registered worktree, including the primary checkout, with issue
  state, PR state, local worktree flags, dirty state, upstream state, branch,
  HEAD, and path. It only calls GitHub when an issue or PR number can be derived
  from the managed naming rules; non-matching worktrees keep issue/PR fields as
  `-`. It does not delete anything.
- Treat clean merged `pr-*` worktrees as normal deletion candidates.
- Treat clean `issue-*` worktrees as deletion candidates only after confirming
  the issue is closed and the branch is merged or otherwise obsolete.
- Delete confirmed linked worktrees manually with `git worktree remove` after
  the same clean, unlocked, merged checks.
- If a path was added to zoxide manually and still appears after deletion,
  remove it with `zoxide remove <path>`.
- Preserve copy-first `.envrc` behavior and `repo-setup` bootstrap when
  changing the backend or jump layer. Worktrees copy the source checkout's
  `.envrc` only when the new worktree does not already have one. Newly created
  issue worktrees allow and evaluate the copied file by default and also allow
  and evaluate a generated fallback file when no `.envrc` already exists and
  the checkout has `flake.nix`; use `--no-allow-direnv` to opt out.
  Issue-branch-provided
  `.envrc` files are left unchanged, and PR review invocations must preserve
  explicit authorization because the checked out branch controls
  review-relevant code such as `flake.nix`; use `--allow-direnv` only when the
  file and branch have been reviewed.
- If a linked worktree reports `No .pre-commit-config.yaml file was found`,
  run `repo-setup` from that worktree. This attempts to install the devshell
  hooks and the generated per-worktree pre-commit config; if Nix or devshell
  setup fails, fix that failure and re-run `repo-setup` or enter the devshell
  before pushing.
- Notification or daemon behavior is outside this document. That belongs to
  `tmux-a2a-postman`.

## 9. Recent changes reflected here

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
- `worktree-status` now provides a read-only inventory for every worktree
  registered to the current repository, plus issue/PR state for worktrees that
  match the repo's naming rules.
- Worktree scripts now use native `git worktree` commands directly; the
  npm-managed worktree backend package was removed.
- No-issue branch work now has an explicit native `git worktree add` flow so
  agents do not treat small changes as permission to commit from the main
  checkout.
- The old “approved target after migration” framing was removed from this page
  because the current code and recent commits are the source of truth.

## 10. Related files

- `scripts/bin/issue-worktree-create`
- `scripts/bin/pr-worktree-create`
- `scripts/bin/worktree-status`
- `config/zsh/zoxide.zsh` for the zsh jump flow
- `config/zsh/zinit.zsh`
- `nix/home-manager/modules/zsh.nix`
- `nix/home-manager/modules/pnpm.nix`
- `skills/dotfiles/references/operating-concepts.md`
- `skills/dotfiles/references/worktree-development-overview.md`
- the worktree-tool evaluation decision record (private vault)
