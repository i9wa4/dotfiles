---
name: dotfiles
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: This dotfiles environment and agent harness: machine setup, Nix
  operations/recovery, missing tools, operating concepts, clipboard,
  Claude/Codex config, hooks, MCP, skills, Postman routing/runbooks,
  tmux/worktrees/panes, prompt/review/resume-handoff contracts, and optional
  portable agent task-memo Gists; Agent Skills authoring/validation/Waza.
  DO NOT USE FOR: Nix package authoring (programming).
---

# Dotfiles Environment

Owner skill for this machine, this repository, and the agent harness.

## 1. Workflow

1. Inspect the relevant files and `git status`.
2. Open the owner reference below; make the smallest scoped change.
3. Run the nearest check (`nix run '.#check'` for flake changes); report
   verification and remaining risk.

## 2. References

Environment:

- [Machine Setup](references/machine-setup.md) — new-machine bootstrap
- [Nix Operations](references/nix-operations.md) — daily ops, upgrade,
  recovery
- [Missing Tools](references/missing-tools.md) — command not found
  workflow
- [Operating Concepts](references/operating-concepts.md) — repo map and
  module ownership boundaries
- [Clipboard](references/clipboard-strategy.md) — Vim/Neovim/tmux/host

Agent harness (hubs link their siblings):

- [Harness](references/harness-guidance.md) — Claude/Codex config, hooks,
  deny rules, contracts, runbook
- [Workspace](references/workspace-guidance.md) — tmux, worktrees,
  Git lock diagnostics, panes, boot, VDE
- [Prompts](references/prompt-contracts.md) — prompt
  blocks, review contracts, boundaries, resume handoff
- [Resume Handoff](references/resume-handoff.md) — local task handoffs and
  optional portable agent task-memo Gists
- [Skills Management](references/skills-management.md) — skill authoring,
  Waza, release, publishing
