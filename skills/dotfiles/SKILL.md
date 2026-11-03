---
name: dotfiles
license: MIT
metadata:
  version: "1.0.1"
description: |
  USE FOR: Dotfiles and agent harness: machine setup, Nix
  operations/recovery, missing tools, operating concepts, clipboard,
  Claude/Codex config, hooks, MCP, skills, Postman routing/runbooks,
  tmux/worktrees/panes, prompt/review/resume-handoff contracts, and Agent
  Skills authoring/validation/Waza.
  DO NOT USE FOR: routine team coordination, or Nix package authoring (programming).
---

# Dotfiles Environment

## 1. Workflow

Maintenance follows current role authority. Coordination-only roles may read
required references; investigation, tests and all writes remain delegated.

1. Read the owner reference; inspect relevant files and `git status`.
2. Run its checks (`nix run '.#check'` for flake changes); report verification
   and remaining risk.

## 2. References

Environment:

- [Machine Setup](references/machine-setup.md) — new-machine bootstrap
- [macSKK and kitty](references/macskk.md) — Ctrl-J newline troubleshooting
- [Nix Operations](references/nix-operations.md) — daily ops, upgrade,
  recovery
- [Tailscale Operations](references/tailscale-operations.md) — start the
  installed daemon and check tailnet connection
- [Missing Tools](references/missing-tools.md) — command not found
  workflow
- [Operating Concepts](references/operating-concepts.md) — repo map and
  module ownership boundaries
- [Clipboard](references/clipboard-strategy.md) — Vim/Neovim/tmux/host

Agent harness:

- [Harness](references/harness-guidance.md) — Claude/Codex config, hooks,
  deny rules, contracts, runbook
- [Workspace](references/workspace-guidance.md) — tmux, worktrees,
  Git lock diagnostics, panes, boot, VDE
- [Prompts](references/prompt-contracts.md) — prompt
  blocks, review contracts, boundaries, resume handoff
- [Resume Handoff](references/resume-handoff.md) — local task handoffs and
  resume prompts
- [Skills Management](references/skills-management.md) — skill authoring,
  Waza, release, publishing
