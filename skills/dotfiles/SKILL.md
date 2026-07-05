---
name: dotfiles
license: MIT
description: |
  USE FOR: This dotfiles environment and its agent harness: machine setup (Ubuntu, WSL2, macOS, home-manager, nix-darwin), daily Nix operations and upgrade/recovery, missing CLI tools / command not found, operating concepts, storage hygiene, clipboard (Vim, Neovim, tmux), Claude Code and Codex CLI config, hooks, MCP, skill installation, postman routing, orchestrator runbooks, tmux workspaces, issue/PR worktrees, pane operations, prompt/review contracts, resume handoff; Agent Skills authoring: add/edit/validate skills, Waza, release readiness, publishing. DO NOT USE FOR: Nix package authoring (programming).
---

# Dotfiles Environment

Owner skill for this machine, this repository, and the agent harness.

## 1. Workflow

1. Inspect the relevant files and `git status`.
2. Open the owner reference below; make the smallest scoped change.
3. Run the nearest check (`nix run '.#check'` for flake-level changes) and
   report verification plus remaining risk.

## 2. References

Environment:

- [Machine Setup](references/machine-setup.md) — new-machine bootstrap
- [Nix Operations](references/nix-operations.md) — daily commands, upgrade,
  macOS recovery
- [Missing Tools](references/missing-tools.md) — command not found: direnv
  exec / comma / nix run
- [Operating Concepts](references/operating-concepts.md) — repo map
- [Storage Hygiene](references/storage-hygiene.md) — reports, retention,
  cleanup
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
