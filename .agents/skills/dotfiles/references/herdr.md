# Herdr Harness Reference

Herdr is a terminal workspace manager for AI coding agents. This dotfiles repo
installs it as part of the shared Home Manager package set so it is available
from normal shells.

## 1. Source Of Truth

- Binary package: `llmAgents.herdr` in `nix/home-manager/default.nix`
- Upstream project: <https://github.com/ogulcancelik/herdr>
- Upstream docs: <https://herdr.dev/docs/>

The package comes from the `llm-agents.nix` flake input, matching the existing
agent CLI package source used for Claude Code, Codex CLI, and related tools.

## 2. Local Use

Start Herdr in the repository or workspace directory:

```sh
herdr
```

Herdr manages panes and long-running agent sessions in the terminal. Use the
upstream quick start and configuration docs for workflow-specific setup.
