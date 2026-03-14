---
name: drawio-local
description: draw.io diagram creation, editing, and review. Use for .drawio XML editing, PNG/SVG/PDF export, layout adjustment, and AWS icon usage.
---

# draw.io Diagram Skill

## 1. Basic Rules

- Edit only `.drawio` files
- Always commit source `.drawio`; generated exports are disposable
- Do not directly edit generated `.drawio.png`, `.drawio.svg`, or `.drawio.pdf` files
- Prefer native mxGraphModel XML over Mermaid or CSV conversions
- Use descriptive lowercase filenames with hyphens (e.g., `login-flow.drawio`)
- Use auto-generated `.drawio.png` by pre-commit hook in slides

## 2. Output Formats

| Format        | Embedded XML | Recommended use                |
| ------------- | ------------ | ------------------------------ |
| `.drawio`     | n/a          | Editable source diagram        |
| `.drawio.png` | Yes          | Docs, slides, chat attachments |
| `.drawio.svg` | Yes          | Docs, scalable output          |
| `.drawio.pdf` | Yes          | Review and print               |
| `.drawio.jpg` | No           | Last-resort lossy export       |

## 3. Font Settings

For diagrams used in Quarto slides,
specify `defaultFontFamily` in mxGraphModel tag:

```xml
<mxGraphModel defaultFontFamily="Noto Sans JP" ...>
```

Also explicitly specify `fontFamily` in each text element's style attribute:

```xml
style="text;html=1;fontSize=27;fontFamily=Noto Sans JP;"
```

## 4. Conversion Commands

See conversion script at [scripts/convert-drawio-to-png.sh](scripts/convert-drawio-to-png.sh).

```sh
# Convert all .drawio files
mise exec -- pre-commit run --all-files

# Convert specific .drawio file
mise exec -- pre-commit run convert-drawio-to-png --files assets/my-diagram.drawio

# Run script directly (using skill's script)
bash ~/.claude/skills/drawio-local/scripts/convert-drawio-to-png.sh assets/diagram1.drawio
```

NOTE: For draw.io CLI flags and export options, see the `drawio-skills` skill.

## 5. Layout Adjustment

- Open `.drawio` in text editor; find `mxCell` by `value` attribute
- Adjust `mxGeometry`: `x` (left), `y` (top), `width`, `height`
- Element center = `y + (height / 2)`; match centers to align elements

## 6. Color Palette and Layout Patterns

Auto-updatable reference files (see Section 12 for update protocol):

- [Color Palette](references/color-palette.md) - Material Design colors and usage rules
- [Layout Guidelines](references/layout-guidelines.md) - Pattern catalog (A-K) and AWS layout rules

## 7. Design Principles

### 7.1. Slide Diagram Constraints (1920x1080)

- YOU MUST: Set `page="0"` (transparent background)
- YOU MUST: Use `fontFamily=Noto Sans JP` for all text
- YOU MUST: Limit to 1-3 accent colors per diagram
- YOU MUST: Include a takeaway bar at the bottom (Note or Primary color)

### 7.2. Core Principles

- Clarity, consistency, accuracy
- Label all elements; use arrows for direction (prefer unidirectional)
- One concept per diagram; split complex systems into staged diagrams
- Ensure color contrast; use patterns in addition to colors

### 7.3. Diagram Types (Progressive Disclosure)

Choose the right abstraction level before drawing:

| Type       | Purpose                              | Typical audience     |
| ---------- | ------------------------------------ | -------------------- |
| Context    | System in its environment            | Stakeholders         |
| System     | High-level building blocks           | Architects, leads    |
| Component  | Internal structure of one block      | Developers           |
| Deployment | Infrastructure and runtime placement | DevOps, SRE          |
| Data Flow  | How data moves through the system    | Architects, security |
| Sequence   | Time-ordered interactions            | Developers, QA       |

Start at Context level; drill down only when the audience needs it.

### 7.4. Related Diagram Set Consistency

- YOU MUST: Use identical canvas width, colors, fonts, stroke width across related diagrams
- Define diagram set specification before creating any diagram
- Verify side-by-side after completion

## 8. XML Structure Rules

### 8.1. Required XML Structure

Every diagram must use native mxGraphModel XML:

```xml
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
  </root>
</mxGraphModel>
```

All normal cells live under `parent="1"` unless using container parents.

### 8.2. Edge Geometry Is Mandatory

Every edge cell must contain geometry:

```xml
<mxCell id="e1" edge="1" parent="1" source="a" target="b" style="edgeStyle=orthogonalEdgeStyle;">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

Never use self-closing edge cells.

### 8.3. Containers and Groups

Do not fake containment by placing boxes on top of bigger boxes.

- Use `parent="containerId"` for child elements
- Use `swimlane` when the container needs a visible title bar
- Use `group;pointerEvents=0;` for invisible containers
- Add `container=1;pointerEvents=0;` when using a custom shape as a container

## 9. Best Practices

### 9.1. General

- Remove `background="#ffffff"` (transparent adapts to themes)
- Font size: 1.5x standard (~18px) for readability
- Japanese text: allow 30-40px per character width
- Canvas size: 800px or less for Zenn articles, 1920x1080 for slides
- Scale canvas proportionally when increasing font size

### 9.2. Spacing and Routing

- Space nodes generously: ~200px horizontal and ~120px vertical gaps
- Use `edgeStyle=orthogonalEdgeStyle` for most technical diagrams
- Add explicit waypoints when auto-routing produces overlap or awkward bends
- Align to a coarse grid when possible

Waypoint example:

```xml
<mxCell id="e1" style="edgeStyle=orthogonalEdgeStyle;rounded=1;" edge="1" parent="1" source="a" target="b">
  <mxGeometry relative="1" as="geometry">
    <Array as="points">
      <mxPoint x="300" y="150"/>
      <mxPoint x="300" y="250"/>
    </Array>
  </mxGeometry>
</mxCell>
```

### 9.3. Arrows

- Structural arrows (flowcharts, ER): place in XML right after Title (back layer)
- Badge-associated arrows (navigation): place last in XML (top layer)
- Keep arrow start/end at least 20px from label bottom edge
- For text elements, use explicit `sourcePoint`/`targetPoint` (exitX/exitY don't work)
- Edge label offset: `<mxPoint x="0" y="-40" as="offset"/>` (negative = above)
- Bidirectional: set `startArrow=classic;endArrow=classic;startFill=1;endFill=1`
- Minimum 80-100px spacing to avoid arrowhead overlap (`><` shape)
- Standardize arrow lengths within a diagram
- Edge labels: place `<mxCell>` at END of `<root>` with `labelBackgroundColor=#ffffff`

### 9.4. Container Spacing

- Internal elements: at least 30px margin from frame boundary
- Parent container label clearance: first child Y >= `parent.y + spacingTop + fontSize + 10`
  (for fontSize >= 24px, use fontSize \* 1.5)
- Label padding: add `spacingLeft=8;spacingTop=8` to box styles
- Maintain vertical symmetry in containers (top margin = bottom margin)
- Align elements on container's horizontal centerline

### 9.5. Labels

- Service name only: 1 line; with supplementary info: 2 lines using `&lt;br&gt;`
- Remove redundant notation (e.g., "ECR Container Registry" -> "ECR")
- Remove decorative icons irrelevant to context

### 9.6. Z-Order (XML document order = render order)

| Element type      | Position in XML           | Reason         |
| ----------------- | ------------------------- | -------------- |
| Structural arrows | After title, before boxes | Back layer     |
| Background/boxes  | Middle                    | Base layer     |
| Badges            | After boxes               | Front layer    |
| Badge arrows      | After badges              | Top layer      |
| Edge labels       | END of `<root>`           | Always visible |

## 10. SVG Linting

After exporting SVG, run the bundled lint to catch overlap issues programmatically:

```sh
drawio -x -f svg -e -b 10 -o diagram.drawio.svg diagram.drawio
node ~/.claude/skills/drawio-local/scripts/check-drawio-svg-overlaps.mjs diagram.drawio.svg
```

The lint checks:

| Check                | What it catches                               |
| -------------------- | --------------------------------------------- |
| `edge-edge`          | Arrow crossings and collinear overlaps        |
| `edge-rect-border`   | Arrows running along box borders              |
| `edge-rect`          | Arrows penetrating boxes                      |
| `text-overflow(w/h)` | Text too wide or tall for its box (heuristic) |

- Input may be either `.drawio` or `.drawio.svg` (auto-resolves)
- Text overflow reads the companion `.drawio` for cell dimensions
- Lint passing does not replace visual verification

## 11. Reference

- [Color Palette](references/color-palette.md) - auto-updatable
- [Layout Guidelines](references/layout-guidelines.md) - auto-updatable
- [AWS Icons](references/aws-icons.md)
- [AWS Icon Search Script](scripts/find_aws_icon.py)
- [SVG Lint Script](scripts/check-drawio-svg-overlaps.mjs)

```sh
python ~/.claude/skills/drawio-local/scripts/find_aws_icon.py ec2
```

## 12. Workflow and Checklist

### 12.1. Phase 0: Design

- [ ] One concept per diagram
- [ ] Reference images viewed and understood
- [ ] Diagram set spec defined (canvas size, colors, fonts, stroke width)

### 12.2. Phase 1: Layout Calculation

- [ ] Parent container sizes calculated
- [ ] Child element clearance calculated (see 9.4)
- [ ] Symmetric placement coordinates calculated
- [ ] Arrow z-order determined (see 9.6)

### 12.3. Phase 2: Implementation

- [ ] `page="0"` set (transparent background)
- [ ] Edge cells contain `<mxGeometry relative="1" as="geometry"/>`
- [ ] Font size appropriate; canvas scaled proportionally
- [ ] Canvas matches target display width
- [ ] Arrows in correct z-order
- [ ] Label padding set (`spacingLeft`/`spacingTop`)
- [ ] AWS icons latest version (`mxgraph.aws4.*`)

### 12.4. Phase 3: Verification (PNG Review)

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
- [ ] SVG lint passes for routing-heavy diagrams (see Section 10)

If issues found, fix XML and repeat from conversion step.

## 13. Self-Update Protocol

Auto-updatable files that evolve as new `.drawio` files are created:

| File                              | Stability  |
| --------------------------------- | ---------- |
| `references/color-palette.md`     | Updatable  |
| `references/layout-guidelines.md` | Updatable  |
| `SKILL.md` section 9              | Appendable |
| `SKILL.md` section 12             | Appendable |

Trigger after creating/editing `.drawio` files:

1. Parse style attributes from all mxCell elements
2. Detect new colors -> add to color-palette.md with semantic role
3. Detect new layout patterns -> add to layout-guidelines.md
4. Detect new best practices or checklist items -> append to SKILL.md
5. Update metadata (last updated, source files)

## 14. Image Display in reveal.js Slides

Add `auto-stretch: false` to YAML header for correct image display on mobile:

```yaml
format:
  revealjs:
    auto-stretch: false
```
