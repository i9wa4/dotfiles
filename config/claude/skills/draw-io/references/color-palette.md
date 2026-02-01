# Color Palette

Material Design color set extracted from existing slide diagrams.

## 1. Color Table

| Role     | Background | Stroke     | Text       |
| -------- | ---------- | ---------- | ---------- |
| Primary  | `#E3F2FD`  | `#2196F3`  | `#1565C0`  |
| Accent   | `#BBDEFB`  | `#1976D2`  | `#0D47A1`  |
| Success  | `#E8F5E9`  | `#4CAF50`  | `#2E7D32`  |
| Warning  | `#FFF3E0`  | `#FF9800`  | `#E65100`  |
| Danger   | `#FFEBEE`  | `#F44336`  | `#C62828`  |
| Info     | `#E8EAF6`  | `#3F51B5`  | `#283593`  |
| Purple   | `#F3E5F5`  | `#9C27B0`  | `#7B1FA2`  |
| Note     | `#FFF8E1`  | `#FFC107`  | `#F57F17`  |
| Neutral  | `#ECEFF1`  | `#607D8B`  | `#455A64`  |
| Code bg  | `#ECEFF1`  | -          | `#37474F`  |

## 2. Usage Rules

- Use 1-3 accent colors per diagram to avoid visual noise
- Background frame (dashed): use Neutral stroke, no fill
- Box elements: use `rounded=1`, `strokeWidth=2` or `3`
- Step numbers (circles): use filled stroke color, white text
- Arrows: match the source element's stroke color
- Code blocks: use `fontFamily=monospace`, Code bg fill

## 3. Semantic Mapping

Common semantic assignments observed in existing diagrams:

| Concept           | Recommended Role |
| ----------------- | ---------------- |
| Developer/Eng     | Primary          |
| Success/Positive  | Success          |
| Alert/Budget      | Warning          |
| Error/Negative    | Danger           |
| Governance/Admin  | Info             |
| LLM/AI/External   | Purple           |
| Takeaway/Callout  | Note             |
| Infrastructure    | Neutral          |
| Data/Analytics    | Success          |
| Business/Consumer | Warning          |

---

Last updated: 2026-02-02
Source files analyzed:

- i9wa4.github.io/assets/2026-01-27-jedai-ai-gateway/*.drawio
- i9wa4.github.io/assets/2025-12-22-aeon-tech-hub-databricks/*.drawio
- i9wa4.github.io/assets/2025-12-12-databricks-notebook-ai-ready/*.drawio
- i9wa4.github.io/assets/2025-11-07-tamesare-data-sapporo-uma-chan/*.drawio
