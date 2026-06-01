---
name: agent-workspace
license: MIT
description: |
  Compatibility trigger for agent tmux workspace and issue/PR worktree requests. Route discovery to agent-harness-engineering, which owns the detailed references and checks.
---

# Agent Workspace

**COMPATIBILITY TRIGGER:** This standalone skill has been demoted. The detailed
owner for agent tmux workspaces, issue/PR worktrees, re-entry, session naming,
and pane operations is `agent-harness-engineering`.

**USE FOR:** Discovery compatibility when a task names `agent-workspace` or asks
about agent tmux workspaces, issue-first development with
`issue-worktree-create`, worktree lifecycle, re-entry, session naming, or pane
operations.

**DO NOT USE FOR:** maintaining separate workspace guidance, unrelated domains,
broad rewrites outside the request, generated runtime outputs, or replacing the
`agent-harness-engineering` source of truth.

## 1. Workflow

1. Switch to `skills/agent-harness-engineering/SKILL.md` for the active
   workflow.
2. For detailed workspace guidance, read these target references:
   `workspace-preserved-guidance.md`, `workspace-worktree-workflow.md`,
   `workspace-tmux-pane-operations.md`, `workspace-boot-failure-modes.md`, and
   `workspace-vde-layout-internals.md`.
3. Follow the validation and handoff rules from `agent-harness-engineering`.

## 2. Examples

For a request in this domain, route to `agent-harness-engineering`, load the
workspace reference that matches the task, run focused checks, and summarize
the result.

## 3. References

Detailed references now live under
`skills/agent-harness-engineering/references/`.

## 4. Troubleshooting

If this compatibility trigger and `agent-harness-engineering` disagree, follow
`agent-harness-engineering` and record the exception in the handoff.
