---
name: dotfiles
license: MIT
description: |
  USE FOR: This dotfiles environment and its agent harness: machine setup (Ubuntu, WSL2, macOS, Nix install, home-manager, nix-darwin), daily Nix operations and upgrade/recovery, operating concepts, storage hygiene, clipboard integration (Vim, Neovim, tmux), Claude Code and Codex CLI config, hooks, MCP, skill installation, postman routing, orchestrator runbooks, tmux workspaces, issue/PR worktrees, pane operations, prompt/review contracts, resume handoff; aliases: agent-harness-engineering, agent-workspace, prompt-contracts-local. DO NOT USE FOR: Nix package authoring (programming) or skill authoring/validation (agent-skills-management).
---

# Dotfiles Environment

Owner skill for "my environment": machine and repository setup, operation,
cleanup, and the agent harness (absorbs the former
`agent-harness-engineering` skill).

## 1. Workflow

1. Inspect the relevant files and `git status`.
2. Open the owner reference for the surface below; use sibling refs as
   needed; make the smallest scoped change.
3. Run the nearest check (`nix run '.#check'` for flake-level changes) and
   report verification plus remaining risk.

## 2. References

Environment:

- [Machine Setup](references/machine-setup.md) — new-machine bootstrap
- [Nix Operations](references/nix-operations.md) — daily commands, upgrade,
  macOS recovery
- [Operating Concepts](references/operating-concepts.md) — repo map
- [Storage Hygiene](references/storage-hygiene.md) — reports, retention,
  cleanup
- [Clipboard](references/clipboard-strategy.md) — Vim/Neovim/tmux/host

Agent harness (each hub links its sibling references):

- [Harness](references/preserved-guidance.md) — Claude/Codex config, hooks,
  deny rules, command approval, AI operating contract, runbook
- [Workspace](references/workspace-preserved-guidance.md) — tmux workspaces,
  worktrees, panes, boot, VDE
- [Prompts](references/prompt-contracts-preserved-guidance.md) — prompt
  blocks, review contracts, responsibility boundaries, resume handoff
