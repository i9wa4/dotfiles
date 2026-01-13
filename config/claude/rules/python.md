# Python Rules

## 1. Basic Rules

- NEVER: Do not pollute global Python environment
- NEVER: Do not create `uv.lock` or `.venv/` without permission

## 2. Python Virtual Environment Usage

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
