---
name: agent-workspace
license: MIT
description: |
  USE FOR: Agent tmux workspaces, issue-first development with issue-worktree-create, worktree lifecycle, re-entry, session naming, and pane operations. DO NOT USE FOR: unrelated tasks or generated outputs.
---

# Agent Workspace

**UTILITY SKILL:** Apply this skill to boot and manage agent tmux workspaces,
issue-first development with `issue-worktree-create`, worktree re-entry,
session naming, and pane operations. Keep the task scoped to the requested
domain and preserve existing repo conventions.

**USE FOR:** Boot and manage agent tmux workspaces using the vde-layout va
preset, issue-first development with `issue-worktree-create`, worktree re-entry,
session naming, and pane operations; related file edits; verification and
handoff in this skill domain.

**DO NOT USE FOR:** unrelated domains, broad rewrites outside the request,
generated runtime outputs, or replacing repo-specific source of truth.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read [Preserved Guidance](references/preserved-guidance.md) before changing
   behavior or giving detailed instructions.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- [Boot Failure Modes](references/boot-failure-modes.md)
- [Preserved Guidance](references/preserved-guidance.md)
- [Tmux Pane Operations](references/tmux-pane-operations.md)
- [Vde Layout Internals](references/vde-layout-internals.md)
- [Worktree Workflow](references/worktree-workflow.md)

## Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
