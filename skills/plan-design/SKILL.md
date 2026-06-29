---
name: plan-design
license: MIT
description: |
  USE FOR: Implementation plans and durable task tracking: parallel investigation, multi-source synthesis, review gates, task artifacts, evidence logs, handoff/resume, and DONE/BLOCKED verification. DO NOT USE FOR: unrelated tasks, broad rewrites outside the request, or generated runtime outputs.
---

# Plan Design

**UTILITY SKILL:** Apply this skill to implementation plans and durable task
tracking: ambiguity reduction, option framing, multi-source synthesis, review
gates, task artifacts, evidence logs, and handoff/resume. Task must be
plan-ready. Preserve existing repo conventions.

**USE FOR:** Implementation plans and durable task tracking: parallel
investigation, multi-source synthesis, review gates, task artifacts, evidence
logs, handoff/resume, DONE/BLOCKED verification; ambiguity reduction before
planning; related file edits; verification and handoff.

**DO NOT USE FOR:** unrelated domains, broad rewrites outside the request,
generated runtime outputs, or replacing repo-specific source of truth.

## 1. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read [Preserved Guidance](references/preserved-guidance.md) before changing
   behavior or giving detailed instructions.
3. If the task is fuzzy or has multiple viable approaches, read
   [Brainstorming](references/brainstorming.md) and stabilize the direction
   before drafting the execution plan.
4. Make the smallest scoped change that satisfies the request.
5. Run the checks named in the preserved guidance or the nearest repo harness.
6. Report verification results and any remaining risk.

## 2. Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## 3. References

- [Preserved Guidance](references/preserved-guidance.md)
- [Brainstorming](references/brainstorming.md)
- [Durable Task Tracking](references/durable-task-tracking.md)

## 4. Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
