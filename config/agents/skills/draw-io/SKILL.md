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

Internal command used:

```sh
drawio -x -f png -s 2 -t -o output.drawio.png input.drawio
```

| Option   | Description                |
| -------- | -------------------------- |
| `-x`     | Export mode                |
| `-f png` | PNG format output          |
| `-s 2`   | 2x scale (high resolution) |
| `-t`     | Transparent background     |
| `-o`     | Output file path           |

## 4. Layout Adjustment

### 4.1. Coordinate Adjustment Steps

1. Open `.drawio` file in text editor (plain XML format)
2. Find `mxCell` for element to adjust (search by `value` attribute for text)
3. Adjust coordinates in `mxGeometry` tag
   - `x`: Position from left
   - `y`: Position from top
   - `width`: Width
   - `height`: Height
4. Run conversion and verify

### 4.2. Coordinate Calculation

- Element center coordinate = `y + (height / 2)`
- To align multiple elements, calculate and match center coordinates

## 5. Color Palette and Layout Patterns

These are auto-updatable reference files. See section 11 for update protocol.

- [Color Palette](references/color-palette.md) - Material Design colors and usage rules
- [Layout Guidelines](references/layout-guidelines.md) - Pattern catalog (A-K) and AWS layout rules

## 6. Design Principles

### 6.0. Slide Diagram Constraints

For presentation slide diagrams (1920x1080 canvas):

- YOU MUST: Set `page="0"` (transparent background)
- YOU MUST: Use `fontFamily=Noto Sans JP` for all text
- YOU MUST: Limit to 1-3 accent colors per diagram
- YOU MUST: Include a takeaway bar at the bottom (Note or Primary color)
- NEVER: Use more than 4 color roles in a single diagram

### 6.1. Basic Principles

- Clarity: Create simple, visually clean diagrams
- Consistency: Unify colors, fonts, icon sizes, line thickness
- Accuracy: Do not sacrifice accuracy for simplification

### 6.2. Element Rules

- Label all elements
- Use arrows to indicate direction
  (prefer 2 unidirectional arrows over bidirectional)
- Use latest official icons
- Add legend to explain custom symbols

### 6.3. Accessibility

- Ensure sufficient color contrast
- Use patterns in addition to colors

### 6.4. Progressive Disclosure

Separate complex systems into staged diagrams:

| Diagram Type       | Purpose                                   |
| ------------------ | ----------------------------------------- |
| Context Diagram    | System overview from external perspective |
| System Diagram     | Main components and relationships         |
| Component Diagram  | Technical details and integration points  |
| Deployment Diagram | Infrastructure configuration              |
| Data Flow Diagram  | Data flow and transformation              |
| Sequence Diagram   | Time-series interactions                  |

### 6.5. Metadata

Include title, description, last updated, author, and version in diagrams.

## 7. Best Practices

### 7.1. Background Color

- Remove `background="#ffffff"`
- Transparent background adapts to various themes

### 7.2. Font Size

- Use 1.5x standard font size (around 18px) for PDF readability

### 7.3. Japanese Text Width

- Allow 30-40px per character
- Insufficient width causes unintended line breaks

```xml
<!-- For 10-character text, allow 300-400px -->
<mxGeometry x="140" y="60" width="400" height="40" />
```

### 7.4. Arrow Placement

- Always place arrows at back (position in XML right after Title)
- Position arrows to avoid overlapping with labels
- Keep arrow start/end at least 20px from label bottom edge

```xml
<!-- Title -->
<mxCell id="title" value="..." .../>

<!-- Arrows (back layer) -->
<mxCell id="arrow1" style="edgeStyle=..." .../>

<!-- Other elements (front layer) -->
<mxCell id="box1" .../>
```

### 7.5. Arrow Connection to Text Labels

For text elements, exitX/exitY don't work, so use explicit coordinates:

```xml
<!-- Good: Explicit coordinates with sourcePoint/targetPoint -->
<mxCell id="arrow" style="..." edge="1" parent="1">
  <mxGeometry relative="1" as="geometry">
    <mxPoint x="1279" y="500" as="sourcePoint"/>
    <mxPoint x="119" y="500" as="targetPoint"/>
    <Array as="points">
      <mxPoint x="1279" y="560"/>
      <mxPoint x="119" y="560"/>
    </Array>
  </mxGeometry>
</mxCell>
```

### 7.6. edgeLabel Offset Adjustment

Adjust offset attribute to distance arrow labels from arrows:

```xml
<!-- Place above arrow (negative value to distance) -->
<mxPoint x="0" y="-40" as="offset"/>

<!-- Place below arrow (positive value to distance) -->
<mxPoint x="0" y="40" as="offset"/>
```

### 7.7. Remove Unnecessary Elements

- Remove decorative icons irrelevant to context
- Example: If ECR exists, separate Docker icon is unnecessary

### 7.8. Labels and Headings

- Service name only: 1 line
- Service name + supplementary info: 2 lines with line break
- Redundant notation (e.g., ECR Container Registry): shorten to 1 line
- Use `&lt;br&gt;` tag for line breaks

### 7.9. Background Frame and Internal Element Placement

When placing elements inside background frames (grouping boxes),
ensure sufficient margin.

- YOU MUST: Internal elements must have at least 30px margin from frame boundary
- YOU MUST: Account for rounded corners (`rounded=1`) and stroke width
- YOU MUST: Always visually verify PNG output for overflow

Coordinate calculation verification:

```text
Background frame: y=20, height=400 -> range is y=20-420
Internal element top: frame y + 30 or more (e.g., y=50)
Internal element bottom: frame y + height - 30 or less (e.g., up to y=390)
```

Bad example (may overflow):

```xml
<!-- Background frame -->
<mxCell id="bg" style="rounded=1;strokeWidth=3;...">
  <mxGeometry x="500" y="20" width="560" height="400" />
</mxCell>
<!-- Text: y=30 is too close to frame top (y=20) -->
<mxCell id="label" value="Title" style="text;...">
  <mxGeometry x="510" y="30" width="540" height="35" />
</mxCell>
```

Good example (sufficient margin):

```xml
<!-- Background frame -->
<mxCell id="bg" style="rounded=1;strokeWidth=3;...">
  <mxGeometry x="500" y="20" width="560" height="430" />
</mxCell>
<!-- Text: y=50 is 30px from frame top (y=20) -->
<mxCell id="label" value="Title" style="text;...">
  <mxGeometry x="510" y="50" width="540" height="35" />
</mxCell>
```

## 8. Reference

- [Color Palette](references/color-palette.md) - auto-updatable
- [Layout Guidelines](references/layout-guidelines.md) - auto-updatable
- [AWS Icons](references/aws-icons.md)
- [AWS Icon Search Script](scripts/find_aws_icon.py)

AWS icon search examples:

```sh
python ~/.claude/skills/draw-io/scripts/find_aws_icon.py ec2
python ~/.claude/skills/draw-io/scripts/find_aws_icon.py lambda
```

## 9. Checklist

- [ ] No background color set (page="0")
- [ ] Font size appropriate (larger recommended)
- [ ] Arrows placed at back layer
- [ ] Arrows not overlapping labels (verify in PNG)
- [ ] Arrow start/end sufficiently distant from labels (at least 20px)
- [ ] Arrows not penetrating boxes or icons (verify in PNG)
- [ ] Internal elements not overflowing background frame (verify in PNG)
- [ ] 30px+ margin between background frame and internal elements
- [ ] AWS service names are official names/correct abbreviations
- [ ] AWS icons are latest version (mxgraph.aws4.\*)
- [ ] No unnecessary elements remaining
- [ ] Visually verified PNG conversion

## 10. Visual Quality Review Workflow

After creating or editing a `.drawio` file, run this review loop:

1. Convert to PNG:

   ```sh
   drawio -x -f png -s 2 -t -o output.drawio.png input.drawio
   ```

2. Read the PNG with the Read tool (Claude can view images)
3. Check against the checklist in section 9
4. If issues found, fix the `.drawio` XML and repeat from step 1

Key items to verify visually:

- Elements not overflowing background frames
- Arrows not penetrating boxes or overlapping labels
- Text not truncated or line-breaking unexpectedly
- Color palette consistent with references/color-palette.md
- Sufficient whitespace between elements

## 11. Self-Update Protocol

This skill maintains auto-updatable reference files that evolve
as new `.drawio` files are created.

### 11.1. Auto-Updatable Files

| File                              | Content                | Stability  |
| --------------------------------- | ---------------------- | ---------- |
| `references/color-palette.md`     | Color table and rules  | Updatable  |
| `references/layout-guidelines.md` | Pattern catalog (A-K+) | Updatable  |
| `SKILL.md` section 7              | Best practices         | Appendable |
| `SKILL.md` section 9              | Checklist              | Appendable |

### 11.2. Triggers

Execute self-update after:

1. Creating a new `.drawio` file
2. Significantly editing an existing `.drawio` file
3. User explicitly requests skill update

### 11.3. Update Procedure

```text
1. Read the created/edited .drawio file
2. Extract style attributes from all mxCell elements
3. Detect:
   a. New colors (fillColor/strokeColor/fontColor not in color-palette.md)
      → Add to references/color-palette.md with semantic role
   b. New layout pattern (structure doesn't match known patterns A-K)
      → Add to references/layout-guidelines.md with name and diagram
   c. New best practice (fix applied during quality review)
      → Append to SKILL.md section 7
   d. New checklist item (repeated issue caught in review)
      → Append to SKILL.md section 9
4. Update "Last updated" and "Source files analyzed" metadata
5. Report changes to user
```

### 11.4. Detection Rules

Color detection:

```text
1. Parse all style="..." attributes in .drawio XML
2. Extract fillColor, strokeColor, fontColor values
3. Compare against known colors in references/color-palette.md
4. If unknown color found:
   - Check if it belongs to Material Design family
   - Assign semantic role based on context
   - Add to palette table
```

Pattern detection:

```text
1. Count vertex elements (boxes) and edge elements (arrows)
2. Analyze nesting (parent-child relationships)
3. Check spatial arrangement (horizontal/vertical/radial)
4. Compare against known patterns A-K in layout-guidelines.md
5. If no match:
   - Name the pattern based on structure
   - Create ASCII diagram
   - Add to appropriate category
```

### 11.5. Metadata Format

Each auto-updatable file ends with:

```markdown
---

Last updated: YYYY-MM-DD
Source files analyzed:

- repo/path/to/\*.drawio
```

## 12. Image Display in reveal.js Slides

Add `auto-stretch: false` to YAML header:

```yaml
---
title: "Your Presentation"
format:
  revealjs:
    auto-stretch: false
---
```

This ensures correct image display on mobile devices.
