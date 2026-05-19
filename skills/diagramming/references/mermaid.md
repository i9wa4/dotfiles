# Mermaid

Use this reference for Mermaid diagrams in Quarto revealjs `.qmd` files and for
Mermaid CLI preview.

## mmdc And revealjs Differences

`%%{init}%%` `themeVariables` can work in `mmdc` output but be overridden by
revealjs CSS at render time. Quarto revealjs injects Mermaid CSS variables
after SVG generation.

Important variables:

| CSS variable               | Targets                | Default value |
| -------------------------- | ---------------------- | ------------- |
| `--mermaid-edge-color`     | signal text, loop text | `#999`        |
| `--mermaid-label-fg-color` | actor names            | `#2a76dd`     |
| `--mermaid-node-fg-color`  | alt/else labels        | `#000`        |

## revealjs Text Color Fix

Prefer overriding the CSS variables at `:root` in the Quarto
`include-in-header` block:

```css
:root {
  --mermaid-edge-color: #000000 !important;
  --mermaid-label-fg-color: #000000 !important;
  --mermaid-node-fg-color: #000000 !important;
}
```

Do not rely only on `.mermaid text { fill: #000000 !important; }` for revealjs
slides, because Mermaid is rendered client-side and CSS variables take
precedence.

## sequenceDiagram Tips

Use `mirrorActors: false` to hide duplicate bottom actors when space matters:

```mermaid
%%{init: {'theme': 'base', 'sequence': {'mirrorActors': false}}}%%
```

About 20 content lines fit on a 1920x1080 revealjs slide with
`scrollable: true` before readability suffers.

## Mermaid CLI Preview

Run Mermaid CLI through the local Nix/comma workflow:

```sh
, mmdc -i input.mmd -o output.png
```

When a system Chrome path is required, set `PUPPETEER_EXECUTABLE_PATH` for that
command. Strip code fence markers before sending content to `mmdc`.

## Layout Checks

Text review of Mermaid source is not enough for layout-sensitive changes.
Render and inspect dimensions before reporting a diagram fixed.

For `graph TD`, disconnected subgraphs tile horizontally even when spacing
directives are set. Split wide disconnected groups into separate Mermaid blocks
so they stack vertically on slides.

For rendered SVGs, inspect the `viewBox`: a width much larger than height is a
strong signal that the diagram will overflow or be unreadable.

## revealjs Shape Coloring

Useful CSS selectors for sequence diagrams:

| Element              | CSS class    |
| -------------------- | ------------ |
| Actor boxes          | `rect.actor` |
| alt/loop section bg  | `.loopLine`  |
| alt/loop label boxes | `.labelBox`  |

`alt` and `loop` blocks share `.loopLine`, so styling them differently requires
more invasive CSS.
