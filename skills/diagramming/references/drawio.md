# draw.io

Use this reference for native draw.io diagram creation, editing, review, and
export in this repo.

## Source And Output Rules

- Edit `.drawio` source files, not generated exports.
- Always commit editable `.drawio` sources.
- Treat `.drawio.png`, `.drawio.svg`, and `.drawio.pdf` as generated exports
  unless a nearby workflow explicitly expects them.
- Prefer native `mxGraphModel` XML over Mermaid or CSV conversions for draw.io
  work.
- Use descriptive lowercase filenames with hyphens, such as
  `login-flow.drawio`.

## Output Formats

| Format        | Embedded XML | Recommended use                |
| ------------- | ------------ | ------------------------------ |
| `.drawio`     | n/a          | Editable source diagram        |
| `.drawio.png` | Yes          | Docs, slides, chat attachments |
| `.drawio.svg` | Yes          | Docs, scalable output          |
| `.drawio.pdf` | Yes          | Review and print               |
| `.drawio.jpg` | No           | Last-resort lossy export       |

## Font And Canvas Rules

- For Quarto slides, set `defaultFontFamily="Noto Sans JP"` on
  `mxGraphModel`.
- Set `fontFamily=Noto Sans JP` explicitly on each text element.
- For slide diagrams, use transparent background with `page="0"`.
- Keep slide diagrams to one to three accent colors.
- Include a bottom takeaway bar when the diagram is explanatory.

## XML Rules

Every diagram must use native `mxGraphModel` XML with root cells:

```xml
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
  </root>
</mxGraphModel>
```

Every edge must contain geometry:

```xml
<mxCell id="e1" edge="1" parent="1" source="a" target="b" style="edgeStyle=orthogonalEdgeStyle;">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

Do not use self-closing edge cells.

## Layout Guidance

- Choose diagram abstraction before drawing: context, system, component,
  deployment, data flow, or sequence.
- Use semantic shapes before product icons.
- Use AWS icons only when cloud product identity matters.
- Keep related diagram sets consistent in canvas size, colors, fonts, and
  stroke widths.
- Use container parent relationships instead of fake visual containment.
- Space nodes generously and prefer orthogonal edges for technical diagrams.
- Add explicit waypoints when auto-routing overlaps labels or nodes.

## Scripts And Assets

The target skill owns the workflow and carries the reusable draw.io helper
assets:

- Color palette:
  [color-palette.md](color-palette.md)
- Layout catalog:
  [layout-guidelines.md](layout-guidelines.md)
- AWS icon catalog:
  [aws-icons.md](aws-icons.md)
- PNG export:
  [scripts/convert-drawio-to-png.sh](../scripts/convert-drawio-to-png.sh)
- AWS icon search:
  [scripts/find_aws_icon.py](../scripts/find_aws_icon.py)
- SVG overlap check:
  [scripts/check-drawio-svg-overlaps.mjs](../scripts/check-drawio-svg-overlaps.mjs)

## Validation

- Run the conversion hook or script when generated PNGs are part of the target
  workflow.
- Inspect generated output for overlap, text clipping, and unreadable contrast.
- For slide diagrams, verify the rendered slide, not only the XML.
