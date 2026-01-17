---
name: python
description: |
  Python environment and execution guide.
  Use when:
  - Running Python scripts
  - Working with uv, poetry, venv
---

# Python Skill

## 1. Python-specific Rules

- NEVER: Do not add shebang lines (`#!/usr/bin/env python3`)
- NEVER: Do not set execute permission on Python files
- YOU MUST: Always execute with explicit `python` command

## 2. Virtual Environment Usage

### 2.1. When uv.lock Exists

Use `uv` to execute Python commands:

```sh
uv run dbt debug --profiles-dir ~/.dbt --no-use-colors
```

### 2.2. When poetry.lock Exists

Create virtual environment with `uv` referring to the blog article:

- <https://i9wa4.github.io/blog/2025-06-08-create-uv-venv-with-poetry-pyproject-toml.html>

### 2.3. When uv.lock Does Not Exist

1. Activate the virtual environment

    ```sh
    source .venv/bin/activate
    ```

2. Execute Python commands

    ```sh
    dbt debug --profiles-dir ~/.dbt --no-use-colors
    ```
