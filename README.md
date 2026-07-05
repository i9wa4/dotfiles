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

Full bootstrap (GitHub SSH auth, Nix install, first switch per OS):
[Machine Setup](skills/dotfiles/references/machine-setup.md).

Daily commands (`nix run '.#switch'`, `.#update`, `.#check`), Nix upgrade, and
macOS recovery: [Nix Operations](skills/dotfiles/references/nix-operations.md).

## 2. Guide Index

Start with the [dotfiles skill](skills/dotfiles/SKILL.md). It links the
current setup, operations, harness, and skill-management references.
