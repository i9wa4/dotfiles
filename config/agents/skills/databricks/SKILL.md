---
name: databricks
description: |
  Databricks Expert Engineer Skill - Comprehensive guide for data engineering, machine learning infrastructure, and permission design
  Use when:
  - Running databricks CLI commands (auth, api)
  - Executing SQL queries via Databricks SQL Warehouse
  - Working with Unity Catalog permissions
  - Managing Lakeflow Jobs or Delta Lake
---

# Databricks Expert Engineer Skill

This skill provides a comprehensive guide for Databricks development.

## 1. Databricks CLI Usage

### 1.1. About warehouse_id

- Find and select one Serverless SQL Warehouse for warehouse_id
- Note: databricks CLI does not auto-read warehouse_id from config files,
  so explicitly include it in JSON each time

### 1.2. Authentication

- When `auth_type=databricks-cli` in profile, run U2M authentication first

  ```sh
  databricks auth login --host https://xxx.cloud.databricks.com --profile PROFILE_NAME
  ```

- Check authentication status

  ```sh
  databricks auth profiles
  ```

### 1.3. Basic Usage

#### Statements API (Query Execution)

```sh
# Execute query
databricks api post /api/2.0/sql/statements --profile "DEFAULT" --json '{
  "warehouse_id": "xxxxxxxxxx",
  "catalog": "catalog_name",
  "schema": "schema_name",
  "statement": "select * from table_name limit 10"
}'

# Get results (statement_id is returned from execution)
databricks api get /api/2.0/sql/statements/{statement_id} --profile "DEFAULT"
```

#### Queries API (Query Object Management)

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

### 1.4. Command Tips

1. Query execution flow
   - `post` executes query -> returns `statement_id`
   - `get` retrieves results (wait until `state` is `SUCCEEDED`)
   - For long queries, add `sleep` and retry

2. Error handling
   - `state: CLOSED`: Result retrieval was too slow. Get earlier
   - `state: FAILED`: SQL error. Check error_message
   - `state: RUNNING`: Still executing. Wait and retry `get`
   - Timeout: For large data, use `limit` to verify

3. Reading results
   - `data_array`: Actual data (2D array)
   - `schema.columns`: Column names and type info
   - `total_row_count`: Total count (shown even with limit)
   - `state`: Query execution state

4. Parameterized queries

```sh
databricks api post /api/2.0/sql/statements --profile "DEFAULT" --json '{
  "warehouse_id": "xxxxxxxxxx",
  "statement": "select * from table where date >= :start_date",
  "parameters": [{"name": "start_date", "value": "2025-01-01", "type": "DATE"}]
}'
```

## 2. Well-Architected Lakehouse Framework

Consists of 7 pillars:

### 2.1. Data and AI Governance

Policies and practices to securely manage data and AI assets.
Minimize data copies with unified governance solution.

### 2.2. Interoperability and Usability

Consistent user experience and seamless integration with external systems.

### 2.3. Operational Excellence

Processes supporting continuous production operations.

### 2.4. Security, Privacy, and Compliance

Implement safeguards against threats.

### 2.5. Reliability

Ensure disaster recovery capabilities.

### 2.6. Performance Efficiency

Adaptability to workload changes.

### 2.7. Cost Optimization

Cost management to maximize value delivery.

## 3. Unity Catalog

### 3.1. Basic Concepts

- "Define once, secure everywhere" approach
- Unified access control policies across multiple workspaces
- ANSI SQL compliant permission management

### 3.2. Object Model

3-level namespace: `catalog.schema.table`

1. Catalog layer: Data isolation unit (by department, etc.)
2. Schema layer: Logical group containing tables, views, volumes
3. Object layer: Tables, views, volumes, functions, models

### 3.3. Permission Management

- Users cannot access data by default
- Explicit permission grants required
- Permissions inherit from parent to child (catalog -> schema -> table)

```sql
-- Check permissions
SHOW GRANTS ON SCHEMA main.default;

-- Grant permissions
GRANT CREATE TABLE ON SCHEMA main.default TO `finance-team`;

-- Revoke permissions
REVOKE CREATE TABLE ON SCHEMA main.default FROM `finance-team`;
```

### 3.4. Best Practices

- Managed tables/volumes recommended
  (Delta Lake format, full lifecycle management)
- Catalog isolation across workspaces possible
- Independent managed storage location per catalog recommended

## 4. Data Engineering

### 4.1. Lakeflow Solution

Unifies data ingestion, transformation, and orchestration.

- Lakeflow Connect: Simplifies data ingestion
- Lakeflow Spark Declarative Pipelines (SDP): Declarative pipeline framework
- Lakeflow Jobs: Workflow automation

### 4.2. Delta Lake

- Parquet data files with file-based transaction log
- ACID transactions
- Time travel functionality
- Optimizations: liquid clustering, data skipping,
  file layout optimization, vacuum

### 4.3. Lakeflow Jobs

Task types:

- Notebook tasks
- Pipeline tasks
- Python script tasks

Triggers:

- Time-based (e.g., daily at 2 AM)
- Event-based (on new data arrival)

Limits:

- Workspace: Max 2000 concurrent task executions
- Saved jobs: Max 12000
- Tasks per job: Max 1000

## 5. Machine Learning Infrastructure

### 5.1. MLflow

- Core tool for experiment tracking and model management
- Dedicated features for GenAI

### 5.2. Feature Store

- Feature management system
- Automatic data pipelines and feature discovery

### 5.3. Model Serving

- Deploy custom models and LLMs as REST endpoints
- Auto-scaling and GPU support

## 6. Security

### 6.1. Authentication and Access Control

- SSO configuration
- Multi-factor authentication
- Access control lists

### 6.2. Network Security

- Private connectivity
- Serverless egress control
- Firewall settings
- VPC management

### 6.3. Data Encryption

- Encryption at rest and in transit
- Customer-managed keys
- Inter-cluster communication encryption
- Automatic credential masking

## 7. SQL Warehouse

### 7.1. Serverless SQL Warehouse Benefits

- Instant and elastic compute
- Auto-scaling
- Minimal management (Databricks handles capacity)
- Low total cost of ownership

## 8. Schema Discovery and Validation

### 8.1. Pre-Query Validation Rule

- YOU MUST: Run DESCRIBE before executing SELECT on unfamiliar tables
- YOU MUST: Verify exact column names and case before writing queries

```sql
-- Check table columns first
DESCRIBE TABLE catalog.schema.table_name;

-- Then write your query using verified column names
SELECT column_name FROM catalog.schema.table_name;
```

### 8.2. Schema Discovery Commands

```sql
-- Basic column info
DESCRIBE TABLE catalog.schema.table_name;

-- Extended info (types, nullability, comments)
DESCRIBE EXTENDED catalog.schema.table_name;

-- List tables in schema
SHOW TABLES IN catalog.schema;

-- Table properties and metadata
DESCRIBE DETAIL catalog.schema.table_name;
```

### 8.3. Common Gotchas

| Issue               | Cause                          | Prevention                    |
| ------------------- | ------------------------------ | ----------------------------- |
| Column name case    | Databricks preserves case      | Use DESCRIBE before query     |
| Data type mismatch  | Implicit conversion fails      | Check column types explicitly |
| NULL handling       | Unexpected NULL in aggregation | Use COALESCE or filter NULLs  |
| Timestamp precision | TIMESTAMP vs TIMESTAMP_NTZ     | Verify type before comparison |

### 8.4. Knowledge Accumulation

When encountering schema-related issues, update this skill with:

- Universal patterns (case sensitivity, type coercion rules)
- Common column naming conventions in Unity Catalog
- Databricks-specific SQL behaviors

NOTE: Do not include project-specific table names or business logic.
Keep entries generalizable across environments.

## 9. VARIANT Type and JSON Operations

### 9.1. VARIANT Type (Runtime 15.3+)

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

### 9.2. JSON Access Patterns

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

## 10. Dashboard API (Lakeview)

### 10.1. Important Changes (2026)

- **Legacy Dashboard API**: Deprecated (access disabled 2026-01-12)
- **Migration deadline**: 2026-03-02
- **New API**: Lakeview API (`/api/2.0/lakeview/dashboards`)

### 10.2. Dashboard Visualization Limitations

**AI/BI Dashboard (Lakeview):**

- ❌ No custom HTML/JavaScript
- ❌ No client-side JSON parsing
- ✅ 20+ predefined visualization types
- ✅ Query parameters for interactivity

**Recommendation:** Parse JSON in SQL (server-side) before visualization

## 11. dbt Integration Patterns

### 11.1. Auto-Schema Evolution with Jinja

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

### 11.2. Recommended Architecture

```text
Source → Bronze (VARIANT) → Silver (dbt expand) → Gold (business logic)
```

- **Bronze**: VARIANT型でRaw JSON保存
- **Silver**: dbt Jinjaマクロで必要なフィールドを展開
- **Gold**: ビジネスロジック、アグリゲーション

## 12. Reference Links

- Official docs: <https://docs.databricks.com/>
- Unity Catalog: <https://docs.databricks.com/en/data-governance/unity-catalog/>
- Lakeflow Jobs: <https://docs.databricks.com/en/jobs/>
- MLflow: <https://docs.databricks.com/en/mlflow/>
- Delta Lake: <https://docs.databricks.com/en/delta/>
- Security: <https://docs.databricks.com/en/security/>
- VARIANT Type: <https://docs.databricks.com/aws/en/semi-structured/variant.html>
- JSON Operations: <https://docs.databricks.com/aws/en/semi-structured/json.html>
- Colon Notation: <https://docs.databricks.com/aws/en/sql/language-manual/functions/colonsign.html>
- Queries API: <https://docs.databricks.com/api/workspace/queries>
- Lakeview Dashboards: <https://docs.databricks.com/aws/en/dashboards/>
- dbt Documentation: <https://docs.getdbt.com/>
