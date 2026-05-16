---
name: python
license: MIT
description: |
  USE FOR: Python coding in this repo: utility edits, explicit python execution, venv selection, and file permission conventions. Detailed owner: programming. DO NOT USE FOR: generated runtime outputs.
---

# Python

Compatibility trigger for Python-specific tasks. The durable implementation
guidance now lives in `skills/programming/references/python-development.md`.

## Use For

- Python utility edits in this repo.
- Python execution, virtual environment, and file permission conventions.

## Do Not Use For

- Unrelated domains, broad rewrites outside the request, or generated runtime
  outputs.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/programming/references/python-development.md`.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- `skills/programming/references/python-development.md`
