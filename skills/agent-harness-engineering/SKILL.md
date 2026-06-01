---
name: agent-harness-engineering
license: MIT
description: |
  USE FOR: agent harness config/hooks, skill install, postman routing, orchestrator runbooks, worktrees, pane validation, prompt/review contracts, resumes.
---

# Agent Harness Engineering

**USE FOR:** Dotfiles agent harness work: Claude/Codex config, Nix/HM hooks,
MCP, skill installation, postman routing, orchestrator role/runbooks, tmux
workspaces, issue/PR worktrees, pane operations including stale target
validation, prompt/review contracts, and resume handoff.

**DO NOT USE FOR:** unrelated domains, broad rewrites, generated outputs, or
replacing repo source of truth.

## 1. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Open the owner reference for the surface:
   [Harness](references/preserved-guidance.md),
   [Workspace](references/workspace-preserved-guidance.md), or
   [Prompts](references/prompt-contracts-preserved-guidance.md).
3. Use sibling refs as needed, make the smallest scoped change, run nearest
   checks, and report verification plus remaining risk.

## 2. References

- [Harness](references/preserved-guidance.md),
  [Claude](references/claude-code.md),
  [Claude trust](references/claude-workspace-trust.md),
  [Codex](references/codex-cli.md),
  [Changelog](references/changelog-tracking.md),
  [Runbook](references/orchestrator-runbook.md)
- [Workspace](references/workspace-preserved-guidance.md),
  [Worktrees](references/workspace-worktree-workflow.md),
  [Panes](references/workspace-tmux-pane-operations.md),
  [Boot](references/workspace-boot-failure-modes.md),
  [VDE](references/workspace-vde-layout-internals.md)
- [Prompts](references/prompt-contracts-preserved-guidance.md),
  [Blocks](references/prompt-blocks.md),
  [Review](references/review-output-contract.md),
  [Resume](references/resume-handoff.md)
