---
name: drawio-local
license: MIT
description: |
  USE FOR: draw.io compatibility trigger for XML editing, export, layout, and AWS icon workflows. Detailed owner: diagramming. DO NOT USE FOR: generated outputs.
---

# Drawio Local

Compatibility trigger for draw.io-specific diagram tasks. The durable
implementation guidance now lives in `skills/diagramming/references/drawio.md`.

## 1. Use For

- draw.io `.drawio` source creation, editing, and review.
- XML layout adjustment and native `mxGraphModel` work.
- PNG, SVG, and PDF export workflows.
- AWS icon lookup and diagram asset references.

## 2. Do Not Use For

- Broad diagramming work; use `diagramming`.
- Unrelated domains, broad rewrites, or generated runtime outputs.

## 3. Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/diagramming/references/drawio.md`.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## 4. Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## 5. References

- `skills/diagramming/references/drawio.md`
- [Aws Icons](references/aws-icons.md)
- [Color Palette](references/color-palette.md)
- [Layout Guidelines](references/layout-guidelines.md)
- [Preserved Guidance](references/preserved-guidance.md)

## 6. Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
