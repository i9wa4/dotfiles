# Python Development

Use this reference for Python utility changes in this repo.

## Rules

- Do not add shebang lines to Python files.
- Do not set execute permission on Python files.
- Run Python code with an explicit `python` command.
- Prefer the repo's existing dependency and execution pattern over adding a new
  toolchain.

## Environment Selection

- If `uv.lock` exists, use `uv run <command>`.
- If `poetry.lock` exists, create the virtual environment with `uv` according
  to the repo's documented Poetry workflow.
- If neither lockfile exists, use the local `.venv` when the project provides
  one.

## Verification

- Run the focused unit or script-level command that exercises the changed
  behavior.
- Run formatter, linter, or pre-commit hooks already used by the changed
  Python surface.
