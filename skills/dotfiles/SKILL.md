---
name: dotfiles
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: This dotfiles environment and its agent harness: machine setup (Ubuntu, WSL2, macOS, home-manager, nix-darwin), daily Nix operations and upgrade/recovery, missing CLI tools / command not found, operating concepts, clipboard (Vim, Neovim, tmux), Claude Code and Codex CLI config, hooks, MCP, skill installation, postman routing, orchestrator runbooks, tmux workspaces, issue/PR worktrees, pane operations, prompt/review contracts, resume handoff; Agent Skills authoring: add/edit/validate skills, Waza, release readiness, publishing. DO NOT USE FOR: Nix package authoring (programming).
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
- [Operating Concepts](references/operating-concepts.md) — repo map
- [Clipboard](references/clipboard-strategy.md) — Vim/Neovim/tmux/host

Agent harness (hubs link their siblings):

- [Harness](references/preserved-guidance.md) — Claude/Codex config, hooks,
  deny rules, contracts, runbook
- [Workspace](references/workspace-preserved-guidance.md) — tmux, worktrees,
  panes, boot, VDE
- [Prompts](references/prompt-contracts-preserved-guidance.md) — prompt
  blocks, review contracts, boundaries, resume handoff
- [Skills Management](references/skills-management.md) — skill authoring,
  Waza, release, publishing
