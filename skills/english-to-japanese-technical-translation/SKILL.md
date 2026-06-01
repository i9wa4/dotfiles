---
name: english-to-japanese-technical-translation
license: MIT
description: |
  USE FOR: English-to-Japanese technical translation of Markdown articles, with
  glossary-first terminology, verbatim-token preservation, structural constraint
  checks, reusable prompts, and publication QA for natural Japanese technical
  prose. DO NOT USE FOR: non-Japanese translation, generic editing, provider or
  model selection, cost control, privacy policy, source chunking automation, or
  publishing translated output without review.
---

# English-to-Japanese Technical Translation

## Overview

Translate English technical writing into natural Japanese. Read
[Workflow](references/workflow.md) for the full procedure, prompt templates,
and QA checklists.

## Workflow

1. Before sending source text, drafts, glossaries, or style examples to any AI
   provider or translation tool, confirm rights to translate, share source with
   the tool, and publish/distribute the translated derivative. Also confirm
   project policy for provider, model, network path, and data handling. If
   unclear, stop for approval; this skill does not choose those policies.
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

## Prompt Use

Use the workflow reference prompts for style contracts, terminology extraction,
section translation, accuracy review, editorial review, drift checks, and final
QA. Keep verbatim tokens exact, preserve constraints such as warning meaning and
table layout, and ask for uncertainty markers instead of invented details.

## Boundaries

Manual workflow only. This skill does not choose providers or models, estimate
cost, define privacy policy, authorize external sharing or derivative
publication, automate source chunking, or publish translated output.
