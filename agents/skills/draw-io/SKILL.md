---
name: draw-io
description: draw.io diagram creation, editing, and review. Use for .drawio XML editing, PNG conversion, layout adjustment, and AWS icon usage.
---

# draw.io Diagram Skill

## 1. Basic Rules

- Edit only `.drawio` files
- Do not directly edit `.drawio.png` files
- Use auto-generated `.drawio.png` by pre-commit hook in slides

## 2. Font Settings

For diagrams used in Quarto slides,
specify `defaultFontFamily` in mxGraphModel tag:

```xml
<mxGraphModel defaultFontFamily="Noto Sans JP" ...>
```

Also explicitly specify `fontFamily` in each text element's style attribute:

```xml
style="text;html=1;fontSize=27;fontFamily=Noto Sans JP;"
```

## 3. Conversion Commands

See conversion script at [scripts/convert-drawio-to-png.sh](scripts/convert-drawio-to-png.sh).

```sh
# Convert all .drawio files
mise exec -- pre-commit run --all-files

# Convert specific .drawio file
mise exec -- pre-commit run convert-drawio-to-png --files assets/my-diagram.drawio

# Run script directly (using skill's script)
bash ~/.claude/skills/draw-io/scripts/convert-drawio-to-png.sh assets/diagram1.drawio
```

NOTE: For draw.io CLI flags and export options, see the `drawio-skills` skill.

## 4. Layout Adjustment

- Open `.drawio` in text editor; find `mxCell` by `value` attribute
- Adjust `mxGeometry`: `x` (left), `y` (top), `width`, `height`
- Element center = `y + (height / 2)`; match centers to align elements

## 5. Color Palette and Layout Patterns

Auto-updatable reference files (see Section 10 for update protocol):

- [Color Palette](references/color-palette.md) - Material Design colors and usage rules
- [Layout Guidelines](references/layout-guidelines.md) - Pattern catalog (A-K) and AWS layout rules

## 6. Design Principles

### 6.1. Slide Diagram Constraints (1920x1080)

- YOU MUST: Set `page="0"` (transparent background)
- YOU MUST: Use `fontFamily=Noto Sans JP` for all text
- YOU MUST: Limit to 1-3 accent colors per diagram
- YOU MUST: Include a takeaway bar at the bottom (Note or Primary color)

### 6.2. Core Principles

- Clarity, consistency, accuracy
- Label all elements; use arrows for direction (prefer unidirectional)
- One concept per diagram; split complex systems into staged diagrams
- Ensure color contrast; use patterns in addition to colors

### 6.3. Related Diagram Set Consistency

- YOU MUST: Use identical canvas width, colors, fonts, stroke width across related diagrams
- Define diagram set specification before creating any diagram
- Verify side-by-side after completion

## 7. Best Practices

### 7.1. General

- Remove `background="#ffffff"` (transparent adapts to themes)
- Font size: 1.5x standard (~18px) for readability
- Japanese text: allow 30-40px per character width
- Canvas size: 800px or less for Zenn articles, 1920x1080 for slides
- Scale canvas proportionally when increasing font size

### 7.2. Arrows

- Structural arrows (flowcharts, ER): place in XML right after Title (back layer)
- Badge-associated arrows (navigation): place last in XML (top layer)
- Keep arrow start/end at least 20px from label bottom edge
- For text elements, use explicit `sourcePoint`/`targetPoint` (exitX/exitY don't work)
- Edge label offset: `<mxPoint x="0" y="-40" as="offset"/>` (negative = above)
- Bidirectional: set `startArrow=classic;endArrow=classic;startFill=1;endFill=1`
- Minimum 80-100px spacing to avoid arrowhead overlap (`><` shape)
- Standardize arrow lengths within a diagram
- Edge labels: place `<mxCell>` at END of `<root>` with `labelBackgroundColor=#ffffff`

### 7.3. Containers and Spacing

- Internal elements: at least 30px margin from frame boundary
- Parent container label clearance: first child Y >= `parent.y + spacingTop + fontSize + 10`
  (for fontSize >= 24px, use fontSize \* 1.5)
- Label padding: add `spacingLeft=8;spacingTop=8` to box styles
- Maintain vertical symmetry in containers (top margin = bottom margin)
- Align elements on container's horizontal centerline

### 7.4. Labels

- Service name only: 1 line; with supplementary info: 2 lines using `&lt;br&gt;`
- Remove redundant notation (e.g., "ECR Container Registry" -> "ECR")
- Remove decorative icons irrelevant to context

### 7.5. Z-Order (XML document order = render order)

| Element type      | Position in XML           | Reason         |
| ----------------- | ------------------------- | -------------- |
| Structural arrows | After title, before boxes | Back layer     |
| Background/boxes  | Middle                    | Base layer     |
| Badges            | After boxes               | Front layer    |
| Badge arrows      | After badges              | Top layer      |
| Edge labels       | END of `<root>`           | Always visible |

## 8. Reference

- [Color Palette](references/color-palette.md) - auto-updatable
- [Layout Guidelines](references/layout-guidelines.md) - auto-updatable
- [AWS Icons](references/aws-icons.md)
- [AWS Icon Search Script](scripts/find_aws_icon.py)

```sh
python ~/.claude/skills/draw-io/scripts/find_aws_icon.py ec2
```

## 9. Workflow and Checklist

### 9.1. Phase 0: Design

- [ ] One concept per diagram
- [ ] Reference images viewed and understood
- [ ] Diagram set spec defined (canvas size, colors, fonts, stroke width)

### 9.2. Phase 1: Layout Calculation

- [ ] Parent container sizes calculated
- [ ] Child element clearance calculated (see 7.3)
- [ ] Symmetric placement coordinates calculated
- [ ] Arrow z-order determined (see 7.5)

### 9.3. Phase 2: Implementation

- [ ] `page="0"` set (transparent background)
- [ ] Font size appropriate; canvas scaled proportionally
- [ ] Canvas matches target display width
- [ ] Arrows in correct z-order
- [ ] Label padding set (`spacingLeft`/`spacingTop`)
- [ ] AWS icons latest version (`mxgraph.aws4.*`)

### 9.4. Phase 3: Verification (PNG Review)

Convert and visually verify with Read tool:

```sh
drawio -x -f png -s 2 -t -o output.drawio.png input.drawio
```

- NEVER claim "no issues" based solely on XML; ALWAYS verify PNG visually
- If unable to view reference images, report honestly

Verify:

- [ ] Elements not overflowing frames (30px+ margin)
- [ ] Arrows not overlapping labels or penetrating boxes
- [ ] Bidirectional arrows appear as `<-->` not `><`
- [ ] Text not truncated or cut off
- [ ] Uniform arrow lengths
- [ ] Symmetric badge/arrow placement
- [ ] Parent label and child elements not intersecting
- [ ] Edge labels visible (at END of `<root>`)
- [ ] Diagram set consistency (side-by-side)

If issues found, fix XML and repeat from conversion step.

## 10. Self-Update Protocol

Auto-updatable files that evolve as new `.drawio` files are created:

| File                              | Stability  |
| --------------------------------- | ---------- |
| `references/color-palette.md`     | Updatable  |
| `references/layout-guidelines.md` | Updatable  |
| `SKILL.md` section 7              | Appendable |
| `SKILL.md` section 9              | Appendable |

Trigger after creating/editing `.drawio` files:

1. Parse style attributes from all mxCell elements
2. Detect new colors -> add to color-palette.md with semantic role
3. Detect new layout patterns -> add to layout-guidelines.md
4. Detect new best practices or checklist items -> append to SKILL.md
5. Update metadata (last updated, source files)

## 11. Image Display in reveal.js Slides

Add `auto-stretch: false` to YAML header for correct image display on mobile:

```yaml
format:
  revealjs:
    auto-stretch: false
```
