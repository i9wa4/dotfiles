---
name: external-references
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Reference-only provider-pack lookup and promotion decisions for
  Cloudflare, dbt, Azure, Databricks, AWS, Terraform/HashiCorp, Google
  Workspace, and Streamlit. DO NOT USE FOR: repo guardrails, harness work,
  active promotion without explicit request, or Cloudflare security audits.
---

# External References

Dormant provider-pack references live under `~/.local/share/skills`. Direct
reads from `~/.local/share/skills/<skill-name>/*` need no promotion; promote
only when the user asks to make a pack active/invokable.

## 1. Workflow

1. Read matching bodies under `~/.local/share/skills/<skill-name>`.
2. Enumerate available reference skill names from
   `~/.local/share/skills/.i9wa4-agent-skills-reference-only.manifest` when the
   generated name is unclear.
3. Use `nix/home-manager/agents/shared/agent-skills.nix` `referenceOnlySources`
   only when the generated tree is missing or source verification is needed.
4. Prefer local owner skills for guardrails: `data-platform`, `programming`,
   or `dotfiles`.
5. Promote only on an explicit active-provider-pack request.

## 2. Dormant Packs

`cloudflare-skills`, `databricks-official`, `dbt`, `azure`, `google`, `aws`,
`hashicorp-terraform`, `googleworkspace-cli`, and `streamlit`. Use active
`security-audit` for Cloudflare security audits.

## 3. Direct Read Example

For Terraform, read `~/.local/share/skills/terraform-style-guide/SKILL.md` and
use the manifest for related Terraform names. `hashicorp-terraform` is an
inventory group, not necessarily a directory.

## 4. Promotion Rules

For Claude, add a source through `i9wa4.agentSkills.extraSources` or an
explicit repo decision. For Codex, also update `codexMinimalSourceNames` and
`codexMinimalAllowlist`.
