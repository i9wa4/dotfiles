# Referent Table

Use this table before drafting when a term, label, heading, category, state,
condition, event, method/type name, or summary bucket may become vague if it is
chosen too early.

The original proposal discussed this as `semantic-generation` with a
`referent-before-label` rule. In this repo the method is named
`clarify-concepts` because the reusable operation is concept clarification
before naming, not broad semantic generation.

## Table

| 出典 | 目的 | 具体対象 | 役割 | 前後関係 | 候補語 | 初出定義 |
| --- | --- | --- | --- | --- | --- | --- |
| Source or evidence location | Why this row matters | Concrete object, behavior, state, record, value, or relation | One role from the allowed set | Preconditions, sequence, cause/effect, lifecycle, or neighboring concept | Candidate term, filled last | Definition to use at first mention |

## Role Choices

Choose one role per row:

- `開始条件`: condition that starts or enables a process
- `状態`: durable state or mode
- `事象`: event or occurrence
- `値`: scalar, enum, threshold, or calculated value
- `記録`: logged, stored, or observed record
- `目的`: intended outcome or reason
- `手段`: method, mechanism, or action used to reach an outcome

## Procedure

1. Extract `出典` and `目的` from the source material or task objective.
2. Write `具体対象` as the concrete referent, not as a candidate label.
3. Assign exactly one `役割`. If two roles fit, split the row.
4. Record `前後関係`: what comes before, what follows, what causes it, what it
   affects, or which neighboring concept it must be distinguished from.
5. Fill `候補語` after the referent, role, and sequence are stable.
6. Write `初出定義` so the first use defines the term from the referent and
   role, not from a circular label.
7. Draft the target text from the table.

## Required Discipline

- Do not place a vague term first and then reason from that term.
- Keep `候補語` rightmost in the table to make it visually and procedurally
  last.
- Do not merge rows just because one attractive label could cover them.
- Prefer ordinary names when the referent is ordinary; the method is not a
  mandate to coin special terminology.
- Skip the table for simple edits, casual chat, translation-only tasks, or
  generic summaries where concept/naming ambiguity is not a risk.

## Output Pattern

When the table is useful to show, use:

```markdown
| 出典 | 目的 | 具体対象 | 役割 | 前後関係 | 候補語 | 初出定義 |
| --- | --- | --- | --- | --- | --- | --- |
| ... | ... | ... | ... | ... | ... | ... |
```

Then continue with definitions or body text derived from the stable rows.
