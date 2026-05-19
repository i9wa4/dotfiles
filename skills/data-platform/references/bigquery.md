# BigQuery

Repo-specific BigQuery conventions. Standard GoogleSQL syntax, `bq` CLI usage,
joins, window functions, BQML, and external tables are assumed knowledge.

## Cost Guardrails

- Use `--dry_run` before large queries.
- Avoid `SELECT *`; specify columns explicitly.
- Always filter on partition columns when querying partitioned tables.
- Do not wrap partition columns in functions when pruning matters.
- Prefer `APPROX_COUNT_DISTINCT` over `COUNT(DISTINCT)` when exact counts are
  not required.

Partition pruning example:

```sql
WHERE created_at >= '2024-01-01'
  AND created_at < '2024-01-02'
```

Avoid this shape for partition pruning:

```sql
WHERE DATE(created_at) = '2024-01-01'
```

## Table Design

- Combine date partitioning with clustering on up to four high-cardinality
  columns.
- Set `require_partition_filter = TRUE` on large tables.
- Put the smaller table on the right side of joins when broadcast optimization
  is useful.

## Pricing Reference

- On-demand analysis: `$5/TB` scanned.
- Active storage: `$0.02/GB`.
- Long-term storage: `$0.01/GB`.

## Slot Usage Check

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

## References

- BigQuery docs: <https://cloud.google.com/bigquery/docs>
- BigQuery pricing: <https://cloud.google.com/bigquery/pricing>
