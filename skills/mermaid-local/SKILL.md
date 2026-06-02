---
name: mermaid-local
license: MIT
description: |
  USE FOR: Mermaid compatibility trigger for Quarto revealjs diagrams, mmdc preview, init config, CSS overrides, and layout checks. Detailed owner: diagramming.
---

# Mermaid Local

Compatibility trigger for Mermaid-specific diagram tasks. The durable
implementation guidance now lives in
`skills/diagramming/references/mermaid.md`.

## 1. Use For

- Mermaid diagrams in Quarto revealjs `.qmd` files.
- `mmdc` preview and rendered dimension checks.
- `%%{init}%%` configuration and revealjs CSS overrides.

## 2. Do Not Use For

- Broad diagramming work; use `diagramming`.
- Unrelated domains, broad rewrites, or generated runtime outputs.

## 3. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/diagramming/references/mermaid.md`.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## 4. Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## 5. References

- `skills/diagramming/references/mermaid.md`

## 6. Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
