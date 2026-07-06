---
name: collaboration
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Read BEFORE any git or GitHub action (issue, branch, commit, push, PR create/review) — sets the issue-first, worktree-based default via issue-worktree-create. GitHub/Jira/Confluence: gh CLI, PR/commit/issue management, review style, public path hygiene; Atlassian Cloud when env vars are confirmed. DO NOT USE FOR: guessing credentials, unrelated tasks, broad rewrites, or generated runtime outputs.
---

# Collaboration

Owns GitHub mechanics (`gh` usage, issue/PR state inspection, commit
rules, inline comments, public path hygiene) and Atlassian access (Jira and
Confluence when env vars are confirmed). Does not own the guardian/critic
review engine or the user-facing review-comment trigger.

## 1. Development Default

Before any git or GitHub action, the default is issue-first, worktree-based
development: create or choose the GitHub issue, run
`issue-worktree-create <issue_number>`, then develop inside that worktree. Do
not edit the main checkout, and do not use raw `git worktree add` or the
generic `EnterWorktree` tool as the entrypoint. Verify placement
(`pwd`, `git branch --show-current`) before editing.

Norm, not absolute rule; deliberate small base-checkout touches are fine. Full
mechanics: `skills/dotfiles/references/worktree-development-overview.md`.

## 2. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read [Workflow Guide](references/github-workflow.md) before changing
   behavior or giving detailed instructions.
3. Before branch publication or PR creation, verify branch, upstream, base,
   head, and clean status; use the same-name remote destination workflow in
   the workflow guide.
4. Make the smallest scoped change that satisfies the request.
5. Run the checks named in the workflow guide or the nearest repo harness.
6. Report verification results and any remaining risk.

## 3. References

- [Workflow Guide](references/github-workflow.md)
- [Atlassian](references/atlassian.md)
- [Atlassian API Token](references/atlassian-api-token.md)
