# dotfiles

[![CI](https://github.com/i9wa4/dotfiles/actions/workflows/ci.yaml/badge.svg)](https://github.com/i9wa4/dotfiles/actions/workflows/ci.yaml)
[![Last Commit](https://img.shields.io/github/last-commit/i9wa4/dotfiles)](https://github.com/i9wa4/dotfiles/commits/main)
[![Top Language](https://img.shields.io/github/languages/top/i9wa4/dotfiles)](https://github.com/i9wa4/dotfiles)
[![Commit Activity](https://img.shields.io/github/commit-activity/m/i9wa4/dotfiles)](https://github.com/i9wa4/dotfiles/commits/main)

Nix-managed machine configuration for macOS (Apple Silicon) and Ubuntu 24.04
LTS (including WSL2), plus a reproducible local engineering and agent harness.
The harness manages tmux role identity, `tmux-a2a-postman` control-plane
integration, Claude/Codex parity, hooks, review and approval boundaries,
durable task artifacts, and active versus reference-only skills.

Operational guidance lives in the
[repo-local dotfiles Skill](.agents/skills/dotfiles/SKILL.md), the
personal/global Skills under [`skills/`](skills/), and the selected Postman
binary. Each local Skill has a `SKILL.md` entry point and detailed
`references/`. The same files serve humans reading this repo and agents working
in it.

Start with the [dotfiles skill](.agents/skills/dotfiles/SKILL.md). It links the
current setup, operations, harness, and skill-management references.

For the system model, read the
[operating concepts](.agents/skills/dotfiles/references/operating-concepts.md).
For the AI runtime and review contract, read the
[repo AI operating contract](.agents/skills/dotfiles/references/repo-ai-operating-contract.md).
