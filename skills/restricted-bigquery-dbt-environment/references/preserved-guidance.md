# Preserved Guidance

Original SKILL.md guidance before Waza compaction. Use this reference when the
concise skill needs domain-specific details.

~~~~~~~~~~~~markdown
---
name: restricted-bigquery-dbt-environment
license: MIT
description: |
  BigQuery dbt safety workflow: temporarily add schema='test' to avoid production writes, run dbt, remove override before commit.
---

# Restricted BigQuery dbt Environment

Supplements the general dbt skills for the restricted BigQuery workflow where
local dbt runs must stay out of production schemas.

## 1. Overview

To prevent accidental writes to production schemas during local development,
temporarily add `schema='test'` to the target model config before `dbt run`.

## 2. Environment Setup (First Time Only)

Follow the repo's actual Python environment, and do NOT treat
`pyproject.toml` as a requirements file.

- If `uv.lock` exists, use `<dbt-command>` = `uv run dbt`
- If `poetry.lock` exists, create the venv with `uv` per
  <https://i9wa4.github.io/blog/2025-06-08-create-uv-venv-with-poetry-pyproject-toml.html>,
  activate it, then use `<dbt-command>` = `dbt`
- If neither exists, `source .venv/bin/activate`, then use
  `<dbt-command>` = `dbt`

In this repo, there is no root `pyproject.toml`, `uv.lock`, or `poetry.lock`,
so this skill must not prescribe `uv pip install --requirement pyproject.toml`.

## 3. Add `schema='test'` to the Model

Add `schema='test'` to the target model config.

Always add it at the beginning to minimize comma diff.

```sql
{{
  config(
    schema='test',  -- <- Add this
    materialized='incremental',
    ...
  )
}}
```

This writes the model to the `test` schema.

## 4. Verification

Verify the schema name with compile.

```bash
<dbt-command> compile --select <model_name> --profiles-dir ~/.dbt --no-use-colors
```

Confirm the output contains the `test` schema.

## 5. `dbt run` Execution

- YOU MUST: Get user permission before `dbt run`
- YOU MUST: Confirm the output schema is `test`

```bash
<dbt-command> run --select <model_name> --profiles-dir ~/.dbt --no-use-colors
```

## 6. `dbt test` Execution

```bash
<dbt-command> test --select <model_name> --profiles-dir ~/.dbt --no-use-colors
```

## 7. Pre-commit Work

Remove `schema='test'` before committing.

```sql
{{
  config(
    -- schema='test',  <- Remove
    materialized='incremental',
    ...
  )
}}
```

## 8. Cautions

- NEVER: Do not commit with `schema='test'` included
- NEVER: Do not run dbt in this restricted environment unless the model is
  redirected away from production schemas
- YOU MUST: Verify with `git diff` that `schema='test'` is removed before
  commit
~~~~~~~~~~~~
