---
name: clarify-concepts
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Clarify concepts before names harden by fixing concrete referents, roles, sequence, candidate terms, and first-use definitions. Use for terminology-heavy design docs, research synthesis, cause-isolation or mitigation plans, naming decisions, and reasoning-order summaries when concept/naming ambiguity could distort the work. DO NOT USE FOR: simple editing, translation-only work, casual chat, proofreading, generic summarization/research, implementation, or broad content generation.
---

# Clarify Concepts

Owns the referent-before-label method: fix the concrete target, role, and
sequence before a plausible label, category, heading, or summary term becomes
the thing being reasoned from.

This method is provider-agnostic. Use it whenever an agent, writer,
researcher, or designer may place a plausible label before the target is fixed.

## 1. Workflow

1. Decide whether concept or naming ambiguity can change the result.
2. If yes, read [Referent Table](references/referent-table.md) before drafting
   the target document, summary, plan, category set, or name list.
3. Build the referent table from available sources. Inspect available facts
   instead of asking when the source material can answer the question.
4. Fill `候補語` only after `具体対象`, `役割`, and `前後関係` are stable.
5. Split a row when one candidate term would cover multiple roles.
6. Define first-use terms from the table before drafting body text.
7. When a concept or naming decision is genuinely user-owned, ask one focused
   question and include a recommended answer.

## 2. Boundaries

- Keep evidence acquisition and claim verification in `technical-research`.
- Keep meaning-preserving prose QA, glossary polish, and translation mechanics
  in `technical-writing`.
- Keep durable implementation planning and review gates in `plan-design`.
- Use this skill only for the concept-clarification layer those skills may call
  before wording, synthesis, or planning.

## 3. References

- [Referent Table](references/referent-table.md)
