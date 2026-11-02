---
name: orchestration
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Team-manager coordination, task decomposition and delegation,
  start/resume recovery, canonical task-index reconciliation, parent/child
  handoffs, review routing, evidence-backed completion, blockers and escalation.
  DO NOT USE FOR: source implementation, machine/harness maintenance,
  artifact storage mechanics, substantive review, or standalone mail syntax.
---

# Orchestration

Coordinate an assigned team scope under the current role's authority. This
skill grants no manager role, new delegation permission or direct source access.
It works at any configured finite depth without assuming a role name or engine.

## 1. Required Procedure

Read the [runbook](references/runbook.md) from this installed/current Skill
root before coordination. Resolve other required owners from the installed
catalog, not task cwd. Missing required guidance blocks the affected action.

1. At start/resume, recover the original objective, constraints, scope, verified
   canonical index, pending tasks/decisions and exact return routes. Use Logbook
   for selection/storage; never silently replace an active index.
2. Assign bounded work with one accountable writer, acceptance evidence and
   non-overlapping ownership. Delegate investigation, tests and every write;
   coordinate through declared immediate interfaces.
3. On delegation, reply, review, scope change, interruption and completion,
   reconcile evidence and original criteria. Inspect a no-change turn without
   manufacturing writes or mail. Delegate needed detail/index updates together
   and verify read-back before reporting current state.
4. Apply the configured review and human gates. Return an evidenced result or
   specific blocker to the accountable recipient; mail closure is not task
   completion. Escalate decisions beyond scope with evidence and a
   recommendation.

## 2. Ownership and Verification

The runbook delegates artifact mechanics to Logbook, review internals to
`subagent-review`, and CLI/schema to matching upstream Postman guidance. Routine
coordination does not start dotfiles maintenance or create a scheduler/database.

[Migration and verification](references/validation.md) records retained rules,
scenarios, cost comparisons and limits of deterministic checks.
