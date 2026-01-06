---
description: "Restricted BigQuery dbt environment"
---

# restricted-bigquery-dbt-environment

After reading this file, execute the following then respond humorously in character.

## 1. Overview

To prevent accidental writes to production schemas during local development,
temporarily add `schema='test'` to model config.

## 2. Environment Setup (First Time Only)

Install dependency packages from pyproject.toml.

```bash
uv pip install --requirement pyproject.toml
```

## 3. Add schema='test' to Model

Add `schema='test'` to target model's config.

Always add at the beginning to minimize comma diff.

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

Verify schema name with compile.

```bash
uv run dbt compile --select <model_name> --profiles-dir ~/.dbt --no-use-colors
```

Confirm output contains `test` schema.

## 5. dbt run Execution

- YOU MUST: Get user permission before `dbt run`
- YOU MUST: Confirm output schema is `test`

```bash
uv run dbt run --select <model_name> --profiles-dir ~/.dbt --no-use-colors
```

## 6. dbt test Execution

```bash
uv run dbt test --select <model_name> --profiles-dir ~/.dbt --no-use-colors
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
- NEVER: Do not run dbt run without `schema='test'` (production write risk)
- YOU MUST: Verify with `git diff` that `schema='test'` is removed before commit
