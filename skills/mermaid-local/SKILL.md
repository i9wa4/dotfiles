---
name: mermaid-local
license: MIT
description: |
  Mermaid diagram creation and debugging for Quarto revealjs slides.
  Use when creating or editing mermaid diagrams (sequenceDiagram, flowchart, pie,
  etc.) embedded in .qmd files, previewing with mmdc, or fixing text color issues
  in revealjs output. Covers %%{init}%% config, CSS overrides, and sequenceDiagram tips.
---

# Mermaid Skill

## 1. mmdc vs revealjs Rendering Difference

`%%{init}%%` themeVariables work in mmdc PNG but are **overridden** by revealjs
CSS at render time. Quarto revealjs injects CSS vars via
`mermaid-init.js defaultCSS`:

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

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'textColor': '#000000', ...}, 'sequence': {'mirrorActors': false}}}%%
```

- `mirrorActors: false` — hides the duplicate bottom actor row, saves ~3 lines

### 4.2. Slide Capacity

~20 diagram content lines fit on a 1920x1080 revealjs slide with
`scrollable: true` without overflow.

## 5. mmdc Command

Run mermaid CLI via nix comma operator:

```bash
, mmdc -i input.mmd -o output.png
```

Requires system Chrome:

```bash
PUPPETEER_EXECUTABLE_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" , mmdc -i input.mmd -o output.png
```

NOTE: Strip code fence markers — mmdc needs raw mermaid syntax (no
` ```{mermaid}` wrapper).

## 6. revealjs Text Color Fix

`%%{init}%%` themeVariables do NOT work in revealjs — revealjs applies its own
CSS variables after SVG generation, overriding any inline settings.

Working fix: override the CSS variables at `:root` level in YAML
`include-in-header`:

```css
:root {
  --mermaid-edge-color: #000000 !important; /* signal text */
  --mermaid-label-fg-color: #000000 !important; /* actor names */
  --mermaid-node-fg-color: #000000 !important; /* alt/loop labels */
}
```

Do NOT use `.mermaid text { fill: #000000 !important; }` — it is ineffective
because revealjs renders mermaid client-side and CSS vars take precedence over
static SVG fill.

Why `[alt/else labels]` appear black by default: they use
`--mermaid-node-fg-color` which defaults to `#000` — while signal text and actor
names use different vars.

## 7. Coloring alt/loop/actor in sequenceDiagram (revealjs)

CSS class names (sourced from mermaid-init.js defaultCSS):

| Element              | CSS class    | Example color           |
| -------------------- | ------------ | ----------------------- |
| Actor boxes          | `rect.actor` | `#dbeafe` (light blue)  |
| alt/loop section bg  | `.loopLine`  | `#fef3c7` (amber)       |
| alt/loop label boxes | `.labelBox`  | `#e0e7ff` (pale indigo) |

IMPORTANT limitation: `alt` and `loop` blocks share the same `.loopLine` CSS
class. They cannot be styled with different colors without more invasive CSS.

Apply via `include-in-header` `<style>` block with `!important`.

## 8. Width / Layout Issues (graph TD)

### 8.1. Disconnected Subgraphs Tile Horizontally

`graph TD` with multiple disconnected subgraphs places them side-by-side
**regardless of `%%{init}%%` layout directives**. A diagram with many groups
can produce an extremely wide output (e.g., 26:1 width:height ratio) that
overflows slides or is unreadable as an image.

`%%{init}%%` spacing/padding directives (`nodeSpacing`, `rankSpacing`,
`wrappingWidth`) control only intra-subgraph node placement. They cannot
force vertical stacking of disconnected subgraphs.

### 8.2. Fix: Split into Multiple Code Blocks

The reliable fix is to split one wide diagram into multiple separate Mermaid
code blocks — one per logical group. Each block renders independently and
stacks vertically on the slide.

```text
# Instead of one graph TD with 6 disconnected subgraphs:
# → split into 6 separate ```{mermaid} blocks, each with its own subgraph
```

This avoids the horizontal-tiling behavior entirely without requiring any
`%%{init}%%` tuning.

### 8.3. Verify Dimensions with mmdc Before Reporting Fixed

Text review of Mermaid source is **insufficient** to detect width problems.
Always render with `mmdc` and check the SVG `viewBox` for authoritative
width:height dimensions before reporting layout as correct.

```bash
PUPPETEER_EXECUTABLE_PATH="..." , mmdc -i input.mmd -o output.svg
# Check: grep viewBox output.svg
# Width >> Height indicates a horizontal-tiling problem
```
