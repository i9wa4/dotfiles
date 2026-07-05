# dotfiles

[![CI](https://github.com/i9wa4/dotfiles/actions/workflows/ci.yaml/badge.svg)](https://github.com/i9wa4/dotfiles/actions/workflows/ci.yaml)
[![Last Commit](https://img.shields.io/github/last-commit/i9wa4/dotfiles)](https://github.com/i9wa4/dotfiles/commits/main)
[![Top Language](https://img.shields.io/github/languages/top/i9wa4/dotfiles)](https://github.com/i9wa4/dotfiles)
[![Commit Activity](https://img.shields.io/github/commit-activity/m/i9wa4/dotfiles)](https://github.com/i9wa4/dotfiles/commits/main)

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/i9wa4/dotfiles)

Nix-managed dotfiles for macOS (Apple Silicon) and Ubuntu 24.04 LTS
(including WSL2).

All operational knowledge lives in Agent Skills under [`skills/`](skills/) —
each skill is a `SKILL.md` entry point plus detailed `references/`. The same
files serve humans reading this repo and agents working in it.

## 1. Quick Start

```sh
nix run nixpkgs#git -- clone git@github.com:i9wa4/dotfiles ~/ghq/github.com/i9wa4/dotfiles
cd ~/ghq/github.com/i9wa4/dotfiles
```

Full bootstrap (GitHub SSH auth, Nix install, first switch per OS):
[Machine Setup](skills/dotfiles/references/machine-setup.md).

Daily commands (`nix run '.#switch'`, `.#update`, `.#check`), Nix upgrade, and
macOS recovery: [Nix Operations](skills/dotfiles/references/nix-operations.md).

## 2. Guide Index

| Topic                                             | Location                                                                                             |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Machine setup and bootstrap                       | [skills/dotfiles/references/machine-setup.md](skills/dotfiles/references/machine-setup.md)           |
| Daily Nix operations and upgrade                  | [skills/dotfiles/references/nix-operations.md](skills/dotfiles/references/nix-operations.md)         |
| Repository operating concepts                     | [skills/dotfiles/references/operating-concepts.md](skills/dotfiles/references/operating-concepts.md) |
| Clipboard strategy (Vim/Neovim/tmux/host)         | [skills/dotfiles/references/clipboard-strategy.md](skills/dotfiles/references/clipboard-strategy.md) |
| Agent harness (Claude/Codex config, hooks, panes) | [skills/dotfiles/](skills/dotfiles/SKILL.md)                                                         |
| Agent Skills authoring and release                | [skills/dotfiles/references/skills-management.md](skills/dotfiles/references/skills-management.md)   |
| Multi-agent postman node contracts                | [config/tmux-a2a-postman/postman.md](config/tmux-a2a-postman/postman.md)                             |

Decision records (evaluations, one-time investigations) are archived in a
private knowledge vault, not in this repository.
