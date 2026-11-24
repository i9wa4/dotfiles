---
name: technical-writing
license: MIT
metadata:
  version: "2.0.0"
description: |
  USE FOR: Start this technical writing workflow before the editorial skills
  when drafting Japanese prose from bullet notes, revising existing Japanese
  or English technical prose, reviewing existing English or Japanese technical
  prose without editing, drafting English-only text, or translating
  English-to-Japanese or Japanese-to-English. Route to avoid-ai-writing for
  English and yomiyasu for Japanese while preserving the original source.
  DO NOT USE FOR: AI detection or humanizing, meaning-changing rewrites, code,
  publication, or unrequested translation.
---

# Technical Writing

Check rights and approved provider/network before sharing source. Keep sensitive
data within approved handling; ask if unclear.

1. Identify source language and task. Load `avoid-ai-writing` for English and
   `yomiyasu` for Japanese from the Skill catalog.
2. Route the work:
   - New Japanese text from notes: draft complete English, revise it with
     `avoid-ai-writing`, translate faithfully, then refine with `yomiyasu`.
   - Existing Japanese draft: edit the original Japanese with `yomiyasu`; keep
     its wording and voice as the baseline. For substantial structural revision,
     optionally consult `avoid-ai-writing` on argument and structure, then edit
     the Japanese original and finish with `yomiyasu`.
   - Existing English text: revise with `avoid-ai-writing`. For new
     English-only writing, draft then refine English without translating.
   - Review only: consult `avoid-ai-writing` for English or `yomiyasu` for
     Japanese. Report specific quality findings and suggestions without editing
     the original; preserve its claims and qualifiers when describing changes.
   - English to Japanese: translate faithfully, refining English first when
     useful, then use `yomiyasu`. Japanese to English: translate faithfully,
     then refine English with `avoid-ai-writing`.

3. Compare the final text with the **original materials**, not only an
   intermediate draft. Preserve claims, technical terms, identifiers, units,
   negation, uncertainty, constraints, citations, and authorial intent.
   Flag missing evidence rather than adding facts.
4. Optionally proofread with [Vale and Harper](references/vale-and-harper.md);
   treat findings as suggestions.
