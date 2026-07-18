# Python Quality

General Python code quality, testing, and tooling guidance for any project.

**DO NOT USE FOR:** running Python already in this repo (`programming` owns
that); Databricks-specific guidance (`data-platform` owns local guardrails;
external Databricks provider skill packs are reference-only unless promoted).

## 1. Code Quality

- Prefer composition over inheritance and pure functions where practical.
- Pick the simplest solution for the common case; don't design for
  hypothetical future requirements.
- Require type hints on function signatures.
- Use Google-style docstrings on public functions, classes, and modules.
- Keep functions single-purpose.

## 2. Error Handling

- Catch specific exception types; never use a bare `except:`.
- Validate inputs at function entry, not deep in the call stack.
- Raise with a message naming what was invalid.

## 3. Testing

- Use `pytest`, not `unittest`.
- Put tests under `./tests/`, mirroring the source layout.
- Write or update tests alongside the code they cover.

## 4. Environment and Tooling

- Use `uv` (`uv sync`, `uv run`, `uv add`/`uv remove`) instead of
  `pip`/`venv`/`conda`; `pyproject.toml` is the dependency source of truth,
  not `requirements.txt`.
- Use `ruff` for both linting and formatting; it replaces `flake8`, `black`,
  and `isort`.
- Use `pyright` for type checking, not `mypy`.

## 5. Review Output

```text
### [High/Medium/Low confidence] Issue Title

- File: `path/to/file.py:line_number`
- Problem: concrete description
- Suggestion: specific fix
```
