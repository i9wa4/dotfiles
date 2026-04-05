# Worktree Development

This document describes the approved developer workflow direction for linked
worktrees in this repository. During the current migration, treat the current
scripts as the source of truth for live behavior and this page as the source of
truth for the approved target.

## 1. Stable entrypoints

- Use `issue-worktree-create <issue_number>` to start issue work.
- Use `pr-worktree-create <pr_number>` to start PR review.
- Use `zwt [keywords...]` to re-enter linked worktrees through the dedicated
  worktree zoxide database.
- Use `zwt list [keywords...]` to inspect the same keyword matches that
  `zwt path` and `zwt [keywords...]` can resolve, with related ghq repo roots
  shown above each managed worktree path.
- Use `worktree-remove <path>` to remove linked worktrees safely.
- Keep issue numbers and PR numbers as the primary human input. Do not replace
  them with free-form naming schemes.

## 2. Migration direction

- Today, `issue-worktree-create` and `pr-worktree-create` still create sibling
  worktrees outside the repo.
- Keep the wrapper commands above as the user-facing entrypoints.
- Move actual worktree creation and lookup under repo-root `.worktrees/`.
- Use shared backend logic so issue and PR flows stop duplicating creation,
  bootstrap, and lookup behavior.
- Keep the dedicated zoxide-backed re-entry command `zwt` aligned with
  `vde-worktree` so entry and re-entry stay in sync during the migration.
- Treat sibling-directory layouts such as `../dotfiles-issue-123` and
  `../dotfiles-pr-456` as legacy behavior. Do not extend that pattern in new
  tooling.

## 3. Approved target flow after Phase 1 migration

### 3.1. Issue execution

1. Run `issue-worktree-create <issue_number>` from the repository.
2. Reuse an existing issue branch when one already exists.
3. Otherwise create a branch that keeps the issue number. An AI-generated
   English kebab-case slug may be appended when available, but the number
   remains the anchor.
4. Create the worktree under `.worktrees/`.
5. Copy `.envrc` into the new worktree when the repo has one.
6. Run `repo-setup` in the new worktree when available.
7. Register or refresh the created path in the dedicated `zwt` zoxide database.

### 3.2. PR review

1. Run `pr-worktree-create <pr_number>` from the repository.
2. Check out the PR head branch in a managed worktree under `.worktrees/`.
3. Apply the same `.envrc` copy and `repo-setup` bootstrap as issue work.
4. Register or refresh the created path in the dedicated `zwt` zoxide database.
5. Re-enter the review worktree with `zwt`, or use `vde-worktree path`,
   `vde-worktree cd`, or `vde-worktree switch` as supporting tools during the
   migration.

### 3.3. Re-entry from outside the repo

1. Keep `ghq + fzf` as the explicit repo browser when the user wants deliberate
   repository selection first.
2. For one-step worktree re-entry, use `zwt` instead of raw `vde-worktree`
   from an arbitrary directory.
3. `zwt list [keywords...]` prints the same keyword matches that
   `zwt path [keywords...]` can resolve, with the related ghq repo root shown
   above each managed worktree path for quick inspection.
4. `zwt` and `zwt path` refresh a dedicated worktree-only zoxide database from
   `vde-worktree list --json` across `ghq` repositories before selection.
5. Inside tmux, `zwt` opens the selected path with
   `vtm project switch "$path"`.
6. Outside tmux, `zwt` changes directory to the selected path through the zsh
   wrapper function.
7. Do not scan `.worktrees/` or `.git/wt` directly. Keep `vde-worktree` as
   the worktree source of truth.

## 4. How `vde-worktree` fits

- `vde-worktree` is the shared backend, the generic inspection tool, and the
  canonical read model for managed worktree paths.
- `zwt` is the dedicated re-entry wrapper that refreshes a worktree-only
  zoxide database from that read model, and its `list` subcommand shows the
  same zoxide-backed matches as `zwt path` with related ghq repo roots above
  the managed worktree paths.
- In this repository, it supports `list`, `status`, `path`, `cd`, and
  `switch`.
- Do not use `vde-worktree` as the primary issue or PR entrypoint here.
- Do not use `vde-worktree` alone as the outermost global selector from an
  arbitrary directory.
- Do not teach `extract`, `absorb`, `unabsorb`, `adopt`, or `gone` as normal
  flow commands for this repository.

## 5. Repository hygiene

- Keep linked worktrees and tool state under repo-local paths such as
  `.worktrees/` and `.vde/`.
- Treat `.vde/` as intentional `vde-worktree` runtime state, not as a tracked
  repository file tree.
- Keep those paths out of normal Git noise with repo-local ignore or exclude
  rules during the migration.
- Preserve `.envrc` copy behavior and `repo-setup` bootstrap when changing the
  backend.
- Notification or daemon behavior is outside this document. That belongs to
  `tmux-a2a-postman`.

## 6. Related files

- `bin/issue-worktree-create`
- `bin/pr-worktree-create`
- `bin/zwt`
- `bin/worktree-remove`
- `config/vde/worktree/config.yml`
- `docs/dotfiles-operating-concepts.md`
