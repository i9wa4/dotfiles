---
name: external-references
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Consulting installed reference Skills for Cloudflare, dbt,
  Azure, Databricks, AWS, Terraform or Google Workspace,
  and assessing requested activation.
  DO NOT USE FOR: General web searches, installation/configuration
  changes or Cloudflare security audits.
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
4. Use the repo-local maintenance Skill for dotfiles installation/configuration
   changes. Use the active `security-audit` Skill for Cloudflare audits.
5. Assess promotion only on an explicit active-provider-pack request; make
   permanent installation/configuration changes in the owning repository.

## 2. Dormant Packs

`cloudflare-skills`, `databricks-official`, `dbt`, `azure`, `google`, `aws`,
`hashicorp-terraform` and `googleworkspace-cli`. Use active
`security-audit` for Cloudflare security audits.

## 3. Direct Read Example

For Terraform, read `~/.local/share/skills/terraform-style-guide/SKILL.md` and
use the manifest for related Terraform names. `hashicorp-terraform` is an
inventory group, not necessarily a directory.

## 4. Promotion Rules

For Claude, add a source through `i9wa4.agentSkills.extraSources` or an
explicit repo decision. For Codex, also update `codexMinimalSourceNames` and
`codexMinimalAllowlist`.
