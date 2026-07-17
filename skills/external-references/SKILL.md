---
name: external-references
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Reference-only external provider packs and dormant source inventory: dbt, azure, databricks-official, obsidian, hashicorp-terraform-codegen, hashicorp-terraform-module, hashicorp-terraform-provider, google, aws, Databricks, Azure, Microsoft Foundry, Google Cloud, GCP, AWS, Terraform, HashiCorp, Obsidian, provider-pack lookup, and promotion questions. DO NOT USE FOR: repo-local guardrails, harness implementation, or making provider packs active without explicit promotion.
---

# External References

Route external provider-pack requests to dormant references without activating
the broad packs by default.

## 1. Workflow

1. Inspect `nix/home-manager/agents/shared/agent-skills.nix`.
2. Use `referenceOnlySources` as the dormant provider-pack inventory.
3. Prefer local owner skills for guardrails: `data-platform`, `programming`,
   or `dotfiles`.
4. For provider syntax not covered locally, inspect the pinned source or
   upstream docs without adding it to loader paths.
5. Promote only on an explicit active-provider-pack request.

## 2. Dormant Packs

- `databricks-official`: Databricks.
- `dbt`: dbt, dbt Labs.
- `azure`: Azure, Microsoft Foundry, Entra.
- `google`: Google Cloud, GCP, BigQuery, GKE, AlloyDB.
- `aws`: AWS, Amazon Web Services.
- `hashicorp-terraform-codegen`, `hashicorp-terraform-module`,
  `hashicorp-terraform-provider`: Terraform, HashiCorp.
- `obsidian`: Obsidian, Bases, Canvas, Markdown vault workflows.

## 3. Promotion Rules

For Claude, add a source through `i9wa4.agentSkills.extraSources` or make an
explicit repo decision to move it active. For Codex, also update both
`codexMinimalSourceNames` and `codexMinimalAllowlist`.
