---
name: durable-task-tracking
license: MIT
description: |
  USE FOR: durable task tracking for multi-step, multi-node, or reviewed work:
  preserving original checklists, evidence logs, handoff/resume, and
  DONE/BLOCKED verification.
  DO NOT USE FOR: live postman routing, mailbox operation, GitHub publication
  mechanics, or simple single-step work without a durable tracking need.
---

# Durable Task Tracking

**UTILITY SKILL:** Apply this skill when a task needs durable tracking across
multi-step execution, multi-node handoff, review rounds, chat compaction, or
explicit original-checklist verification.

**USE FOR:** Preserving an original markdown checklist, keeping one task
artifact current, recording progress and evidence, preparing handoff/resume
notes, and verifying DONE/BLOCKED reports against actual evidence.

**DO NOT USE FOR:** Live postman routing, mailbox operation, GitHub publication
mechanics, or simple single-step work that has no durable tracking need.

## 1. Workflow

1. Decide whether the situation needs durable tracking: multi-step work,
   multi-node coordination, review rounds, handoff/resume, or a completion gate
   tied to an original checklist.
2. Preserve any provided markdown artifact as the canonical original checklist.
3. If no artifact exists, create one with `mkmd` before deep work.
4. Keep a single canonical artifact. Put the task, original checklist, progress,
   evidence, decisions, verification, blockers, and completion verdict there.
5. Before reporting DONE or BLOCKED, compare the artifact's original checklist
   with actual evidence and name the artifact path in the report.

## 2. Details

Read [Task Artifact Method](references/task-artifact-method.md) for directory
choices, `mkmd` command examples, tracker skeletons, handoff/resume fields,
DONE/BLOCKED verification, and common mistakes.

## 3. Troubleshooting

If an existing artifact path conflicts with a newly created one, keep the
provided path as canonical and note the duplicate as a mistake in the evidence
log. If `mkmd` fails, report BLOCKED with the exact command and failure.
