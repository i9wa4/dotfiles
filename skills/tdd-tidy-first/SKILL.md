---
name: tdd-tidy-first
license: MIT
description: |
  USE FOR: TDD and Tidy First loops in this repo: small verifiable behavior changes, reproducer-first fixes, and structural cleanup sequencing. Detailed owner: programming. DO NOT USE FOR: unclear root-cause debugging.
---

# Tdd Tidy First

Compatibility trigger for TDD and Tidy First tasks. The durable implementation
guidance now lives in `skills/programming/references/tdd-tidy-first.md`.

## Use For

- Red-Green-Refactor and Tidy First loops for understood implementation tasks.
- Small verifiable changes where the test surface is clear.

## Do Not Use For

- Unknown failure mechanisms; use `systematic-debugging` first.
- Unrelated domains or generated runtime outputs.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/programming/references/tdd-tidy-first.md`.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- `skills/programming/references/tdd-tidy-first.md`
