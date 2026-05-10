---
name: bigquery-local
license: MIT
description: |
  USE FOR: BigQuery local: cost-aware query patterns, GoogleSQL guardrails, project conventions, partitioned/clustered table design, slot usage. Use this skill when tasks need this repository-specific workflow. DO NOT USE FOR: unrelated tasks, broad rewrites outside the request, or generated runtime outputs.
---

# Bigquery Local

**UTILITY SKILL:** Apply this skill to BigQuery local: cost-aware query
patterns, GoogleSQL guardrails, project conventions, partitioned/clustered table
design, slot usage. Keep the task scoped to the requested domain and preserve
existing repo conventions.

**USE FOR:** BigQuery local: cost-aware query patterns, GoogleSQL guardrails,
project conventions, partitioned/clustered table design, slot usage; related
file edits; verification and handoff in this skill domain.

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
