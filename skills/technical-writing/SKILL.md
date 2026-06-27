---
name: technical-writing
license: MIT
description: |
  USE FOR: Technical prose quality, Vale/Harper checks, terminology, English
  and Japanese editorial review, English-to-Japanese translation workflow,
  glossary handling, AI-slop cleanup, and publication QA. DO NOT USE FOR: AI
  detector/humanizer workflows, content generation from scratch, meaning-
  changing rewrites, replacing author judgment, publishing, provider/model/
  cost/privacy choices, external-sharing authorization, or source chunking
  automation.
---

# Technical Writing

**UTILITY SKILL:** Apply this skill when technical prose needs quality review,
translation workflow guidance, terminology control, Japanese editorial review,
AI-slop cleanup, or publication QA.

## 1. Workflow

1. Identify the surface: English docs, Japanese prose, translation, skill text,
   or publication QA.
2. Preserve technical meaning. Do not rewrite commands, identifiers, product
   names, paths, code, links, versions, or API names for style.
3. For English prose checks, read
   [Vale And Harper](references/vale-and-harper.md).
4. For English-to-Japanese translation, read
   [English-to-Japanese Workflow](references/english-to-japanese-workflow.md)
   and [Japanese Writing Style](references/japanese-writing-style.md).
5. For prose that feels generic or AI-like, read
   [Prose Review](references/prose-review.md) and fix stance, agency,
   concrete claims, structure, rhythm, and filler before punctuation.
6. Treat tool findings and editorial suggestions as review evidence. Apply only
   changes that improve clarity without changing facts or author intent.

## 2. Boundaries

This skill preserves the documentation-first translation boundary from #225
and PR #226: automation, provider/model choice, cost controls, privacy policy,
external-sharing authorization, derivative publication approval, and source
chunking remain outside this skill.

## 3. Compatibility

Legacy triggers `english-writing-quality` and
`english-to-japanese-technical-translation` remain as thin compatibility
skills that route here.
