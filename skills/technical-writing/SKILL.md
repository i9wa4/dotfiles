---
name: technical-writing
license: MIT
metadata:
  version: "2.0.0"
description: |
  USE FOR: Draft, edit, translate or review English/Japanese technical prose,
  including README text and technical documentation. Check terminology,
  clarity, grammar, cognitive rhythm, AI-like style and publication readiness;
  use Vale and Harper for English QA. Preserve meaning. Route English to
  avoid-ai-writing and Japanese to yomiyasu. Includes Japanese from notes,
  Japanese drafts, English prose and translation in both directions.
  DO NOT USE FOR: AI detection or humanizing, meaning-changing rewrites, code,
  publishing, or unrequested translation.
---

# Technical Writing

Respect source rights and approved provider/data boundaries; ask if unclear.

1. Identify source language and task. Load `avoid-ai-writing` for English and
   `yomiyasu` for Japanese from the Skill catalog.
2. Route the work:
   - New Japanese text from notes: draft complete English, revise it with
     `avoid-ai-writing`, translate faithfully, then refine with `yomiyasu`.
   - Existing Japanese draft: keep its wording and voice as the baseline;
     revise with `yomiyasu`. For structural changes, optionally consult
     `avoid-ai-writing` on argument, edit the Japanese original, then finish
     with `yomiyasu`.
   - Existing English text: revise with `avoid-ai-writing`. For new
     English-only writing, draft then refine English without translating.
   - Review only: consult `avoid-ai-writing` for English or `yomiyasu` for
     Japanese. Report findings without editing; preserve claims and qualifiers.
   - English to Japanese: translate faithfully, refining English first when
     useful, then use `yomiyasu`. Japanese to English: translate faithfully,
     then refine English with `avoid-ai-writing`.

3. Compare final text to **original materials**. Preserve claims, terms,
   identifiers, units, negation, uncertainty, constraints, citations and intent;
   flag unsupported additions.
4. Optionally use [Vale and Harper](references/vale-and-harper.md) for
   proofreading; treat findings as suggestions.
