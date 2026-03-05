---
name: dbt-local
description: |
  Local dbt additions - Issue-specific target setup and Databricks SQL dialect notes.
  Supplements the official `dbt` and `running-dbt-commands` skills.
  Use when:
  - Setting up Issue-specific targets in profiles.yml
  - Working with Databricks SQL dialect quirks in dbt
---

# dbt Local Additions

Supplements the official `dbt` skill. For command basics (`debug`, `compile`,
`run`, `test`, `show`), selectors, verification procedures, and ad-hoc queries,
use the official `dbt` and `running-dbt-commands` skills.

## 1. Issue Work Target Setup

Always set up Issue-specific target before `dbt run` during Issue work.

### 1.1. Setup Procedure

1. Read `~/.dbt/profiles.yml` and check existing settings
2. Add Issue-specific target if not exists, based on existing `dev` target

```yaml
my_databricks_dbt:
  outputs:
    dev:
      # Existing settings...
    issue_123: # Name based on issue number
      catalog: dbt_dev_{username} # Same as dev
      host: dbc-xxxxx.cloud.databricks.com # Same as dev
      http_path: /sql/1.0/warehouses/xxxxx # Same as dev
      schema: dwh_issue_123 # Include issue number in schema name
      threads: 1
      token: dapixxxxx # Same as dev
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

### 1.2. Notes

- Keep target name and schema name consistent with issue number
- Manually delete unused schemas after work completion
- Intermediate layer auto-generates as `{schema}_dbt_intermediates`

## 2. Databricks SQL Dialect

- Full-width column names require backticks
- Column names and catalog names with hyphens require backticks

```sql
-- Reference catalog name with hyphen
select * from `catalog-name`.schema_name.table_name;

-- Reference full-width column name
select `full-width column` from table_name;
```
