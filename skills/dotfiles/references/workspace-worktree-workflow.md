# Worktree Workflow

This is the sole operational entrypoint for worktree creation, reuse,
bootstrap, publication preparation and cleanup in this environment. The
[overview](worktree-development-overview.md) owns architecture and historical
context. Checked-in scripts remain the source of truth; correct stale prose
rather than changing working code to match it.

## 1. Choose the Entry and Verify Scope

- For implementation, create or choose the GitHub issue first, then use
  `issue-worktree-create`; for PR review use `pr-worktree-create`. Do not
  replace these with manual issue branches, raw `git worktree add`,
  `EnterWorktree` or another backend. Deliberate no-issue work has its own flow
  below.
- Even docs-only and one-line commit work uses a dedicated linked worktree.
  Keep unrelated changes out of the base checkout and report final path/branch
  in handoffs. Managed paths are under the invoking checkout's `.worktrees/`.
- Resolve the invoking checkout, current branch and intended base first. From
  `main`, both wrappers fetch and fast-forward `main` with `git pull --ff-only`;
  off-main they preserve local `main`. New issue branches start from the
  invoking checkout's current branch, including an explicitly intended stack.
  Invoking from a subdirectory resolves that checkout's root; invoking from a
  linked worktree uses that worktree's root and can create a nested
  `.worktrees/`. Do not assume every invocation starts from main or another
  checkout's root.
- Before edits, verify the returned worktree and intended branch/base:

  ```sh
  pwd
  git branch --show-current
  git status --short --branch
  git worktree list --porcelain
  ```

- An issue branch may track only an existing `origin/<same-branch-name>`.
  New local issue branches intentionally have no upstream before same-name
  publication. Stop with BLOCKED if it tracks `origin/main`, `origin/dev` or
  another non-matching upstream; do not push through that configuration.

## 2. Issue Implementation

From the checkout whose branch and managed root you intend to use:

```sh
issue-worktree-create [--allow-direnv|--no-allow-direnv] <issue_number> [issue_number2 ...]
```

The wrapper fetches origin and applies section 1's main/off-main behavior. For
each issue it reads title, body and comments with `gh issue view`, reuses
`origin/issue-<number>` when present or the first matching
`origin/issue-<number>-*`, and otherwise creates an issue branch from the
invoking branch. It optionally asks an available Codex CLI for a short
descriptive slug; if unavailable or unusable, it falls back to `issue-<number>`.
The executable script owns model/options; documentation does not select a model.

It locates existing branch worktrees via native `git worktree list --porcelain`,
creates a linked checkout when absent, and enforces the same-name upstream
invariant after preparation, clearing stale/unsafe upstreams. Reused same-name
remote branches get that upstream; new local branches do not inherit a base
upstream. Do not manually create a competing issue branch/worktree.

For new worktrees it preserves a branch-provided `.envrc`, otherwise copies the
source checkout's when available, including non-Nix repositories. It attempts
`repo-setup` when available, follows the trust rules in section 4, and registers
the final path with zoxide. For an existing worktree, default remediation may
allow its `.envrc` only from a distinct source checkout whose `.envrc` still
matches it. Invoking inside that issue worktree does not make its own file
trusted. Otherwise review it and explicitly use `--allow-direnv` or
`repo-setup --allow-direnv`; `--no-allow-direnv` opts out.

## 3. PR Review

```sh
pr-worktree-create [--allow-direnv] <pr_number> [pr_number2 ...]
```

After fetching and section 1's base handling, the wrapper reads PR head name,
repository owner/name and cross-repository status. For a cross-repository head,
it creates/refreshes a PR-specific remote targeting the actual source repo;
otherwise it uses origin. It fetches the PR head, keeps the local branch name
identical to the PR head and sets its upstream to that source branch.

The review directory is
`.worktrees/pr-<number>-<head-branch-with-slashes-replaced>/`. Existing branch
worktrees may be reused. An existing local review branch fast-forwards only
when safe; ahead/diverged branches are refused rather than rewritten. New
worktrees preserve branch `.envrc` or copy the source checkout's, attempt
`repo-setup` under section 4 and register the final path with zoxide.

PR review does not automatically allow `.envrc`. Use `--allow-direnv` only after
reviewing the branch-controlled file and `flake.nix`. If any requested PR is
invalid, skipped, refused or fails, the wrapper exits nonzero without the
all-ready success message. Do not treat a partial batch as complete.

## 4. Bootstrap and Envrc Trust

`repo-setup` attempts devshell hook installation and the generated per-worktree
`.pre-commit-config.yaml`. Source `.envrc` copying applies only when the
checked-out branch did not provide one. If no file exists and the checkout has
`flake.nix`, setup may generate the `use flake` fallback.

For newly created issue worktrees, copied source `.envrc` and generated
fallbacks are allowed by default and evaluated once with
`direnv exec <worktree-root> true`. `--no-allow-direnv` creates/prepares without
allowing them. Branch-provided files remain unchanged and are not implicitly
allowed. Existing issue remediation has the distinct-source/matching-file
restriction in section 2. PR review defaults also preserve explicit review
before allow. An explicit allowed file is loaded once, not merely marked allowed
without evaluation.

Nix, one-shot direnv loading or devshell failures warn and continue. Creation
success therefore does not prove hooks are ready. If hooks are missing or a
linked checkout reports no `.pre-commit-config.yaml`, repair the failure and
rerun `repo-setup` or enter the devshell in that worktree before publication.
Do not change the wrapper's trust policy, skip hooks or allow an unreviewed
branch file merely to make setup pass.

## 5. Deliberate No-Issue Work

Only when the task deliberately has no issue/PR identifier, create a dedicated
branch checkout before edits:

```sh
branch_name=<short-branch-name>
git worktree add -b "$branch_name" ".worktrees/$branch_name" main
cd ".worktrees/$branch_name"
```

Use a descriptive directory-safe name. If the branch already exists, attach it
instead of recreating it:

```sh
branch_name=<existing-branch-name>
git worktree add ".worktrees/$branch_name" "$branch_name"
cd ".worktrees/$branch_name"
```

Verify path/branch/status as in section 1. This native Git use does not replace
issue/PR wrappers when their identifiers exist.

## 6. Re-entry and Publication Preparation

Use `z <branch-or-keyword>`, `zi [keywords...]` or Ctrl-G for shell-local
re-entry. Do not use raw zoxide as the outer selector. The exact
navigation/session naming flow belongs to
[Agent Workspace](workspace-guidance.md#6-navigation-primitives).

Before publication, confirm the intended branch/upstream and current worktree
state. If an upstream exists, inspect ahead/behind with
`git rev-list --left-right --count HEAD...@{u}`. No-upstream is expected for a
new issue branch. First lazygit publication is appropriate only to origin with
the same branch name. The installed `dev-platform-workflow` Skill's
`references/github-workflow.md` section 5 alone owns exact publication refspec,
PR base/head verification and shared-branch protection; load it from its Skill
root rather than a guessed task-repository path.

## 7. Inspection and Explicit Cleanup

Use `worktree-status` to inspect every registered checkout for the current repo,
including primary and detached worktrees. It is read-only and reports local
flags, dirty/upstream state, branch, HEAD and path. It consults GitHub only when
issue/PR IDs can be derived from managed naming rules; other rows retain `-`.
Native `git worktree list --porcelain` is the canonical backend inspection view.

Confirm clean, unlocked, merged/obsolete state before manual `git worktree
remove`. Clean merged PR worktrees are candidates; issue worktrees additionally
need confirmation that the issue is closed and branch merged/obsolete. No
automatic deletion is authorized by this reference. If a manually registered
zoxide entry remains afterward, remove that confirmed obsolete entry with
`zoxide remove <path>`. Never assume every linked checkout is a simple branch.

Do not edit `.gitignore` or wrapper scripts unless the task concerns them. If
changing scripts/config, read the affected sources fully and treat it as code
work. Git-lock diagnosis belongs to Agent Workspace; workspace isolation cannot
be replaced by lock cleanup. Notification/daemon behavior belongs to Postman,
and runtime activation/Nix switching is outside worktree lifecycle guidance.

## 8. Source Owners

- `scripts/bin/issue-worktree-create`
- `scripts/bin/pr-worktree-create`
- `scripts/bin/worktree-status`
- `scripts/bin/repo-setup` and `scripts/lib/worktree-common.sh`
- `config/zsh/zoxide.zsh` for navigation, sourced by the zsh Nix module
