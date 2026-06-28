---
name: github
license: MIT
description: |
  USE FOR: GitHub: gh CLI usage, PR conflict resolution, commit messages, issue/PR creation, inline comments, sub-issues, review style, public surface path hygiene rules. Use this skill when tasks need this repository-specific workflow. DO NOT USE FOR: unrelated tasks, broad rewrites outside the request, or generated runtime outputs.
---

# Github

**UTILITY SKILL:** Apply this skill to GitHub: gh CLI usage, PR conflict
resolution, commit messages, issue/PR creation, inline comments, sub-issues,
review style, and public surface path hygiene. Preserve existing repo
conventions.

**USE FOR:** GitHub: gh CLI usage, PR conflict resolution, commit messages,
issue/PR creation, inline comments, sub-issues, review style, public surface
path hygiene; related file edits; verification and handoff.

**DO NOT USE FOR:** unrelated domains, broad rewrites outside the request,
generated runtime outputs, or replacing repo-specific source of truth.

## 1. Boundary

This skill owns GitHub mechanics: `gh` usage, issue/PR state inspection,
commit and PR-publication rules, inline comments, and public wording/path
hygiene. It supports review workflows but does not own the
guardian/critic review engine or the user-facing review-comment trigger.

## 2. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read [Preserved Guidance](references/preserved-guidance.md) before changing
   behavior or giving detailed instructions.
3. Before branch publication or PR creation, verify branch, upstream, base,
   head, and clean status; use the same-name remote destination workflow in
   the preserved guidance.
4. Make the smallest scoped change that satisfies the request.
5. Run the checks named in the preserved guidance or the nearest repo harness.
6. Report verification results and any remaining risk.

## 3. Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize.

## 4. References

- [Preserved Guidance](references/preserved-guidance.md)
- [Atlassian](references/atlassian.md)

## 5. Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
