---
name: technical-writing
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Prose QA, Vale/Harper, terminology, English/Japanese editing,
  English-to-Japanese, glossary, rhythm, AI-slop cleanup, publication QA.
  DO NOT USE FOR: AI detector/humanizer workflows, fresh generation,
  meaning-changing rewrites, replacing author judgment, publishing,
  model/cost/privacy, external sharing, or chunking.
---

# Technical Writing

Owns meaning-preserving editing, translation, terminology, AI-slop cleanup,
rhythm, and QA. Translation: clean source English, then render natural
Japanese.

## 1. Workflow

1. Identify surface: English docs, Japanese prose, translation, skill text, or
   QA.
2. Preserve meaning. Do not rewrite commands, identifiers, product
   names, paths, code, links, versions, or APIs for style.
3. For generic/AI-like prose, read
   [Prose Review](references/prose-review.md).
4. For English checks, read
   [Vale And Harper](references/vale-and-harper.md).
5. For English-to-Japanese, clean English first, then read
   [English-to-Japanese Workflow](references/english-to-japanese-workflow.md)
   and [Japanese Writing Style](references/japanese-writing-style.md).
6. For Japanese editorial review, read
   [Japanese Writing Style](references/japanese-writing-style.md).
7. For accurate but flat explanatory prose, read
   [Cognitive Rhythm](references/cognitive-rhythm.md). Build rhythm from
   source material, not meta-commentary.
8. Apply only clarity changes; preserve facts and intent.

## 2. Boundaries

Issue 225/226 boundaries: no automation, model/cost/privacy, external-sharing
approval, derivative publication approval, or chunking.

Do not add direct polished-Japanese drafting from scratch. Repair English
first, then translate or QA Japanese.

## 3. References

- [Vale And Harper](references/vale-and-harper.md)
- [English-to-Japanese Workflow](references/english-to-japanese-workflow.md)
- [Japanese Writing Style](references/japanese-writing-style.md)
- [Prose Review](references/prose-review.md)
- [Cognitive Rhythm](references/cognitive-rhythm.md)
