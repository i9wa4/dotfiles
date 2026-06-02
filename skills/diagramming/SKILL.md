---
name: diagramming
license: MIT
description: |
  USE FOR: draw.io and Mermaid diagram authoring, preview, export, layout, color, and asset workflows in this repo. DO NOT USE FOR: data-platform or generic coding tasks.
---

# Diagramming

Owns repo-local diagramming guidance for draw.io and Mermaid workflows. Use this
skill for diagram source edits, preview/export decisions, layout checks,
color/asset conventions, and diagram-focused validation.

## 1. Use For

- draw.io `.drawio` source creation, editing, review, and export.
- draw.io layout, color palette, shape vocabulary, and AWS icon usage.
- Mermaid diagrams in Quarto revealjs `.qmd` files.
- Mermaid CLI preview, `%%{init}%%` configuration, CSS overrides, and layout
  validation.
- Diagram-focused scripts and reference assets.

## 2. Do Not Use For

- Data-platform workflows; use `data-platform`.
- GitHub issue, PR, review, or public-surface mechanics; use `github`.
- Generic Bash, Python, Nix, Markdown, or implementation-loop work; use
  `programming`.
- Agent harness runtime, hooks, postman routing, or installed agent outputs;
  use `agent-harness-engineering`.

## 3. Workflow

1. Inspect the diagram source, nearby conventions, and `git status`.
2. Choose the focused reference below before editing or validating diagrams.
3. Preserve editable source files; treat generated exports as reproducible
   outputs unless the surrounding workflow requires them.
4. Verify rendered dimensions, text contrast, and overlap when diagram layout
   changes are user-visible.
5. Run the nearest diagram or Markdown checks before reporting success.

## 4. References

- [draw.io](references/drawio.md)
- [Mermaid](references/mermaid.md)
