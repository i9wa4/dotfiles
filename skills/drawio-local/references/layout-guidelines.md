# Layout Guidelines

## 1. AWS Architecture Diagrams

### 1.1. Grouping Principles

- Use AWS Cloud group as the outermost layer
- Create subgroups by functional unit
- Arrange groups horizontally, following data flow

```text
AWS Cloud (outermost)
├── VPC
│   ├── Public Subnet
│   │   └── ALB, NAT Gateway, etc.
│   └── Private Subnet
│       └── ECS, RDS, etc.
├── S3
├── CloudWatch
└── Other services
```

### 1.2. Connection Line Rules

| Flow Type      | Line Style | Purpose          |
| -------------- | ---------- | ---------------- |
| Ingestion Flow | Dashed     | Data ingestion   |
| Query Flow     | Solid      | Query / lookup   |
| Control Flow   | Dotted     | Control / manage |

- Arrows follow the direction of data flow
- For bidirectional communication, use 2 unidirectional arrows

### 1.3. Placement Principles

Left-to-right flow (default):

```text
[Data Source] → [Processing] → [Storage] → [Analytics / Visualization]
```

Top-to-bottom flow (alternative):

```text
[User / Client]
       ↓
[Load Balancer]
       ↓
[Application]
       ↓
[Database]
```

## 2. Slide Diagram Pattern Catalog

Reusable layout patterns extracted from existing slides.
Select the best-matching pattern from this catalog when creating diagrams.

### 2.1. Comparison Patterns

#### 2.1.1. A. Side-by-Side Comparison Panel

Compare two concepts horizontally.

```text
┌─────── Suitable ────────┐  ┌──── Not Suitable ────┐
│ ┌─────────────────────┐ │  │ ┌─────────────────────┐│
│ │ Item 1              │ │  │ │ Item 1              ││
│ ├─────────────────────┤ │  │ ├─────────────────────┤│
│ │ Item 2              │ │  │ │ Item 2              ││
│ └─────────────────────┘ │  │ └─────────────────────┘│
└─────────────────────────┘  └────────────────────────┘
```

- Left: Success color (positive) / Right: Danger color (negative)
- Optional Note-colored supplementary box at the bottom

#### 2.1.2. B. Before/After (Vertical Two-Row)

Show improvement over time.

```text
┌────────── Before (red background) ──────────┐
│ [Step1] → [Step2] → [Step3] → [Total]      │
└─────────────────────────────────────────────┘
┌────────── After (green background) ─────────┐
│ [Step1] → [Step2] → [Total]                │
└─────────────────────────────────────────────┘
```

- Before: Danger background + Warning steps
- After: Success background + Success steps
- Show total time/cost on the right edge

#### 2.1.3. C. 3-Column Comparison Table

Show mappings and correspondences.

```text
┌──────────┬──────────┬──────────┐
│ Header 1 │ Header 2 │ Header 3 │
├──────────┼──────────┼──────────┤
│ Item     │ Item     │ Item     │
├──────────┼──────────┼──────────┤
│ Item     │ Item     │ Item     │
└──────────┴──────────┴──────────┘
```

- Assign different color roles to each column
- Use arrows "→" to indicate directionality

### 2.2. Flow / Process Patterns

#### 2.2.1. D. Horizontal Step Flow

Show sequential steps or processes.

```text
  ①          ②          ③
┌────┐    ┌────┐    ┌────┐
│Step│ →  │Step│ →  │Step│
│    │    │    │    │    │
└────┘    └────┘    └────┘
┌──────── Supplement / Code Block ───────┐
│ export VAR=value                       │
└────────────────────────────────────────┘
┌──────── Takeaway (Note color) ─────────┐
│ Key message                            │
└────────────────────────────────────────┘
```

- Number badges on each step (circle, filled stroke, white text)
- Different color role per step
- Neutral-colored code example and Note-colored takeaway at bottom

#### 2.2.2. E. Multi-Column Layout

Expand system structure from left to right.

```text
┌── Left Panel ──┐     ┌── Center Panel ──┐     ┌── Right Panel ──┐
│ ┌───────────┐  │     │ ┌─────────────┐  │     │ ┌───────────┐   │
│ │ Element   │  │ ──→ │ │ Feature 1   │  │ ──→ │ │ Element 1 │   │
│ ├───────────┤  │     │ ├─────────────┤  │     │ ├───────────┤   │
│ │ Element   │  │     │ │ Feature 2   │  │     │ │ Element 2 │   │
│ └───────────┘  │     │ └─────────────┘  │     │ └───────────┘   │
└────────────────┘     └─────────────────┘     └─────────────────┘
┌──────────── Takeaway (Primary color) ────────────┐
│ Key message                                      │
└──────────────────────────────────────────────────┘
```

- Different color role per panel
- Thick arrows between panels (strokeWidth=4)
- Summary bar at bottom

#### 2.2.3. F. Vertical Flow + Branching

Show Git-flow-style branching and merging.

```text
       [Config File]
            ↓
    ┌───────┴───────┐
    ↓               ↓
[Local]         [CI/CD]
    ↓               ↓
    └───────┬───────┘
            ↓
        [PR/Review]
            ↓
        [main]
```

- Main line thick (strokeWidth=3), branches thin
- Highlight points with colored border (Danger stroke)

### 2.3. Aggregation / Decomposition Patterns

#### 2.3.1. G. Multiple → Unified Result

Multiple inputs converge into a single result.

```text
┌────┐ ┌────┐ ┌────┐ ┌────┐
│Sol1│ │Sol2│ │Sol3│ │Sol4│
└──┬─┘ └──┬─┘ └──┬─┘ └──┬─┘
   └───┬───┴───┬──┘      │
       ↓       ↓         ↓
┌───────────── Unified Result ──────────────┐
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐         │
│ │Feat1│ │Feat2│ │Feat3│ │Feat4│         │
│ └─────┘ └─────┘ └─────┘ └─────┘         │
└───────────────────────────────────────────┘
```

- Different color role per input
- Result box with accent stroke
- Internal feature cards on white background

#### 2.3.2. H. Center + Radial (Problem Statement)

Arrange problems/features around a central icon.

```text
        ┌────────┐
        │Problem1│
        └───┬────┘
            ↓
┌────┐  ┌──────┐  ┌────┐
│Prob2│→ │Center│ ←│Prob3│
└────┘  └──────┘  └────┘
            ↑
        ┌───┴────┐
        │Problem4│
        └────────┘
```

- Central icon (emoji or person)
- Surrounding boxes in uniform color (Warning or Danger)
- Dashed arrows from problems to center

### 2.4. Card / Metric Patterns

#### 2.4.1. I. Side-by-Side Cards (KPI / Metrics)

Display independent metrics in parallel.

```text
┌──── Metric 1 ────┐ ┌──── Metric 2 ────┐ ┌──── Metric 3 ────┐
│ Icon             │ │ Icon             │ │ Icon             │
│ Title            │ │ Title            │ │ Title            │
│ Before → After   │ │ Before → After   │ │ Before → After   │
│ ┌─────────────┐  │ │ ┌─────────────┐  │ │ ┌─────────────┐  │
│ │ XX% improved│  │ │ │ XX% improved│  │ │ │ XX% improved│  │
│ └─────────────┘  │ │ └─────────────┘  │ │ └─────────────┘  │
└──────────────────┘ └──────────────────┘ └──────────────────┘
```

- Different color role per card
- Improvement values highlighted in Success color

### 2.5. Hierarchy / Structure Patterns

#### 2.5.1. J. Multi-Layer Architecture Diagram

Expand vertically from user layer to foundation layer.

```text
┌──── 5 User Types ──────────────────────────┐
│ [Type1] [Type2] [Type3] [Type4] [Type5]    │
└────────────────────────────────────────────┘
┌──── Feature Layer ─────────────────────────┐
│ ┌────┐ ┌────┐ ┌────┐ ┌──────────────┐     │
│ │Dev │ │ML  │ │SQL │ │Consumer      │     │
│ └────┘ └────┘ └────┘ └──────────────┘     │
├──── Shared Layer ──────────────────────────┤
│ [Compute] [Storage]                        │
└────────────────────────────────────────────┘
┌──── Foundation Layer ──────────────────────┐
│ [Governance / Catalog]                     │
└────────────────────────────────────────────┘
```

- Different color role per feature section
- Shared layer in Neutral color
- Foundation in Note color (indicates importance)

#### 2.5.2. K. 3-Column Mapping

Visualize relationships between left and right elements via center.

```text
┌──Left──┐     ┌──Center──┐     ┌──Right──┐
│ Role 1 │ ──→ │ Perm A   │ ──→ │ Feat X  │
│ Role 2 │ ──→ │ Perm B   │ ──→ │ Feat Y  │
│ Role 3 │ ──→ │ Perm C   │ ──→ │ Feat Z  │
└────────┘     └──────────┘     └─────────┘
```

- Different color role for left, center, and right
- Arrow color matches source element color

### 2.6. Technical / AI System Patterns

#### 2.6.1. L. Agent + Tool + Memory Loop

Show the user request, agent core, tools, and memory as separate
responsibilities.

```text
[User / Trigger] ──→ [Agent / Planner] ──→ [Tool Call]
                        │   ↑                │
                        │   └── feedback ───┘
                        ↓
                 [Short-term Memory]
                        ↓
                 [Long-term Store]
                        │
                        └──── retrieval ───→ [Agent / Planner] ──→ [Response]
```

- Keep the agent core visually distinct from ordinary services
- Show tool calls and memory reads as different arrow meanings
- Use a curved feedback arrow only when the reasoning loop matters to the
  story

#### 2.6.2. M. Memory Tier Read / Write Split

Separate what the runtime reads from what it writes.

```text
                read path
[Runtime] <──── [Working Set] <──── [Long-term Store]
    │                  │                   ↑
    │                  └──── write path ───┘
    └──────────────→ [Event / History Log]
```

- Put runtime or agent logic on one side and stores on the other
- Use dashed retrieval arrows and solid persistence arrows consistently
- Label the stored asset type when it is not obvious (`chunks`, `embeddings`,
  `memory`, `events`)

## 3. Visibility

- Place labels close to their elements
- Adjust placement to avoid crossing arrows
- Group related elements and place them nearby
- Ensure adequate whitespace for readability
- Always include a Takeaway bar at the bottom of slide diagrams

---

Last updated: 2026-04-14
Source files analyzed:

- i9wa4.github.io/assets/2026-01-27-jedai-ai-gateway/\*.drawio
- i9wa4.github.io/assets/2025-12-22-aeon-tech-hub-databricks/\*.drawio
- i9wa4.github.io/assets/2025-12-12-databricks-notebook-ai-ready/\*.drawio
- i9wa4.github.io/assets/2025-11-07-tamesare-data-sapporo-uma-chan/\*.drawio
- Selective adaptation study:
  `yizhiyanhua-ai/fireworks-tech-graph@c8668407ebfa72e00719be8f4312b71ab90c3c3e`
