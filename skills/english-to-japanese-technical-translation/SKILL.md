---
name: english-to-japanese-technical-translation
license: MIT
description: |
  USE FOR: Translate English technical articles into Japanese and review
  Japanese technical prose with glossary and style checks. DO NOT USE FOR:
  provider/model choice or publishing.
---

# English-to-Japanese Technical Translation

## 1. Overview

Translate English technical writing into natural Japanese. Read
[Workflow](references/workflow.md) for the full procedure, prompt templates, and
QA checklists. Read
[Japanese Writing Style](references/japanese-writing-style.md) for Japanese
prose rules and the visual style note.

## 2. Workflow

1. Before sending source text, drafts, glossaries, style examples, or image
   contents to any AI provider or translation tool, confirm rights to translate,
   share the material, and publish or distribute the derivative. Confirm policy
   for provider, model, network path, and data handling. If unclear, stop for
   approval; this skill does not choose those policies.
2. Stabilize the source revision, publication surface, audience, and register.
3. Mark verbatim tokens separately from semantic and structural
   constraints. Keep code, commands, paths, URLs, API names, identifiers,
   product names, UI labels, and versions exact; preserve warning meaning and
   table structure.
4. Build a glossary before translating body text. Decide whether each term
   should be translated, kept in English, written in katakana, or shown in
   bilingual first-use form.
5. Translate section by section. Do not translate a whole technical article in
   one shot.
6. Run separate review passes for technical accuracy, terminology consistency,
   Japanese editorial quality, technical integrity, and final publication QA.

## 3. Prompt Use

Use the reference prompts for style contracts, terminology extraction, section
translation, accuracy review, editorial review, drift checks, and final QA. Keep
verbatim tokens exact and ask for uncertainty markers instead of invented
detail.

## 4. Boundaries

Manual workflow only. This skill does not choose providers or models, estimate
cost, define privacy policy, authorize external sharing or derivative
publication, automate source chunking, or publish translated output.
