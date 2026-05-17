# Preserved Guidance

Original SKILL.md guidance before Waza compaction. Use this reference when the
concise skill needs domain-specific details.

~~~~~~~~~~~~markdown
---
name: github
license: MIT
description: |
  GitHub: gh CLI usage, commit messages, issue/PR creation, inline comments, sub-issues, review style, public surface path hygiene rules.
---

# GitHub Rules

## 1. gh CLI

- YOU MUST: Use `gh` for GitHub info retrieval
- YOU MUST: Always fetch all comments (body + comments) for Issues/PRs
- YOU MUST: Cite Issue/PR numbers with `#` prefix (e.g., `#240`)

## 2. Issue Creation

- YOU MUST: Check `.github/ISSUE_TEMPLATE/` and follow if exists

## 3. External Repo References (Mention Prevention)

Applies to: Issues, PRs, commit messages, all GitHub-posted text.

Public and permanent GitHub surfaces MUST use repo-relative paths or stable web
URLs. Do not write machine-local absolute paths in issues, PRs, commit
messages, review comments, or other GitHub-posted text.
<!-- private-content-scan: allow-next-line -- examples of forbidden local paths for public GitHub surfaces. -->
Examples include `/home/...`, `/nix/store/...`, and `~/ghq/...`. Local absolute
paths are only for user-facing chat, internal task artifacts, and debug
evidence.

Check org membership:
`gh api user/memberships/orgs --jq '.[].organization.login'`

- Same org: bare URLs and `org/repo#123` OK
- Cross-org/external: escape with backticks or plain text
- Non-GitHub URLs and blob/tree URLs: always safe

## 4. PR Conflict Resolution

- Fetch `origin` and verify PR head, base, worktree branch, upstream, and clean
  status before editing.
- Do not rebase, force-push, or otherwise rewrite PR branch history unless the
  user explicitly approves that operation for the current task.
- When merge, rebase, or direct integration commands are blocked by hooks or
  policy, do not retry them. Prefer ordinary resolution commits that make the
  PR branch mergeable while preserving branch-specific changes.
- If push or publication is denied, report the branch, local commit, checks,
  and denial so a human can publish the prepared commit.

## 5. Commit Messages

- YOU MUST: Match language of recent commits (English or Japanese)
- YOU MUST: Use Conventional Commits:
  `<type>(<scope>): <description> (#<Issue>)`
- Types: feat, fix, docs, style, refactor, test, chore
- Body sections as needed: Summary, Background, Changes, Technical Details,
  Verification, Related URLs
- IMPORTANT: Granularity for work resumption; include "why"
- IMPORTANT: When structural and behavioral changes are both needed, prefer
  separate commits; if not possible, call out the split explicitly
- NEVER: Co-Authored-By, AI tool notices
- NEVER: `.i9wa4/` files, `/tmp/` files, machine-local absolute paths

## 6. Sub-issues

- YOU MUST: Use `gh sub-issue` extension (`add/list/remove`)

## 7. PR Inline Comments

- `gh pr comment` = PR-wide only; inline requires `gh api`
- `commit_id`: `gh pr view NUMBER --json commits --jq '.commits[-1].oid'`
- Post: `gh api repos/OWNER/REPO/pulls/NUMBER/comments` with `body`,
  `commit_id`, `path`, `line`(absolute), `side`(RIGHT/LEFT)
- Reply: `gh api repos/OWNER/REPO/pulls/NUMBER/comments/COMMENT_ID/replies`

## 8. TodoWrite (Claude Code)

```text
- [ ] Commit changes (requires permission)
- [ ] Push to remote (requires permission)
```

## 9. PR Review Comments

Tags (required at start of every comment):

| Tag      | Meaning                       | Action   |
| -------- | ----------------------------- | -------- |
| [must]   | Must fix before merge         | Fix      |
| [want]   | Strongly prefer, not blocking | Respond  |
| [imo]    | Take it or leave it           | Optional |
| [nits]   | Style/readability nitpick     | Optional |
| [ask]    | Needs clarification           | Respond  |
| [fyi]    | Informational                 | None     |
| [praise] | Positive feedback             | None     |

- Style: Japanese, concise (problem not fix), no Before/After blocks, one
  concern
per comment.
<!-- private-content-scan: allow-next-line -- preserved source guidance references the owner's private writing corpus. -->
- Tone: match @~/ghq/github.com/i9wa4/i9wa4.github.io/blog/ and zenn/
~~~~~~~~~~~~
