---
name: agent-harness-engineering
license: MIT
description: |
  USE FOR: Dotfiles agent harness work including Claude/Codex config, Nix/HM hooks, MCP, skill installation, postman routing, workspace/worktree operations, prompt contracts, reviews, and resume handoff.
---

# Agent Harness Engineering

**USE FOR:** Dotfiles agent harness work: Claude/Codex config, Nix/HM hooks,
MCP, skill installation, postman routing, runbooks, tmux workspaces, issue/PR
worktrees, pane operations, prompt/review contracts, and resume handoff.

**DO NOT USE FOR:** unrelated domains, broad rewrites, generated outputs, or
replacing repo source of truth.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Open the owner reference for the surface:
   [Harness](references/preserved-guidance.md),
   [Workspace](references/workspace-preserved-guidance.md), or
   [Prompts](references/prompt-contracts-preserved-guidance.md).
3. Use sibling refs as needed, make the smallest scoped change, run nearest
   checks, and report verification plus remaining risk.

## References

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
