---
name: systematic-debugging
license: MIT
description: |
  USE FOR: Root-cause-first debugging for unknown failures: reproducer isolation, working-pattern comparison. Use when mechanism is unclear. Detailed owner: programming. DO NOT USE FOR: unrelated tasks, broad rewrites outside the request, or generated runtime outputs.
---

# Systematic Debugging

Compatibility trigger for root-cause-first debugging. The durable guidance now
lives in `skills/programming/references/systematic-debugging.md`.

## 1. Use For

- Unknown failures where the mechanism is unclear.
- Reproducer isolation and working-pattern comparison.
- Investigation loops before committing to a fix.

## 2. Do Not Use For

- Unrelated domains, broad rewrites outside the request, or generated runtime
  outputs.
- Implementation: once the cause is credible, hand off to `programming` /
  `tdd-tidy-first`.

## 3. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/programming/references/systematic-debugging.md` for the
   investigation loop, repo fit, stop conditions, and handoff guidance.
3. When the cause is credible and the next step is a fix, use
   `skills/programming/references/tdd-tidy-first.md`.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## 4. References

- `skills/programming/references/systematic-debugging.md`
- `skills/programming/references/tdd-tidy-first.md`
