---
name: brainstorming
license: MIT
description: |
  USE FOR: Ambiguity-reduction before planning: fuzzy requirements, multiple plausible approaches, and option tradeoffs. Detailed owner: plan-design. DO NOT USE FOR: unrelated tasks, broad rewrites outside the request, or generated runtime outputs.
---

# Brainstorming

Compatibility trigger for ambiguity-reduction tasks. The durable guidance now
lives in `skills/plan-design/references/brainstorming.md`.

## Use For

- Fuzzy requirements or multiple plausible approaches before planning.
- Option framing with 2-3 trade-off comparisons.
- Narrowing a user-facing objective before implementation.

## Do Not Use For

- Clear tasks with an existing acceptance target.
- Approved plans that already have concrete milestones.
- Unrelated domains, broad rewrites outside the request, or generated runtime
  outputs.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/plan-design/references/brainstorming.md`.
3. Stabilize the direction enough to continue with `plan-design` or a direct
   implementation handoff.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- `skills/plan-design/references/brainstorming.md`
