# Databricks

Repo-specific Databricks additions. Use official Databricks skills for CLI
basics, auth, Unity Catalog, Delta Lake, Lakeflow Jobs, ML, security, and schema
discovery.

## Profile Verification

When a Databricks CLI profile name is provided but not confirmed, verify it
before incorporating it into a plan or using it in commands:

```sh
databricks --profile <name> clusters list
```

If verification fails, report the failure before proceeding.

## Queries API

For saved query objects, use `warehouse_id`, `query_text`, and `display_name`.
Do not use the older `data_source_id`, `query`, or `name` fields for this API.

```sh
databricks api post /api/2.0/sql/queries --profile "DEFAULT" --json '{
  "warehouse_id": "xxxxxxxxxx",
  "display_name": "My Query",
  "query_text": "SELECT * FROM table_name LIMIT 10",
  "description": "Optional description"
}'
```

Useful read operations:

```sh
databricks api get /api/2.0/sql/queries --profile "DEFAULT"
databricks api get /api/2.0/sql/queries/{query_id} --profile "DEFAULT"
```

## VARIANT And JSON

Prefer the VARIANT type for semi-structured data on runtimes that support it.
It avoids fixed schemas and is faster than repeatedly parsing JSON strings.

```sql
CREATE TABLE events (
  id BIGINT,
  data VARIANT
);

SELECT
  data:name::STRING AS name,
  data:age::INT AS age
FROM events;
```

Use colon notation for object fields, array elements, wildcards, and type
casts:

```sql
json_data:name
json_data:metadata.status
json_data:tags[0]
json_data:tags[*]
json_data:age::INT
```

`get_json_object()` remains useful for simple JSON strings, but its path
argument must be a string literal and does not support colon-notation
wildcards.

## Dashboard API

Use Lakeview APIs for AI/BI dashboards. Legacy dashboard APIs are deprecated.
Lakeview dashboards do not support custom HTML, client-side JavaScript, or
client-side JSON parsing. Parse JSON in SQL before visualization.

## dbt Integration

Store raw semi-structured data in bronze tables as VARIANT, expand fields in
silver dbt models, then apply business logic in gold models.

```text
Source -> Bronze (VARIANT) -> Silver (dbt expand) -> Gold (business logic)
```

Dynamic JSON expansion belongs in macros and must still be reviewed for schema
drift before production use.

## Jupyter Kernel

For Databricks-backed notebooks, install and run the Databricks Jupyter kernel
when the environment provides the required host, token, and cluster ID.

```sh
uv pip install jupyter-databricks-kernel
uv run python -m jupyter_databricks_kernel.install
uv run jupyter execute <notebook_path> --inplace --kernel_name=databricks --timeout=300
```

Cluster startup can take several minutes if the target cluster is stopped.

## References

- VARIANT: <https://docs.databricks.com/aws/en/semi-structured/variant.html>
- JSON operations:
  <https://docs.databricks.com/aws/en/semi-structured/json.html>
- Colon notation:
  <https://docs.databricks.com/aws/en/sql/language-manual/functions/colonsign.html>
- Lakeview dashboards:
  <https://docs.databricks.com/aws/en/dashboards/>
- dbt: <https://docs.getdbt.com/>
- Jupyter Databricks kernel:
  <https://github.com/i9wa4/jupyter-databricks-kernel>
