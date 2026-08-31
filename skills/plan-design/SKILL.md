---
name: plan-design
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Implementation plans and durable task tracking: reduce ambiguity,
  compare options, parallel investigation, multi-source synthesis, review
  gates, planning evidence, handoff/resume, DONE/BLOCKED verification, and
  Secret-Gist handoff semantics. DO NOT USE FOR: artifact storage mechanics,
  machine-only outputs, internal logs, code/config artifacts, unrelated tasks,
  broad rewrites outside the request, or generated runtime outputs.
---

# Plan Design

Owns implementation-plan authoring and durable task tracking for plan-ready
tasks: ambiguity reduction, option framing, multi-source synthesis, review
gates, task artifacts, evidence logs, and handoff/resume.

Use `logbook` for non-code artifact lifecycle, local `mkmd` storage,
artifact discovery/reuse, and Secret-Gist delivery mechanics. This skill owns
planning semantics and evidence expectations, not artifact storage policy.

Follow the output language designated by the active runtime/session policy or
explicit request. Do not establish an independent language policy in this
skill.

## 1. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read [Plan Authoring](references/plan-authoring.md) before changing
   behavior or giving detailed instructions.
3. If the task is fuzzy or has multiple viable approaches, read
   [Brainstorming](references/brainstorming.md) and stabilize the direction
   before drafting the execution plan.
4. If plan terms, states, conditions, cause categories, or mitigation names are
   ambiguous, use `clarify-concepts` before the plan language hardens.
5. Make the smallest scoped change that satisfies the request.
6. Run the checks named in the plan authoring guide or the nearest repo
   harness.
7. Report verification results and any remaining risk.

## 2. References

- [Plan Authoring](references/plan-authoring.md)
- [Brainstorming](references/brainstorming.md)
- [Durable Task Tracking](references/durable-task-tracking.md)
