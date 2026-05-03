---
name: databricks-local
license: MIT
description: |
  Databricks local additions - Queries API, VARIANT/JSON, Dashboard API, dbt integration, Jupyter kernel
  Supplements the official `databricks` skill with project-specific patterns.
  Use when:
  - Working with Databricks Queries API (saved queries)
  - Handling VARIANT type or JSON operations
  - Working with Lakeview Dashboard API
  - Integrating dbt with Databricks JSON/VARIANT columns
  - Running Jupyter notebooks with Databricks kernel
---

# Databricks Local Additions

Supplements the official `databricks` skill. For CLI basics, auth, Unity
Catalog, Delta Lake, Lakeflow Jobs, ML, Security, and Schema Discovery, use the
parent `databricks` skill.

## Profile Verification

When a Databricks CLI profile name is provided but not yet confirmed working,
ALWAYS verify before incorporating it into a plan or using it in commands:

```sh
databricks --profile <name> clusters list
```

If this fails, report to the user before proceeding.
Do not assume a profile works based on the name alone.

## 1. Queries API (Query Object Management)

```sh
# Create query object (for dashboards, saved queries)
# IMPORTANT: Use warehouse_id, query_text, display_name (NOT data_source_id, query, name)
databricks api post /api/2.0/sql/queries --profile "DEFAULT" --json '{
  "warehouse_id": "xxxxxxxxxx",
  "display_name": "My Query",
  "query_text": "SELECT * FROM table_name LIMIT 10",
  "description": "Optional description"
}'

# List queries
databricks api get /api/2.0/sql/queries --profile "DEFAULT"

# Get query by ID
databricks api get /api/2.0/sql/queries/{query_id} --profile "DEFAULT"
```

**Common Mistakes:**

- ❌ `data_source_id` → ✅ `warehouse_id`
- ❌ `query` → ✅ `query_text`
- ❌ `name` → ✅ `display_name`

## 2. VARIANT Type and JSON Operations

### 2.1. VARIANT Type (Runtime 15.3+)

**Benefits:**

- 10-30x faster than JSON strings
- Schema evolution without manual updates
- No predefined schema required

**Basic Usage:**

```sql
-- Create table with VARIANT
CREATE TABLE events (
  id BIGINT,
  data VARIANT
);

-- Insert JSON data
INSERT INTO events VALUES
  (1, parse_json('{"name":"太郎","age":25}')),
  (2, parse_json('{"name":"花子","age":30,"new_field":"value"}'));

-- Query with colon notation
SELECT
  data:name::STRING AS name,
  data:age::INT AS age,
  data:new_field::STRING AS new_field  -- Auto-recognized
FROM events;
```

### 2.2. JSON Access Patterns

**Colon Notation (Recommended):**

```sql
-- Object fields
json_data:name
json_data:metadata.status

-- Array elements
json_data:tags[0]
json_data:tags[1]

-- Wildcards (all elements)
json_data:tags[*]  -- Returns array

-- Nested arrays
json_data:basket[*][0]  -- First element of each sub-array
json_data:basket[0][*]  -- All elements of first array
```

**get_json_object() Function:**

```sql
-- Basic usage
get_json_object(json_data, '$.name')
get_json_object(json_data, '$.tags[0]')
get_json_object(json_data, '$.metadata.status')

-- Limitation: Path must be STRING literal (no variables)
```

**json_object_keys() Function:**

```sql
-- Get all keys as array
SELECT json_object_keys(json_data) FROM table_name;
-- Result: ["name", "age", "tags", "metadata"]

-- Access by index (order not guaranteed)
SELECT
  json_object_keys(json_data)[0] AS first_key,
  get_json_object(json_data, '$.' || json_object_keys(json_data)[0]) AS first_value
FROM table_name;
```

**Important Notes:**

- Object field order is NOT guaranteed in JSON
- Array order IS guaranteed
- Colon notation supports type casting: `json_data:age::INT`
- Wildcards `[*]` only work with colon notation (not get_json_object)

## 3. Dashboard API (Lakeview)

### 3.1. Important Changes (2026)

- **Legacy Dashboard API**: Deprecated (access disabled 2026-01-12)
- **Migration deadline**: 2026-03-02
- **New API**: Lakeview API (`/api/2.0/lakeview/dashboards`)

### 3.2. Dashboard Visualization Limitations

**AI/BI Dashboard (Lakeview):**

- ❌ No custom HTML/JavaScript
- ❌ No client-side JSON parsing
- ✅ 20+ predefined visualization types
- ✅ Query parameters for interactivity

**Recommendation:** Parse JSON in SQL (server-side) before visualization

## 4. dbt Integration Patterns

### 4.1. Auto-Schema Evolution with Jinja

**Macro for Dynamic JSON Expansion:**

```sql
-- macros/get_json_keys.sql
{% macro get_json_keys(table_ref, json_column) %}
  {% set query %}
    SELECT DISTINCT key
    FROM {{ table_ref }},
    LATERAL variant_explode({{ json_column }})
    ORDER BY key
  {% endset %}

  {% if execute %}
    {% set results = run_query(query) %}
    {% set keys = results.columns[0].values() %}
    {{ return(keys) }}
  {% else %}
    {{ return([]) }}
  {% endif %}
{% endmacro %}
```

**dbt Model:**

```sql
-- models/staging/stg_events.sql
{% set json_keys = get_json_keys(source('bronze', 'events'), 'json_data') %}

SELECT
  id,
  {% for key in json_keys %}
  json_data:{{ key }}::STRING AS {{ key | lower }}
  {%- if not loop.last %},{% endif %}
  {% endfor %}
FROM {{ source('bronze', 'events') }}
```

**Benefits:**

- New JSON fields auto-detected on `dbt run`
- No manual model updates required
- Works with VARIANT or JSON string columns

### 4.2. Recommended Architecture

```text
Source → Bronze (VARIANT) → Silver (dbt expand) → Gold (business logic)
```

- **Bronze**: Raw JSON stored as VARIANT
- **Silver**: dbt Jinja macro expands required fields
- **Gold**: Business logic, aggregation

## 5. Databricks Jupyter Kernel

For generic Jupyter execution options, use the official `jupyter-notebook`
skill.

### 5.1. Installation

<https://github.com/i9wa4/jupyter-databricks-kernel>

```bash
uv pip install jupyter-databricks-kernel
uv run python -m jupyter_databricks_kernel.install
```

### 5.2. Execute with Databricks Kernel

```sh
uv run jupyter execute <notebook_path> --inplace --kernel_name=databricks --timeout=300
```

Required environment variables:

- `DATABRICKS_HOST`: Databricks workspace URL
- `DATABRICKS_TOKEN`: Personal Access Token
- `DATABRICKS_CLUSTER_ID`: Cluster ID

### 5.3. Notes

- For Databricks kernel, cluster startup takes 5-6 minutes if stopped
- Verify required environment variables are properly set before execution

## 6. Reference Links

- VARIANT Type:
  <https://docs.databricks.com/aws/en/semi-structured/variant.html>
- JSON Operations:
  <https://docs.databricks.com/aws/en/semi-structured/json.html>
- Colon Notation:
  <https://docs.databricks.com/aws/en/sql/language-manual/functions/colonsign.html>
- Queries API: <https://docs.databricks.com/api/workspace/queries>
- Lakeview Dashboards: <https://docs.databricks.com/aws/en/dashboards/>
- dbt Documentation: <https://docs.getdbt.com/>
- jupyter-databricks-kernel:
  <https://github.com/i9wa4/jupyter-databricks-kernel>
- Jupyter nbclient: <https://nbclient.readthedocs.io/>
