---
name: systematic-debugging
license: MIT
description: |
  USE FOR: Root-cause-first debugging for unknown failures: reproducer isolation, working-pattern comparison. Use when mechanism is unclear. Use this skill when tasks need this repository-specific workflow. DO NOT USE FOR: unrelated tasks, broad rewrites outside the request, or generated runtime outputs.
---

# Systematic Debugging

**UTILITY SKILL:** Apply this skill to Root-cause-first debugging for unknown
failures: reproducer isolation, working-pattern comparison. Use when mechanism
is unclear. Keep the task scoped to the requested domain and preserve existing
repo conventions.

**USE FOR:** Root-cause-first debugging for unknown failures: reproducer
isolation, working-pattern comparison. Use when mechanism is unclear; related
file edits; verification and handoff in this skill domain.

**DO NOT USE FOR:** unrelated domains, broad rewrites outside the request,
generated runtime outputs, or replacing repo-specific source of truth.

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
