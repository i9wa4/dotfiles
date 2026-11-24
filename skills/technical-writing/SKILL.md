---
name: technical-writing
license: MIT
metadata:
  version: "2.0.0"
description: |
  USE FOR: Start this technical writing workflow before the editorial skills
  when drafting Japanese prose from bullet notes, revising existing Japanese
  or English technical prose, drafting English-only text, or translating
  English-to-Japanese or Japanese-to-English. Route to avoid-ai-writing for
  English and yomiyasu for Japanese while preserving the original source.
  DO NOT USE FOR: Code changes, publication, or translation outside the
  user's requested scope.
---

# Technical Writing

1. Identify the source language and whether this is new writing or revision.
   Load `avoid-ai-writing` for English editorial work and `yomiyasu` for
   Japanese. Resolve their SKILL.md paths from the session Skill catalog, or
   replace this Skill path’s final `technical-writing/SKILL.md` segment with
   the sibling name; bundle entries may be symlinks. Metadata helps discovery
   but cannot guarantee load order.
2. Route the work:
   - New Japanese text from notes: draft complete English, revise it with
     `avoid-ai-writing`, translate faithfully, then refine with `yomiyasu`.
   - Existing Japanese draft: edit the original Japanese with `yomiyasu`; keep
     its wording and voice as the baseline. For substantial structural revision,
     optionally consult `avoid-ai-writing` on argument and structure, then edit
     the Japanese original and finish with `yomiyasu`.
   - Existing English text: revise with `avoid-ai-writing`. For new
     English-only writing, draft then refine English without translating.
   - English to Japanese: translate faithfully, refining English first when
     useful, then use `yomiyasu`. Japanese to English: translate faithfully,
     then refine English with `avoid-ai-writing`.

3. Compare the final text with the **original materials**, not only an
   intermediate draft. Preserve claims, technical terms, identifiers, units,
   negation, uncertainty, constraints, citations, and authorial intent. Change
   structure only within the requested scope. Flag missing evidence rather than
   adding facts.
4. Optionally use [Vale and Harper](references/vale-and-harper.md) for
   proofreading when available. Treat findings as suggestions; continue if
   those tools are unavailable.
