---
name: dotfiles
license: MIT
metadata:
  version: "1.0.1"
description: |
  USE FOR: Maintaining this dotfiles repository and its managed
  environment: machine setup and recovery, Nix/Home Manager,
  terminal/editor settings, and Claude/Codex configuration, hooks,
  MCP and Skill management.
  DO NOT USE FOR: Work in unrelated repositories or routine Postman
  team coordination.
---

# Dotfiles Maintenance

This Skill is local to this repository. Read the relevant source, reference and
Git status before editing. Work in an isolated worktree for changes. Keep the
macOS Apple Silicon and Ubuntu 24.04/WSL2 targets in view. Use repository checks
for the changed surface; run `nix run '.#check'` for flake or installed-agent
changes. Report actual results and remaining limits. Machine activation is a
separate operation.

## 1. References

- [Machine Setup](references/machine-setup.md) and
  [Nix Operations](references/nix-operations.md) — bootstrap, updates and
  recovery.
- [Operating Concepts](references/operating-concepts.md) — source and runtime
  ownership.
- [Harness](references/harness-guidance.md) — Claude/Codex config, hooks, MCP
  and selected Postman integration.
- [Workspace](references/workspace-guidance.md) — tmux, pane identity and
  environment navigation.
- [Skill Management](references/skills-management.md) — authoring, validation
  and publishing.
- [Repo AI Contract](references/repo-ai-operating-contract.md) — local runtime
  and repository boundaries.
- [macSKK](references/macskk.md), [Clipboard](references/clipboard-strategy.md),
  [Tailscale](references/tailscale-operations.md), and
  [Missing Tools](references/missing-tools.md) — focused environment operations.

Postman's pinned Skills and CLI help own generic Git/GitHub operations,
communication, records and review procedures. The installed `postman.md` owns
roles, topology and authority; this repository owns its selection and wiring.
