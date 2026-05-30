---
name: english-to-japanese-technical-translation
license: MIT
metadata:
  version: "0.1.0"
description: |
  USE FOR: English-to-Japanese technical translation of Markdown articles, with
  glossary-first terminology handling, protected-span preservation, reusable
  translation/review prompts, and publication QA for natural Japanese technical
  prose. DO NOT USE FOR: non-Japanese translation, generic prose editing,
  provider/model selection, cost control, privacy policy, source chunking
  automation, or publishing translated output without review.
---

# English-to-Japanese Technical Translation

## Overview

Translate English technical writing into natural Japanese while preserving
technical accuracy, Markdown structure, protected spans, terminology, and
publication quality.

Read [Workflow](references/workflow.md) when translating, reviewing, or
preparing prompts for a concrete article.

## Workflow

1. Stabilize the source revision, publication surface, audience, and Japanese
   register before translation.
2. List protected spans before translating: code fences, inline code, commands,
   paths, URLs, API names, identifiers, product names, UI labels, versions,
   warnings, and Markdown tables.
3. Build a glossary before translating body text. Decide whether each term
   should be translated, kept in English, written in katakana, or shown in
   bilingual first-use form.
4. Translate section by section. Do not translate a whole technical article in
   one shot.
5. Run separate review passes for technical accuracy, terminology consistency,
   Japanese editorial quality, technical integrity, and final publication QA.

## Prompt Use

Use the prompt templates in the workflow reference as starting points for:

- Project style contracts.
- Terminology extraction.
- Section translation.
- Technical accuracy review.
- Japanese editorial review.
- Terminology drift checks.
- Final publication QA.

Keep protected spans exact in every prompt. Ask the model to mark uncertainty
instead of inventing details.

## Boundaries

This skill packages the manual translation and review workflow. It does not
choose providers or models, estimate cost, define privacy policy, automate
source chunking, or publish translated output. Treat automation as a later
engineering task after repeated use exposes stable boundaries.
