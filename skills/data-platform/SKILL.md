---
name: data-platform
license: MIT
description: |
  USE FOR: Repo-local BigQuery, Databricks, dbt, restricted BigQuery/dbt safety, and cloud auth workflows. DO NOT USE FOR: harness, diagrams, or generic code.
---

# Data Platform

Owns repo-local data-platform guidance for BigQuery, Databricks, dbt,
restricted BigQuery/dbt safety, and cloud authentication workflows. Use official
provider skills for general cloud or product documentation, then apply these
repo-specific guardrails.

## 1. Use For

- BigQuery cost-aware query patterns, GoogleSQL guardrails, table design, and
  slot usage checks.
- Databricks Queries API, VARIANT/JSON patterns, dashboard API notes, dbt
  integration, and Jupyter kernel execution.
- Local dbt target setup and Databricks SQL dialect caveats.
- Restricted BigQuery/dbt safety workflows that keep local runs out of
  production schemas.
- Cloud authentication workflows that must run through a user-authenticated
  pane instead of the agent pane.

## 2. Do Not Use For

- Agent harness runtime, Home Manager agent config, hooks, postman routing, or
  installed agent outputs; use `agent-harness-engineering`.
- GitHub issue, PR, review, or public-surface mechanics; use `github`.
- Diagram authoring or export workflows; use `diagramming`.
- Generic Bash, Python, Nix, Markdown, or implementation-loop work; use
  `programming`.

## 3. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Select the focused reference below before changing files or running data
   commands.
3. For any command that can write cloud or warehouse state, verify the target,
   schema, and approval requirements before execution.
4. Keep repo-local safety constraints in focused references and keep the owner
   skill as the primary trigger surface.
5. Run the fastest focused check during iteration, then the nearest repo
   validation surface before reporting success.

## 4. References

- [BigQuery](references/bigquery.md)
- [Databricks](references/databricks.md)
- [dbt](references/dbt.md)
- [Restricted BigQuery dbt Safety](references/restricted-bigquery-dbt.md)
- [Cloud Auth](references/cloud-auth.md)
