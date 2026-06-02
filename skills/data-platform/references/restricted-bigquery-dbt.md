# Restricted BigQuery dbt Safety

Use this workflow when local dbt runs must stay out of production BigQuery
schemas.

## 1. Environment Selection

Follow the repository's actual Python environment. Do not treat `pyproject.toml`
as a requirements file.

- If `uv.lock` exists, use `uv run dbt`.
- If `poetry.lock` exists, create the virtual environment with `uv`, activate
  it, then use `dbt`.
- If neither exists, activate `.venv` when available, then use `dbt`.

This repo has no root `pyproject.toml`, `uv.lock`, or `poetry.lock`, so do not
prescribe `uv pip install --requirement pyproject.toml`.

## 2. Redirect Local Writes

Temporarily add `schema='test'` at the beginning of the target model config
before a local run.

```sql
{{
  config(
    schema='test',
    materialized='incremental',
  )
}}
```

Compile first and confirm the rendered relation uses the `test` schema:

```sh
<dbt-command> compile --select <model_name> --profiles-dir <profiles_dir> --no-use-colors
```

## 3. Running dbt

- Get explicit user approval before `dbt run`.
- Confirm the output schema is redirected away from production before running.
- Prefer focused selectors.

```sh
<dbt-command> run --select <model_name> --profiles-dir <profiles_dir> --no-use-colors
<dbt-command> test --select <model_name> --profiles-dir <profiles_dir> --no-use-colors
```

## 4. Before Commit

Remove the temporary `schema='test'` override before committing and verify the
diff.

Never commit a temporary schema override.
