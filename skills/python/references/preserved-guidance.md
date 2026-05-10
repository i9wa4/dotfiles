# Preserved Guidance

Original SKILL.md guidance before Waza compaction. Use this reference when the
concise skill needs domain-specific details.

~~~~~~~~~~~~markdown
---
name: python
license: MIT
description: |
  Python coding rules: shebang, file permissions, venv selection (uv, poetry, venv). Use when writing or running Python code in this repo.
---

# Python Rules

## 1. Python-specific Rules

- NEVER: Do not add shebang lines (`#!/usr/bin/env python3`)
- NEVER: Do not set execute permission on Python files
- YOU MUST: Always execute with explicit `python` command

## 2. Virtual Environment Usage

- `uv.lock` exists: use `uv run <command>`
- `poetry.lock` exists: create venv with `uv` per
  <https://i9wa4.github.io/blog/2025-06-08-create-uv-venv-with-poetry-pyproject-toml.html>
- Neither exists: `source .venv/bin/activate` then run commands
~~~~~~~~~~~~
