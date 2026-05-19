---
name: bigquery-local
license: MIT
description: |
  USE FOR: BigQuery compatibility trigger for cost guardrails, GoogleSQL, table design, and slot checks. Detailed owner: data-platform. DO NOT USE FOR: generated outputs.
---

# Bigquery Local

Compatibility trigger for BigQuery-specific tasks. The durable implementation
guidance now lives in `skills/data-platform/references/bigquery.md`.

## Use For

- BigQuery cost-aware query patterns in this repo.
- GoogleSQL guardrails and partition/filter conventions.
- Partitioned and clustered table design.
- Slot usage checks.

## Do Not Use For

- Broad data-platform work; use `data-platform`.
- Unrelated domains, broad rewrites, or generated runtime outputs.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/data-platform/references/bigquery.md`.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- `skills/data-platform/references/bigquery.md`

## Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
