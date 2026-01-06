---
name: databricks-expert
description: Databricks Expert Engineer Skill - Comprehensive guide for data engineering, machine learning infrastructure, and permission design
---

# Databricks Expert Engineer Skill

This skill provides a comprehensive guide for Databricks development.

## 1. Databricks CLI Usage

### 1.1. About warehouse_id

- Find and select one Serverless SQL Warehouse for warehouse_id
- Note: databricks CLI does not auto-read warehouse_id from config files,
  so explicitly include it in JSON each time

### 1.2. Basic Usage

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

### 1.3. Command Tips

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

## 8. Detailed Documentation

See `docs/` directory for detailed documentation:

- `unity-catalog.md` - Unity Catalog details and permission management
- `data-engineering.md` - Data engineering best practices
- `machine-learning.md` - Machine learning infrastructure details
- `security.md` - Security and permission design
- `well-architected.md` - Well-Architected framework

## 9. Reference Links

- Official docs: <https://docs.databricks.com/>
- Unity Catalog: <https://docs.databricks.com/en/data-governance/unity-catalog/>
- Lakeflow Jobs: <https://docs.databricks.com/en/jobs/>
- MLflow: <https://docs.databricks.com/en/mlflow/>
- Delta Lake: <https://docs.databricks.com/en/delta/>
- Security: <https://docs.databricks.com/en/security/>
