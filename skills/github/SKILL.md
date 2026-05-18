---
name: github
license: MIT
description: |
  USE FOR: GitHub: gh CLI usage, PR conflict resolution, commit messages, issue/PR creation, inline comments, sub-issues, review style, public surface path hygiene rules. Use this skill when tasks need this repository-specific workflow. DO NOT USE FOR: unrelated tasks, broad rewrites outside the request, or generated runtime outputs.
---

# Github

**UTILITY SKILL:** Apply this skill to GitHub: gh CLI usage, PR conflict
resolution, commit messages, issue/PR creation, inline comments, sub-issues,
review style, public surface path hygiene rules. Keep the task scoped to the
requested domain and preserve existing repo conventions.

**USE FOR:** GitHub: gh CLI usage, PR conflict resolution, commit messages,
issue/PR creation, inline comments, sub-issues, review style, public surface
path hygiene rules; related file edits; verification and handoff in this skill
domain.

**DO NOT USE FOR:** unrelated domains, broad rewrites outside the request,
generated runtime outputs, or replacing repo-specific source of truth.

## Boundary

This skill owns GitHub mechanics: `gh` usage, issue/PR state inspection,
commit and PR-publication rules, inline comment mechanics, and public
wording/path hygiene. It supports review workflows but does not own the
guardian/critic review engine or the user-facing review-comment trigger.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read [Preserved Guidance](references/preserved-guidance.md) before changing
   behavior or giving detailed instructions.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- [Preserved Guidance](references/preserved-guidance.md)

## Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
