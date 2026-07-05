---
name: programming
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Programming and systematic debugging: Bash scripts, Python code quality and Jupyter notebooks (type hints, pytest, uv, ruff, pyright), Nix package workflow, Markdown authoring, TDD/Tidy First loops, and root-cause debugging via reproducer isolation. DO NOT USE FOR: agent harness runtime, data-platform, diagramming, or GitHub workflow work.
---

# Programming

Owns repo-local implementation guidance and systematic debugging. Prefer a
narrower domain skill when one exists.

## 1. Scope

- Bash scripts and shell command design.
- Python utility edits, local execution rules, and general Python quality:
  type hints, pytest, uv/ruff/pyright tooling, Jupyter notebooks.
- General Nix package workflow, especially fetcher hash acquisition.
- Markdown authoring and formatting rules.
- Red-Green-Refactor and Tidy First implementation loops.
- Systematic debugging: reproducer isolation, working-pattern comparison, and
  root-cause analysis.

Out of scope:

- Agent harness runtime, Home Manager agent config, hooks, postman routing, or
  installed agent outputs; use `dotfiles`.
- GitHub issue, PR, review, or public-surface mechanics; use `collaboration`.
- Data-platform or diagramming workflows; use their target skills.

## 2. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
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
- [Markdown Authoring](references/markdown-authoring.md)
- [TDD And Tidy First](references/tdd-tidy-first.md)
- [Systematic Debugging](references/systematic-debugging.md)
