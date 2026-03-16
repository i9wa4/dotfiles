---
name: bigquery-local
description: |
  BigQuery local additions - cost-aware query patterns and project conventions.
  Supplements general BigQuery knowledge with guardrails.
  Use when:
  - Running bq commands
  - Writing GoogleSQL queries
  - Designing partitioned/clustered tables
---

# BigQuery Local Skill

Project-specific BigQuery conventions. Standard GoogleSQL syntax, bq CLI
usage, JOIN patterns, window functions, BQML, and external tables are
assumed knowledge.

## 1. Cost Guardrails

- YOU MUST: Use `--dry_run` before large queries
- YOU MUST: Avoid `SELECT *`; specify columns explicitly
- YOU MUST: Always filter on partition columns
- IMPORTANT: Partition pruning fails when functions wrap the partition column
  - Bad: `WHERE DATE(created_at) = '2024-01-01'`
  - Good: `WHERE created_at >= '2024-01-01' AND created_at < '2024-01-02'`
- IMPORTANT: Use `APPROX_COUNT_DISTINCT` over `COUNT(DISTINCT)` when exact
  counts are not required

## 2. Table Design Conventions

- Combine partitioning (date) + clustering (up to 4 high-cardinality columns)
- Set `require_partition_filter = TRUE` on large tables
- Put smaller table on right side of JOIN (broadcast optimization)

## 3. Pricing Reference

- On-demand: $5/TB scanned
- Storage: Active $0.02/GB, Long-term $0.01/GB

## 4. Slot Usage Check

```sql
SELECT
  job_id,
  total_bytes_processed,
  total_slot_ms,
  TIMESTAMP_DIFF(end_time, start_time, SECOND) AS duration_sec
FROM `region-us`.INFORMATION_SCHEMA.JOBS
WHERE creation_time > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
ORDER BY total_slot_ms DESC
LIMIT 10;
```

## 5. Reference Links

- Official docs: <https://cloud.google.com/bigquery/docs>
- Pricing: <https://cloud.google.com/bigquery/pricing>
