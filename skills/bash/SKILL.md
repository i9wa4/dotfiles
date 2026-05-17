---
name: bash
license: MIT
description: |
  USE FOR: Bash scripting in this repo: scripts, shell command design, worker pane discipline, hook denial handling, and stall diagnosis. Detailed owner: programming. DO NOT USE FOR: generated runtime outputs.
---

# Bash

Compatibility trigger for Bash-specific tasks. The durable implementation
guidance now lives in `skills/programming/references/bash-scripting.md`.

## Use For

- Bash scripts and shell command design in this repo.
- Worker pane shell discipline and hook denial handling.
- Stall diagnosis for non-interactive agent commands.

## Do Not Use For

- Unrelated domains, broad rewrites outside the request, or generated runtime
  outputs.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/programming/references/bash-scripting.md`.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- `skills/programming/references/bash-scripting.md`
