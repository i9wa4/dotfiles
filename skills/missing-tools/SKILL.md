---
name: missing-tools
license: MIT
description: |
  USE FOR: Missing command recovery in this repo using direnv/dev shells, comma, nix run, and nix shell fallback order. DO NOT USE FOR: hook-denied commands or global installs.
---

# Missing Tools

Compatibility trigger for missing-command recovery. The durable implementation
guidance lives in `skills/programming/references/missing-tools.md`.

## Use For

- Recovering when a command is not available in the current repo shell.
- Choosing between direnv, `comma`, `nix run`, and `nix shell`.
- Avoiding global installs while still running focused validation commands.

## Do Not Use For

- Commands denied by hooks, policy, permissions, or sandboxing; report those
  denials through the Bash guidance.
- Installing tools globally with language package managers, Homebrew, or system
  package managers.
- Adding declarative packages to Nix or Home Manager; use `nix` or
  `agent-harness-engineering` as appropriate.

## Workflow

1. Confirm the failure is a missing command, not a hook or permission denial.
2. Read `skills/programming/references/missing-tools.md`.
3. Use the fallback order from that reference.
4. Report the fallback command used and any remaining risk.

## References

- `skills/programming/references/missing-tools.md`
