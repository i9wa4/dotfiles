---
name: dbt-expert
description: dbt Expert Engineer Skill - Comprehensive guide for dbt development best practices, command execution, and environment configuration
---

# dbt Expert Engineer Skill

This skill provides a comprehensive guide for dbt development.

## 1. dbt Command Basics

### 1.1. Required Options

Always specify these options with dbt commands:

```sh
--profiles-dir ~/.dbt --no-use-colors
```

### 1.2. Connection Verification

Always verify connection at work start:

```sh
dbt debug --profiles-dir ~/.dbt --no-use-colors
```

### 1.3. Ad-hoc Query Execution

Use `dbt show` command for ad-hoc queries in dbt:

```sh
# Basic query execution
dbt show --inline "select 1 as test, current_timestamp() as now" --profiles-dir ~/.dbt --no-use-colors

# Specify row limit (default is 5)
dbt show --inline "select * from table_name" --limit 10 --profiles-dir ~/.dbt --no-use-colors

# Reference dbt models
dbt show --inline "select * from {{ ref('model_name') }}" --profiles-dir ~/.dbt --no-use-colors

# Direct reference using catalog.schema.table format
dbt show --inline "select * from catalog_name.schema_name.table_name" --limit 3 --profiles-dir ~/.dbt --no-use-colors
```

Notes:

- Explicit LIMIT in query conflicts with `--limit` option and causes error
- DDL commands (SHOW statements, etc.) cause syntax error due to auto-LIMIT

## 2. Verification Procedures

### 2.1. Verification When dbt run is Prohibited

Verification steps when `dbt run` cannot be executed to avoid production impact:

1. Edit model
2. Generate SQL with `dbt compile --profiles-dir ~/.dbt --no-use-colors`
3. Get generated SQL from `target/compiled/`
4. Verify with `bq query` or `databricks` command (recommend using LIMIT)

### 2.2. Verification When dbt run is Allowed

Verification steps when `dbt run` is allowed
in development/sandbox environments:

1. Edit model
2. Execute `dbt run --select +model_name --profiles-dir ~/.dbt --no-use-colors`
3. Execute `dbt test --select +model_name --profiles-dir ~/.dbt --no-use-colors`
4. Query generated table directly if needed

Notes:

- Use `--select` option to limit scope
- For model AND tag conditions, use `--select "staging.target,tag:tag_name"`

## 3. Issue Work Target Setup

Always set up Issue-specific target before `dbt run` during Issue work.

### 3.1. Setup Procedure

1. Read `~/.dbt/profiles.yml` and check existing settings
2. Add Issue-specific target if not exists, based on existing `dev` target

```yaml
my_databricks_dbt:
  outputs:
    dev:
      # Existing settings...
    issue_123:  # Name based on issue number
      catalog: dbt_dev_{username}  # Same as dev
      host: dbc-xxxxx.cloud.databricks.com  # Same as dev
      http_path: /sql/1.0/warehouses/xxxxx  # Same as dev
      schema: dwh_issue_123  # Include issue number in schema name
      threads: 1
      token: dapixxxxx  # Same as dev
      type: databricks
  target: dev
```

Then switch with `--target` option when executing dbt commands

```sh
# Execute with issue_123 target
dbt run --select +model_name --target issue_123 --profiles-dir ~/.dbt --no-use-colors

# Verify connection
dbt debug --target issue_123 --profiles-dir ~/.dbt --no-use-colors
```

### 3.2. Notes

- Keep target name and schema name consistent with issue number
- Manually delete unused schemas after work completion
- Intermediate layer auto-generates as `{schema}_dbt_intermediates`

## 4. Databricks SQL Dialect

- Full-width column names require backticks
- Column names and catalog names with hyphens require backticks

```sql
-- Reference catalog name with hyphen
select * from `catalog-name`.schema_name.table_name;

-- Reference full-width column name
select `full-width column` from table_name;
```

## 5. Best Practices Documentation

`docs/` directory contains best practice documentation:

### 5.1. Project Structure

- `1-guide-overview.md` - Structure guide overview
- `2-staging.md` - Staging layer
- `3-intermediate.md` - Intermediate layer
- `4-marts.md` - Mart layer
- `5-semantic-layer.md` - Semantic layer

### 5.2. Style Guide

- `0-how-we-style-our-dbt-projects.md` - Project style overview
- `1-how-we-style-our-dbt-models.md` - Model style
- `2-how-we-style-our-sql.md` - SQL style
- `3-how-we-style-our-python.md` - Python style
- `4-how-we-style-our-jinja.md` - Jinja style
- `5-how-we-style-our-yaml.md` - YAML style

### 5.3. Materializations

- `1-guide-overview.md` - Materialization overview
- `2-available-materializations.md` - Available materializations
- `3-configuring-materializations.md` - Configuration
- `4-incremental-models.md` - Incremental models
- `5-best-practices.md` - Best practices

### 5.4. dbt Mesh

- `mesh-1-intro.md` - dbt Mesh introduction
- `mesh-2-who-is-dbt-mesh-for.md` - Target users
- `mesh-3-structures.md` - Structures
- `mesh-4-implementation.md` - Implementation
- `mesh-5-faqs.md` - FAQ

## 6. Documentation Search

```bash
python scripts/search_docs.py "<query>"
```

Options:

- `--json` - Output in JSON format
- `--max-results N` - Limit number of results (default: 10)

## 7. Response Format

```text
[Documentation-based response]

Source: [source_url]
Fetched: [fetched_at]
```
