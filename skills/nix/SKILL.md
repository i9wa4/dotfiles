---
name: nix
license: MIT
description: |
  USE FOR: General Nix package workflow in this repo: fetcher hash acquisition, package edits, and focused Nix checks. Detailed owner: programming. DO NOT USE FOR: agent harness runtime config.
---

# Nix

Compatibility trigger for general Nix package workflow. The durable
implementation guidance now lives in
`skills/programming/references/nix-package-workflow.md`.

## Use For

- Nix package workflow and fetcher hash acquisition.
- General package-oriented Nix edits.

## Do Not Use For

- Agent harness runtime, Home Manager agent config, hooks, or installed outputs;
  use `agent-harness-engineering`.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/programming/references/nix-package-workflow.md`.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- `skills/programming/references/nix-package-workflow.md`
