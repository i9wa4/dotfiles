---
name: programming
license: MIT
description: |
  USE FOR: Repo-local programming tasks and systematic debugging: Bash scripts, Python utilities, Nix package workflow, Markdown authoring, TDD/Tidy First loops, and root-cause debugging via reproducer isolation. DO NOT USE FOR: agent harness runtime, data-platform, diagramming, or GitHub workflow work.
---

# Programming

Owns repo-local implementation guidance and systematic debugging. Use more
specific domain skills when they exist; otherwise use this skill for Bash,
Python, general Nix package workflow, Markdown, implementation-loop discipline,
and root-cause debugging.

## 1. Use For

- Bash scripts and shell command design.
- Python utility edits and local execution rules.
- General Nix package workflow, especially fetcher hash acquisition.
- Markdown authoring and formatting rules.
- Red-Green-Refactor and Tidy First implementation loops.
- Systematic debugging: reproducer isolation, working-pattern comparison, and
  root-cause analysis.

## 2. Do Not Use For

- Agent harness runtime, Home Manager agent config, hooks, postman routing, or
  installed agent outputs; use `agent-harness-engineering`.
- GitHub issue, PR, review, or public-surface mechanics; use `github`.
- Data-platform or diagramming workflows; use their target skills.

## 3. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Select the focused reference below before changing files.
3. Keep structural and behavioral edits separate when practical.
4. Run the fastest focused check during iteration, then the nearest repo
   validation surface before reporting success.
5. Report changed files, verification, residual Waza findings, and remaining
   risk.

## 4. References

- [Bash Scripting](references/bash-scripting.md)
- [Python Development](references/python-development.md)
- [Nix Package Workflow](references/nix-package-workflow.md)
- [Markdown Authoring](references/markdown-authoring.md)
- [TDD And Tidy First](references/tdd-tidy-first.md)
- [Systematic Debugging](references/systematic-debugging.md)
