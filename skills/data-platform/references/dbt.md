# dbt

Repo-local dbt additions. Use official dbt skills for command basics such as
`debug`, `compile`, `run`, `test`, `show`, selectors, verification procedures,
and ad-hoc queries.

## 1. Issue Work Target Setup

Set up an issue-specific target before local `dbt run` work.

1. Read the local dbt profile and check existing settings.
2. Add an issue-specific target based on the existing development target.
3. Use a target and schema name that includes the issue number.
4. Run dbt commands with `--target <issue_target>` and the appropriate
   profiles directory option for the project.

Example target shape:

```yaml
my_databricks_dbt:
  outputs:
    dev:
      # Existing development settings.
    issue_123:
      catalog: dbt_dev_{username}
      host: dbc-xxxxx.cloud.databricks.com
      http_path: /sql/1.0/warehouses/xxxxx
      schema: dwh_issue_123
      threads: 1
      token: dapixxxxx
      type: databricks
  target: dev
```

Example commands:

```sh
dbt debug --target issue_123 --profiles-dir <profiles_dir> --no-use-colors
dbt run --select +model_name --target issue_123 --profiles-dir <profiles_dir> --no-use-colors
```

Manually delete unused issue schemas after the work is complete.

## 2. Databricks SQL Dialect

Use backticks for full-width column names and names containing hyphens.

```sql
SELECT * FROM `catalog-name`.schema_name.table_name;
SELECT `full-width column` FROM table_name;
```

## 3. Examples

- Staging model example: `skills/dbt-local/examples/staging-model.sql`
