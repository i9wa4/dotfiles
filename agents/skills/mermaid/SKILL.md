---
name: mermaid
description: |
  Mermaid diagram creation and debugging for Quarto revealjs slides.
  Use when creating or editing mermaid diagrams (sequenceDiagram, flowchart, pie,
  etc.) embedded in .qmd files, previewing with mmdc, or fixing text color issues
  in revealjs output. Covers %%{init}%% config, CSS overrides, and sequenceDiagram tips.
---

# Mermaid Skill

## 1. mmdc vs revealjs Rendering Difference

`%%{init}%%` themeVariables work in mmdc PNG but are **overridden** by revealjs CSS at
render time. Quarto revealjs injects CSS vars via `mermaid-init.js defaultCSS`:

| CSS variable               | Targets                | Default value    |
| -------------------------- | ---------------------- | ---------------- |
| `--mermaid-edge-color`     | signal text, loop text | `#999` (gray)    |
| `--mermaid-label-fg-color` | actor names            | `#2a76dd` (blue) |
| `--mermaid-node-fg-color`  | alt/else labels        | `#000` (black)   |

Result: mmdc shows black text; revealjs shows faint/colored text.

## 2. Fix: Black Text in revealjs

Add CSS override to YAML `include-in-header` in `.qmd` file:

```yaml
include-in-header:
  - existing-header.html
  - text: |
      <style>
      .mermaid text { fill: #000000 !important; }
      .mermaid .label { color: #000000 !important; }
      </style>
```

- `.mermaid text` targets SVG `<text>` elements
- `.mermaid .label` targets CSS-positioned labels

## 3. Verification

mmdc-only is insufficient. Use `quarto render` + HTML inspection:

```bash
mise exec -- quarto render slides/xxx.qmd --to revealjs
# Inspect _site/slides/xxx.html — search for mermaid SVG, check fill attributes
```

Or use the webapp-testing skill (Playwright) to screenshot the rendered slide.

## 4. sequenceDiagram Tips

### 4.1. %%{init}%% Config

```
%%{init: {'theme': 'base', 'themeVariables': {'textColor': '#000000', ...}, 'sequence': {'mirrorActors': false}}}%%
```

- `mirrorActors: false` — hides the duplicate bottom actor row, saves ~3 lines

### 4.2. Slide Capacity

~20 diagram content lines fit on a 1920x1080 revealjs slide with `scrollable: true`
without overflow.

## 5. mmdc Command

Run mermaid CLI via nix comma operator:

```bash
, mmdc -i input.mmd -o output.png
```

Requires system Chrome:

```bash
PUPPETEER_EXECUTABLE_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" , mmdc -i input.mmd -o output.png
```

NOTE: Strip code fence markers — mmdc needs raw mermaid syntax (no ` ```{mermaid} ` wrapper).
