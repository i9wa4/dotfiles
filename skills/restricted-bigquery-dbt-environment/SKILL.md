---
name: restricted-bigquery-dbt-environment
license: MIT
description: |
  USE FOR: BigQuery dbt safety workflow: temporarily add schema='test' to avoid production writes, run dbt, remove override before commit. Use this skill when tasks need this repository-specific workflow. DO NOT USE FOR: unrelated tasks, broad rewrites outside the request, or generated runtime outputs.
---

# Restricted Bigquery Dbt Environment

**UTILITY SKILL:** Apply this skill to BigQuery dbt safety workflow: temporarily
add schema='test' to avoid production writes, run dbt, remove override before
commit. Keep the task scoped to the requested domain and preserve existing repo
conventions.

**USE FOR:** BigQuery dbt safety workflow: temporarily add schema='test' to
avoid production writes, run dbt, remove override before commit; related file
edits; verification and handoff in this skill domain.

**DO NOT USE FOR:** unrelated domains, broad rewrites outside the request,
generated runtime outputs, or replacing repo-specific source of truth.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read [Preserved Guidance](references/preserved-guidance.md) before changing
   behavior or giving detailed instructions.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- [Preserved Guidance](references/preserved-guidance.md)

## Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
