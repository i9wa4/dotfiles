---
name: plan-design
license: MIT
description: |
  USE FOR: Implementation plans for complex tasks. Covers parallel investigation, multi-source synthesis, and review gates. Task must be plan-ready. Use this skill when tasks need this repository-specific workflow. DO NOT USE FOR: unrelated tasks, broad rewrites outside the request, or generated runtime outputs.
---

# Plan Design

**UTILITY SKILL:** Apply this skill to Implementation plans for complex tasks,
ambiguity reduction, option framing, multi-source synthesis, and review gates.
Task must be plan-ready before execution planning begins. Keep the task scoped
to the requested domain and preserve existing repo conventions.

**USE FOR:** Implementation plans for complex tasks. Covers parallel
investigation, multi-source synthesis, and review gates. Task must be
plan-ready; ambiguity reduction before planning; related file edits;
verification and handoff in this skill domain.

**DO NOT USE FOR:** unrelated domains, broad rewrites outside the request,
generated runtime outputs, or replacing repo-specific source of truth.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read [Preserved Guidance](references/preserved-guidance.md) before changing
   behavior or giving detailed instructions.
3. If the task is fuzzy or has multiple viable approaches, read
   [Brainstorming](references/brainstorming.md) and stabilize the direction
   before drafting the execution plan.
4. Make the smallest scoped change that satisfies the request.
5. Run the checks named in the preserved guidance or the nearest repo harness.
6. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- [Preserved Guidance](references/preserved-guidance.md)
- [Brainstorming](references/brainstorming.md)

## Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
