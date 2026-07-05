---
name: plan-design
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Implementation plans and durable task tracking: reduce ambiguity, compare options, parallel investigation, multi-source synthesis, review gates, task artifacts, evidence logs, handoff/resume, and DONE/BLOCKED verification. DO NOT USE FOR: unrelated tasks, broad rewrites outside the request, or generated runtime outputs.
---

# Plan Design

Owns implementation-plan authoring and durable task tracking for plan-ready
tasks: ambiguity reduction, option framing, multi-source synthesis, review
gates, task artifacts, evidence logs, and handoff/resume.

## 1. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read [Plan Authoring](references/plan-authoring.md) before changing
   behavior or giving detailed instructions.
3. If the task is fuzzy or has multiple viable approaches, read
   [Brainstorming](references/brainstorming.md) and stabilize the direction
   before drafting the execution plan.
4. Make the smallest scoped change that satisfies the request.
5. Run the checks named in the plan authoring guide or the nearest repo
   harness.
6. Report verification results and any remaining risk.

## 2. References

- [Plan Authoring](references/plan-authoring.md)
- [Brainstorming](references/brainstorming.md)
- [Durable Task Tracking](references/durable-task-tracking.md)
