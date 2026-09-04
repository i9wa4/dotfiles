---
name: programming
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Programming/debugging: Bash, Python/Jupyter quality, Nix package workflow, Terraform with Checkov, Markdown, TDD/Tidy First, and root-cause isolation. DO NOT USE FOR: agent harness, data-platform, diagramming, or GitHub workflow work.
---

# Programming

Owns repo-local implementation guidance and debugging. Prefer a narrower domain
skill when one exists.

## 1. Scope

- Bash scripts and shell command design.
- Python utility edits, local execution, and general Python quality:
  type hints, pytest, uv/ruff/pyright tooling, Jupyter notebooks.
- Nix package workflow, especially fetcher hash acquisition.
- Terraform infrastructure code development, plan review, and Checkov
  security/compliance scanning.
- Markdown authoring and formatting rules.
- Red-Green-Refactor and Tidy First implementation loops.
- Systematic debugging: reproducers, working-pattern comparison, root cause.

Out of scope:

- Agent harness runtime, Home Manager agent config, hooks, postman routing, or
  installed agent outputs; use `dotfiles`.
- GitHub issue, PR, review, or public-surface mechanics; use
  `dev-platform-workflow`.
- Data-platform or diagramming workflows; use their target skills.

## 2. Workflow

1. Inspect relevant files, repo conventions, and `git status`.
2. Select the focused reference below before changing files.
3. Keep structural and behavioral edits separate when practical.
4. Run the fastest focused check during iteration, then the nearest repo
   validation surface before reporting success.
5. Report changed files, verification, residual Waza findings, and remaining
   risk.

## 3. References

- [Bash Scripting](references/bash-scripting.md)
- [Python Development](references/python-development.md)
- [Python Quality](references/python-quality.md)
- [Nix Package Workflow](references/nix-package-workflow.md)
- [Terraform Development](references/terraform-development.md)
- [Markdown Authoring](references/markdown-authoring.md)
- [TDD And Tidy First](references/tdd-tidy-first.md)
- [Systematic Debugging](references/systematic-debugging.md)
