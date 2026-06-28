---
name: durable-task-tracking
license: MIT
description: |
  USE FOR: durable task tracking for multi-step, multi-node, or reviewed work:
  preserving original checklists, evidence logs, handoff/resume, and
  DONE/BLOCKED verification. Detailed owner: plan-design.
  DO NOT USE FOR: live postman routing, mailbox operation, GitHub publication
  mechanics, or simple single-step work without a durable tracking need.
---

# Durable Task Tracking

Compatibility trigger for durable task tracking. The durable guidance now
lives in `skills/plan-design/references/durable-task-tracking.md`.

## 1. Use For

- Multi-step work that must survive chat compaction, node handoff, or review
  loops.
- Original-checklist preservation and DONE/BLOCKED verification.
- Handoff and resume across nodes or sessions.

## 2. Do Not Use For

- Live postman routing or mailbox operation.
- GitHub publication mechanics.
- Simple single-step work that has no durable tracking need.

## 3. Workflow

1. Decide whether the situation needs durable tracking.
2. Read `skills/plan-design/references/durable-task-tracking.md` for directory
   labels, `mkmd` commands, artifact shape, evidence log discipline,
   handoff/resume fields, and DONE/BLOCKED verification.
3. Create or preserve a single canonical artifact before deep work.
4. Before reporting DONE or BLOCKED, compare the artifact's original checklist
   with actual evidence.

## 4. References

- `skills/plan-design/references/durable-task-tracking.md`
