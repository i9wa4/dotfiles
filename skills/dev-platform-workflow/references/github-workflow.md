# GitHub Workflow

Detailed GitHub mechanics for this environment: `gh` usage, issue and PR
operations, branch publication, commit messages, and review comment style.

Implementation and review work happen in a dedicated worktree, never the main
checkout, even for docs-only or single-line changes. See
`skills/dotfiles/references/workspace-guidance.md` for the worktree creation
commands, the no-issue-branch fallback, and entrypoint restrictions.

## 1. gh CLI

- Use `gh` for GitHub information retrieval.
- Always fetch the full conversation (body plus comments) for issues and PRs.
- Cite issue and PR numbers with a `#` prefix, for example `#240`.

### 1.1. Review Modes and Isolation

- A read-only review uses `gh pr view` and `gh pr diff`; do not create a local
  checkout merely to inspect a PR.
- A review that runs tests, builds, or other commands uses a dedicated PR
  worktree created from the PR ref with `pr-worktree-create <pr_number>`.
  The reviewer uses and removes that worktree; never check out the shared main
  directory during a review.
- A request for review must say explicitly when the reviewer is expected to run
  tests, builds, or other commands, so the required worktree is unambiguous.
- A script that changes directory before a stateful command, such as
  `git checkout` or `rm`, must use `set -euo pipefail` or chain the directory
  change with `&&`. A failed `cd` must stop the script rather than allow a
  later command to run in the caller's directory.

### 1.2. GitHub Actions dependency lockfile

Dotfiles onboards both workflows to `.github/workflows/actions.lock`. This
machine-generated file records action commits and repository identities,
including transitive actions. Existing full-SHA `uses:` pins and the pinact
hook remain in place; the lockfile adds dependency coverage to that policy.
It does not lock reusable workflow calls (`jobs.<job>.uses`) or container
images, which still need their own SHA or digest pins.

Use the repository-pinned CLI, without installing or upgrading an extension:

```sh
# Check coverage offline, without credentials or file writes.
nix run '.#gh-actions-lock' -- --verify-local
# Check the locked commits and source identities through the GitHub API.
nix run '.#gh-actions-lock' -- --verify
# Generate/update after reviewing changes to workflow dependencies.
nix run '.#gh-actions-lock' -- --no-narrow
```

Network modes use the existing GitHub CLI authentication. CI supplies its
read-only job token. The same version is declared as a Home Manager `gh`
extension, so `gh actions-lock --no-narrow` is available after normal
human-owned activation. Running the Nix commands above requires no activation.

Update the normal full-SHA pins first, then generate with `--no-narrow`. This
keeps each lockfile key identical to its workflow's literal `uses:` reference
while recording the upstream tag and repository identity. Without this flag,
the generator can rewrite workflows to tags; subsequently restoring SHA pins
can leave a lockfile that the CLI accepts but GitHub rejects at job startup.
If pinact edits a workflow, restage it and regenerate the lockfile before the
next commit. Do not edit the lockfile by hand.

Expected `sha-as-ref` warnings do not invalidate verified SHA pins; inspect
actual errors rather than suppressing all output.

The pre-commit/Nix gate runs the upstream offline coverage check whenever a
workflow or `actions.lock` changes. The PR CI additionally runs `--verify` to
check upstream provenance; offline coverage alone does not establish it.
Dependabot's existing `github-actions` entry also updates the lockfile in its
dependency PRs; keep its current schedule, grouping and cooldown. Review those
diffs, and rerun the generator if dependency changes are made manually. Routine
checks never relock or accept moved references automatically.

Background: [the trial article][actions-lock-trial],
[GitHub's dependency lockfile contract][actions-lock-contract], and
[the pinned CLI documentation][actions-lock-cli].

[actions-lock-trial]: https://zenn.dev/shunsuke_suzuki/scraps/f3aacea7584784
[actions-lock-contract]: https://docs.github.com/en/actions/concepts/security/workflow-dependency-lockfiles
[actions-lock-cli]: https://github.com/github/gh-actions-lock/blob/v0.4.0/README.md

## 2. Issue Creation

- Check `.github/ISSUE_TEMPLATE/` first and follow the template when one
  exists.

## 3. External Repo References (Mention Prevention)

Applies to issues, PRs, commit messages, and all GitHub-posted text.

Public and permanent GitHub surfaces must use repo-relative paths or stable
web URLs. Do not write machine-local absolute paths in issues, PRs, commit
messages, review comments, or other GitHub-posted text.
<!-- private-content-scan: allow-next-line -- examples of forbidden local paths for public GitHub surfaces. -->
Examples include `/home/...`, `/nix/store/...`, and `~/ghq/...`. Local
absolute paths are only for user-facing chat, internal task artifacts, and
debug evidence.

Check org membership before linking other repositories:

```sh
gh api user/memberships/orgs --jq '.[].organization.login'
```

- Same org: bare URLs and `org/repo#123` are fine.
- Cross-org or external: escape with backticks or plain text so the reference
  does not create a mention.
- Non-GitHub URLs and blob/tree URLs are always safe.

## 4. PR Conflict Resolution

- Fetch `origin` and verify PR head, base, worktree branch, upstream, and
  clean status before editing.
- Do not rebase, force-push, or otherwise rewrite PR branch history unless the
  user explicitly approves that operation for the current task.
- When integration commands are blocked by hooks or policy, do not retry them.
  Prefer ordinary resolution commits that make the PR branch mergeable while
  preserving branch-specific changes.
- If push or publication is denied, report the branch, local commit, checks,
  and denial so a human can publish the prepared commit.

## 5. Branch Publication and PR Creation

- First-time branch publication must use an explicit destination refspec:
  `git push --set-upstream origin HEAD:refs/heads/<same-branch-name>`.
- Before publication, verify `git branch --show-current`,
  `git status --short --branch`, and
  `git rev-parse --abbrev-ref --symbolic-full-name @{u}` when an upstream
  already exists.
- The local branch name and remote destination branch name must match.
  Destinations `refs/heads/main` and `refs/heads/dev` are protected shared
  branch destinations, not feature branch publication targets.
- Local Git defaults are only safety defaults. Repositories must rely on
  GitHub rulesets or branch protection for shared branches such as `main` and
  `dev`.
- Before PR creation, verify that `origin/<feature-branch>` exists, the PR
  base is the intended base branch, the PR head is the feature branch, and the
  working tree is clean. Do not create a PR from an unverified local-only
  branch or a mismatched base/head pair.

## 6. Commit Messages

- Match the language of recent commits (English or Japanese).
- Use Conventional Commits: `<type>(<scope>): <description> (#<issue>)`.
- Types: feat, fix, docs, style, refactor, test, chore.
- Add body sections as needed: Summary, Background, Changes, Technical
  Details, Verification, Related URLs.
- Choose granularity that supports work resumption, and include the "why".
- When structural and behavioral changes are both needed, prefer separate
  commits; if that is not possible, call out the split explicitly in the body.
- Never add Co-Authored-By trailers or AI tool notices.
- Never commit `.i9wa4/` files, `/tmp/` files, or machine-local absolute
  paths.

## 7. Sub-issues and Issue Types

Sub-issues are natively supported by `gh issue` since v2.94 (no extension
needed):

- Create a new issue as a sub-issue: `gh issue create --parent <number-or-URL>`
- Add an existing issue as a sub-issue:
  `gh issue edit <number> --add-sub-issue <number-or-URL>`
- Remove a sub-issue:
  `gh issue edit <number> --remove-sub-issue <number-or-URL>`
- Set or change the parent issue:
  `gh issue edit <number> --parent <number-or-URL>`
- Remove the parent relationship: `gh issue edit <number> --remove-parent`

Issue types (also native since v2.94):

- Set the type on create: `gh issue create --type <name>`
- Set or change the type: `gh issue edit <number> --type <name>`
- Remove the type: `gh issue edit <number> --remove-type`

## 8. PR Inline Comments

- `gh pr comment` posts PR-wide comments only; inline comments require
  `gh api`.
- Resolve `commit_id` with
  `gh pr view NUMBER --json commits --jq '.commits[-1].oid'`.
- Post with `gh api repos/OWNER/REPO/pulls/NUMBER/comments` and the fields
  `body`, `commit_id`, `path`, `line` (absolute), and `side` (RIGHT/LEFT).
- Reply with
  `gh api repos/OWNER/REPO/pulls/NUMBER/comments/COMMENT_ID/replies`.

## 9. Commit and Push Permissions

Track commit and push as explicit task items that require permission:

```text
- [ ] Commit changes (requires permission)
- [ ] Push to remote (requires permission)
```

"Requires permission" means asking the human directly only in a plain,
non-postman session. When operating as a postman node (worker, worker-alt, or
any future node with push/PR ability, per `tmux-a2a-postman help config`
`common_template`), never ask the human user directly for this permission,
even though this phrasing is generic. Instead, reply
`BLOCKED: awaiting human approval for <action>` to orchestrator so approval
routes through orchestrator to messenger to the user. Treat commit, push,
force-push, branch publication, and PR creation as the actions this applies
to.

## 10. PR Review Comments

Start every review comment with one of these tags:

| Tag      | Meaning                       | Action   |
| -------- | ----------------------------- | -------- |
| [must]   | Must fix before merge         | Fix      |
| [want]   | Strongly prefer, not blocking | Respond  |
| [imo]    | Take it or leave it           | Optional |
| [nits]   | Style/readability nitpick     | Optional |
| [ask]    | Needs clarification           | Respond  |
| [fyi]    | Informational                 | None     |
| [praise] | Positive feedback             | None     |

- Style: Japanese, concise (state the problem, not the fix), no Before/After
  blocks, one concern per comment.
<!-- private-content-scan: allow-next-line -- preserved source guidance references the owner's private writing corpus. -->
- Tone: match @~/ghq/github.com/i9wa4/i9wa4.github.io/blog/ and zenn/

## 11. Lookup / Read Commands

These are read-only information lookups, not mutating actions. They do NOT
require an issue worktree first; the worktree-before-editing rule at the top
of this file applies only to mutating actions (issue/branch/commit/push/PR
creation), not to reading existing issues, PRs, or history.

- Read an issue's full conversation:
  `gh issue view <number> --json title,body,comments`
- Read a PR's full conversation, including reviews:
  `gh pr view <number> --json title,body,comments,reviews`
- Read recent commit history for context:
  `git log --oneline -20` and `git log -p -- <changed-files>`
- Search past issues or PRs for related prior decisions:
  `gh pr list --state all --search "<keyword>"` and
  `gh issue list --state all --search "<keyword>"`
