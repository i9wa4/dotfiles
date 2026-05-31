---
name: programming
license: MIT
description: |
  USE FOR: Repo-local programming tasks: Bash scripts, Python utilities, Nix package workflow, Markdown authoring, and TDD/Tidy First loops in this repo. DO NOT USE FOR: agent harness runtime, data-platform, diagramming, or GitHub workflow work.
---

# Programming

Owns repo-local implementation guidance for small code and documentation
changes. Use more specific domain skills when they exist; otherwise use this
skill for Bash, Python, general Nix package workflow, Markdown, and
implementation-loop discipline.

## Use For

- Bash scripts and shell command design.
- Python utility edits and local execution rules.
- General Nix package workflow, especially fetcher hash acquisition.
- Markdown authoring and formatting rules.
- Red-Green-Refactor and Tidy First implementation loops.

## Do Not Use For

- Agent harness runtime, Home Manager agent config, hooks, postman routing, or
  installed agent outputs; use `agent-harness-engineering`.
- GitHub issue, PR, review, or public-surface mechanics; use `github`.
- Data-platform or diagramming workflows; use their target skills.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Select the focused reference below before changing files.
3. Keep structural and behavioral edits separate when practical.
4. Run the fastest focused check during iteration, then the nearest repo
   validation surface before reporting success.
5. Report changed files, verification, residual Waza findings, and remaining
   risk.

## References

- [Bash Scripting](references/bash-scripting.md)
- [Python Development](references/python-development.md)
- [Nix Package Workflow](references/nix-package-workflow.md)
- [Markdown Authoring](references/markdown-authoring.md)
- [TDD And Tidy First](references/tdd-tidy-first.md)
