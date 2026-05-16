---
name: agent-harness-engineering
license: MIT
description: |
  USE FOR: Dotfiles agent harness: Claude Code/Codex CLI config, Nix/HM settings, hooks, MCP, skill installation pipeline (Nix-side), postman routing. Use this skill when tasks need this repository-specific workflow. DO NOT USE FOR: unrelated tasks, broad rewrites outside the request, or generated runtime outputs.
---

# Agent Harness Engineering

**UTILITY SKILL:** Apply this skill to Dotfiles agent harness: Claude Code/Codex
CLI config, Nix/HM settings, hooks, MCP, skill installation pipeline (Nix-side),
postman routing. Keep the task scoped to the requested domain and preserve
existing repo conventions.

**USE FOR:** Dotfiles agent harness: Claude Code/Codex CLI config, Nix/HM
settings, hooks, MCP, skill installation pipeline (Nix-side), postman routing;
related file edits; verification and handoff in this skill domain.

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
- [Claude Code](references/claude-code.md)
- [Claude Workspace Trust](references/claude-workspace-trust.md)
- [Codex CLI](references/codex-cli.md)
- [Changelog Tracking](references/changelog-tracking.md)
- [Orchestrator Runbook](references/orchestrator-runbook.md)

## Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
