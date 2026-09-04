---
name: dev-platform-workflow
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Read BEFORE any git or GitHub action (issue, branch, commit, push, PR create/review) — sets the issue-first, worktree-based default via issue-worktree-create. GitHub/Jira/Confluence: gh CLI, PR/commit/issue management, review style, public path hygiene; Atlassian Cloud when env vars are confirmed. DO NOT USE FOR: guessing credentials, unrelated tasks, broad rewrites, or generated runtime outputs.
---

# Dev Platform Workflow

Owns `gh` usage, GitHub issue/PR creation and inspection, public surface path
hygiene, commit/PR rules, and Atlassian access when env vars are confirmed.

## 1. Development Default

Before git/GitHub actions that edit files, create commits, or change branches,
work in a dedicated worktree. Issue work: create/choose the issue, run
`issue-worktree-create <issue_number>`, then edit there. PR review:
`pr-worktree-create <pr_number>`.

Never edit or commit from the main checkout, even for docs-only or single-line
changes. If there is deliberately no issue/PR number, first run
`git worktree add -b <branch> .worktrees/<branch> main` and `cd` there. Raw
`git worktree add` is only for this no-issue branch case, not issue/PR work.
Avoid `EnterWorktree`. Verify `pwd`, branch, and status before editing.

## 2. Workflow

1. Inspect relevant files, repo conventions, and `git status`.
2. Read [Workflow Guide](references/github-workflow.md) before changing
   behavior or giving detailed instructions.
3. Before publication or PR creation, verify branch, upstream, base/head, and
   clean status; use the same-name remote destination workflow.
4. Make the smallest scoped change, run nearest checks, and report risk.

## 3. References

- [Workflow Guide](references/github-workflow.md)
- [Atlassian](references/atlassian.md)
- [Atlassian API Token](references/atlassian-api-token.md)
