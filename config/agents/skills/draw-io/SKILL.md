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

### 6.6. One Concept Per Diagram

- Avoid cramming multiple concepts into a single diagram
- Split complex diagrams into focused, single-concept diagrams
- Each diagram should communicate one clear message
- Example: Instead of "Session + Window + Pane navigation" in one diagram,
  create "Session/Window navigation" and "Pane navigation" separately

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

For structural/connection arrows (e.g., flowcharts, ER diagrams):

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

### 7.10. Canvas Size and Target Display Width

- YOU MUST: Consider the target display width before setting canvas size
- For Zenn articles: body text width is approximately 700px
  - Recommended canvas width: 800px or less
  - Large canvas (3000px+) gets scaled down, making fonts unreadable
- For presentation slides: use 1920x1080
- Match canvas size to final display context to ensure readability

### 7.11. Arrow Size and Element Spacing

When using bidirectional arrows (`<-->`):

- Short distance between elements causes arrowheads to overlap,
  creating a star/diamond shape (`><`) instead of proper arrows
- YOU MUST: Ensure element spacing is sufficient for arrow length
  - Minimum 80-100px spacing recommended for badge-style elements
  - Reduce arrowhead size (`endSize`, `startSize`) to 3-6 for structure diagrams
  - Use `strokeWidth` 2-3 for auxiliary/structure diagram arrows
- YOU MUST: Visually verify arrow appearance in PNG output

### 7.12. Bidirectional Arrow Configuration

To create proper `<-->` arrows (not `><`):

- YOU MUST: Set both `startArrow=classic` and `endArrow=classic`
- YOU MUST: Set both `startFill=1` and `endFill=1`
- Verify arrow direction: arrows should point outward, not inward
- Example:

  ```xml
  <mxCell style="startArrow=classic;endArrow=classic;html=1;strokeWidth=5;
                 strokeColor=#FF6F00;startSize=6;endSize=6;
                 startFill=1;endFill=1;" edge="1" parent="1">
    <mxGeometry relative="1" as="geometry">
      <mxPoint x="100" y="200" as="sourcePoint" />
      <mxPoint x="300" y="200" as="targetPoint" />
    </mxGeometry>
  </mxCell>
  ```

### 7.13. Font Size and Canvas Scaling

When increasing font size:

- YOU MUST: Scale canvas and elements proportionally
- Increasing only font size causes text overflow
- Calculate proportional scaling:
  - Font 16pt → 24pt (1.5x): scale canvas and elements by 1.5x
  - Font 20pt → 30pt (1.5x): scale canvas and elements by 1.5x
- Example: Canvas 800x600 with 16pt font → Canvas 1200x900 with 24pt font

### 7.14. Symmetry, Arrow Consistency, and Z-Order

#### 7.14.1. Symmetry Principle

When placing badges or arrows with similar roles:

- YOU MUST: Align positions and sizes symmetrically
- Example: M-Up/M-Down badges should share the same X coordinate,
  positioned vertically (M-Up above, M-Down below)
- Example: S-Left/S-Right badges should share the same Y coordinates,
  positioned horizontally
- Symmetry enhances visual clarity and intuitive understanding

#### 7.14.2. Arrow Length Uniformity

Within a single diagram:

- YOU MUST: Standardize all arrow lengths to the same value
- NEVER: Mix short and long arrows (e.g., one 15px, another 35px)
- Example: If one arrow is 20px, all arrows should be 20px
- Consistent arrow length improves diagram balance and professionalism

#### 7.14.3. Z-Order Management

For badge-associated directional arrows (e.g., navigation diagrams):

Arrows should always be on the topmost layer:

- YOU MUST: Place arrow mxCell elements after badges and structure elements in XML
- This ensures arrows render on top and are not hidden behind other elements
- In draw.io XML, rendering order follows document order (later = front)
- NEVER: Place arrows before badges/boxes in XML structure

Example XML ordering:

```xml
<!-- 1. Background/structure elements first -->
<mxCell id="session" ...>
<!-- 2. Badges second -->
<mxCell id="badge_m_up" ...>
<!-- 3. Arrows last (will render on top) -->
<mxCell id="arrow_m_up" ...>
```

### 7.15. Parent Container Internal Symmetry

When placing elements inside parent containers (e.g., badges inside session boxes):

- YOU MUST: Maintain vertical symmetry (top margin = bottom margin)
- YOU MUST: Align elements on the container's horizontal centerline
- Example: For a container with x=150, w=400 (center x=350), place a 70px-wide badge at x=315 (350 - 35)
- Calculation: Container height = 2M + (element heights) + (spacing between elements)
  - M = top/bottom margin (should be equal for symmetry)
  - Example: For 2 badges (30px each) with 20px spacing: height = 2M + 60 + 20 = 2M + 80
- Symmetry applies to all internal elements within parent containers, not just badges

### 7.16. Label Text Padding

Label text should not be placed directly against box edges:

- YOU MUST: Add `spacingLeft` and `spacingTop` attributes to box styles for padding (5-10px recommended)
- Example: `style="...;spacingLeft=8;spacingTop=8;"`
- Applies to all container boxes (sessions, windows, panes)
- Improves readability and visual breathing room

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
- [ ] Canvas size matches target display width (800px or less for Zenn)
- [ ] Font size and canvas scaled proportionally
- [ ] Diagram follows "one concept per diagram" principle
- [ ] Arrows placed at back layer
- [ ] Arrows not overlapping labels (verify in PNG)
- [ ] Arrow start/end sufficiently distant from labels (at least 20px)
- [ ] Bidirectional arrows configured correctly (startArrow, endArrow, startFill, endFill)
- [ ] Arrows appear as `<-->` not `><` (verify in PNG)
- [ ] Arrow size appropriate for element spacing (endSize/startSize 3-6 recommended)
- [ ] Arrows not penetrating boxes or icons (verify in PNG)
- [ ] All arrows have uniform length within a diagram (verify in PNG)
- [ ] Badges/arrows with similar roles are positioned symmetrically (verify in PNG)
- [ ] Arrows placed last in XML (z-order: topmost layer)
- [ ] Internal elements not overflowing background frame (verify in PNG)
- [ ] 30px+ margin between background frame and internal elements
- [ ] Parent container internal symmetry (top margin = bottom margin)
- [ ] Elements aligned on parent container's horizontal centerline
- [ ] Label text padding set (spacingLeft/spacingTop 5-10px)
- [ ] Text not truncated or cut off at edges (verify in PNG)
- [ ] Reference images (if any) actually viewed and understood
- [ ] AWS service names are official names/correct abbreviations
- [ ] AWS icons are latest version (mxgraph.aws4.\*)
- [ ] No unnecessary elements remaining
- [ ] **Visually verified PNG conversion using Read tool**

## 10. Visual Quality Review Workflow

After creating or editing a `.drawio` file, run this review loop:

1. Convert to PNG:

   ```sh
   drawio -x -f png -s 2 -t -o output.drawio.png input.drawio
   ```

2. **CRITICAL**: Read the PNG with the Read tool (Claude can view images)
   - NEVER claim "no overlaps" or "no issues" based solely on XML coordinate values
   - XML geometry does not account for actual font rendering size
   - ALWAYS verify visually using the Read tool before reporting completion

3. Check against the checklist in section 9
4. If issues found, fix the `.drawio` XML and repeat from step 1

**When reference images exist:**

- YOU MUST: Actually view reference images using Read tool or WebFetch
- NEVER guess or infer design from descriptions alone
- If unable to view reference: report honestly, do not pretend

Key items to verify visually:

- Elements not overflowing background frames
- Arrows not penetrating boxes or overlapping labels
- Arrows appearing as proper `<-->` (not star/diamond `><` shapes)
- Text not truncated or line-breaking unexpectedly
- Text fully visible (no cutoff characters at edges)
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
