---
name: dbt-local
license: MIT
description: |
  USE FOR: dbt compatibility trigger for issue targets, Databricks SQL dialect notes, and local examples. Detailed owner: data-platform. DO NOT USE FOR: generated outputs.
---

# Dbt Local

Compatibility trigger for dbt-specific repo additions. The durable
implementation guidance now lives in `skills/data-platform/references/dbt.md`.

## Use For

- Issue-specific local dbt target setup.
- Databricks SQL dialect caveats for dbt work.
- Repo-local dbt examples.

## Do Not Use For

- Broad data-platform work; use `data-platform`.
- General dbt command basics; use official dbt skills when available.
- Unrelated domains, broad rewrites, or generated runtime outputs.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/data-platform/references/dbt.md`.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- `skills/data-platform/references/dbt.md`

## Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
