---
name: restricted-bigquery-dbt-environment
license: MIT
description: |
  USE FOR: Restricted BigQuery/dbt safety compatibility trigger for local schema redirection. Detailed owner: data-platform. DO NOT USE FOR: broad data-platform work or generated outputs.
---

# Restricted Bigquery Dbt Environment

Compatibility trigger for restricted BigQuery/dbt safety work. The durable
implementation guidance now lives in
`skills/data-platform/references/restricted-bigquery-dbt.md`.

## 1. Use For

- Local dbt work that must avoid production BigQuery schemas.
- Temporary schema override workflow and pre-commit removal checks.

## 2. Do Not Use For

- Broad data-platform work; use `data-platform`.
- Unrelated domains, broad rewrites, or generated runtime outputs.

## 3. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/data-platform/references/restricted-bigquery-dbt.md`.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## 4. Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## 5. References

- `skills/data-platform/references/restricted-bigquery-dbt.md`

## 6. Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
