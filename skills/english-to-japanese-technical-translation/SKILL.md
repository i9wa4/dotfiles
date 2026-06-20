---
name: english-to-japanese-technical-translation
license: MIT
description: |
  USE FOR: Translate English technical docs to Japanese; review Japanese
  technical prose with glossary, style, AI-slop, and publication QA. DO NOT USE
  FOR: publishing.
---

# English-to-Japanese Technical Translation

**UTILITY SKILL:** Apply this skill for English-to-Japanese technical
translation and Japanese technical-prose review.

## 1. Overview

Translate English technical writing into natural Japanese. Read
[Workflow](references/workflow.md) for procedure, prompts, and QA checklists.
Read [Japanese Writing Style](references/japanese-writing-style.md) for prose
rules, argument checks, AI-slop review, and visual style notes.

## 2. Workflow

1. Before using any AI provider or translation tool, confirm rights to
   translate, share, and distribute the material. If provider, model, network,
   or data-handling policy is unclear, stop for approval.
2. Stabilize the source revision, publication surface, audience, and register.
3. Mark verbatim tokens separately from semantic and structural constraints.
   Keep code, commands, paths, URLs, API names, identifiers, product names, UI
   labels, and versions exact.
4. Build a glossary before translating body text. Decide whether each term
   should be translated, kept in English, written in katakana, or shown in
   bilingual first-use form.
5. Translate section by section. Do not translate a whole technical article in
   one shot.
6. Run separate review passes for technical accuracy, terminology consistency,
   Japanese editorial quality, AI-slop cleanup, technical integrity, and final
   publication QA.

## 3. Prompt Use

Use the reference prompts for style contracts, terminology extraction,
translation, reviews, drift checks, and final QA. Keep verbatim tokens exact and
ask for uncertainty markers instead of invented detail.

## 4. Do Not Use For

**DO NOT USE FOR:** Choosing providers or models, estimating cost, defining
privacy policy, authorizing external sharing or derivative publication,
automating source chunking, or publishing translated output.
