---
name: databricks-local
license: MIT
description: |
  USE FOR: Databricks compatibility trigger for Queries API, VARIANT/JSON, dashboards, dbt, and Jupyter. Detailed owner: data-platform. DO NOT USE FOR: generated outputs.
---

# Databricks Local

Compatibility trigger for Databricks-specific tasks. The durable
implementation guidance now lives in
`skills/data-platform/references/databricks.md`.

## Use For

- Databricks Queries API object management.
- VARIANT/JSON usage patterns.
- AI/BI dashboard API notes.
- Databricks/dbt integration and Jupyter kernel execution.

## Do Not Use For

- Broad data-platform work; use `data-platform`.
- Unrelated domains, broad rewrites, or generated runtime outputs.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/data-platform/references/databricks.md`.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- `skills/data-platform/references/databricks.md`

## Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
