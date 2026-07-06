# GitHub Workflow

Detailed GitHub mechanics for this environment: `gh` usage, issue and PR
operations, branch publication, commit messages, and review comment style.

Implementation work is issue-first and worktree-based by default: create or
choose the issue, run `issue-worktree-create <issue_number>`, and edit inside
that issue worktree rather than the main checkout. Do not use the generic
worktree tool (`EnterWorktree`) or raw `git worktree add` as the entrypoint.
See `skills/dotfiles/references/workspace-worktree-workflow.md` for the full
flow.

## 1. gh CLI

- Use `gh` for GitHub information retrieval.
- Always fetch the full conversation (body plus comments) for issues and PRs.
- Cite issue and PR numbers with a `#` prefix, for example `#240`.

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
