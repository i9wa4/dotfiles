---
name: subagent-review
license: MIT
description: "USE FOR: Guardian/critic reviews with required perspectives, bounded aggregation, and meta-review gates. DO NOT USE FOR: implementation, posting, or model overrides."
---

# Subagent Review

Use native reviewer perspectives only. Do not implement, approve, dispatch
fan-out, override models/tiers, or cross-engine pool.

Lane: orchestrator -> guardian -> critic -> guardian -> orchestrator.
Defaults: security, architecture, historian, code, QA.

## 1. Workflow

1. Run the cheapest relevant verifier first.
2. Substantive reviews use subagents before synthesis.
3. Guardian uses all five Codex perspectives.
4. Critic launches the guardian-specified set; no `Required perspectives`
   means all five. Critic never self-selects.
5. Direct review requires guardian-labeled trivial follow-up.
6. Run waves in parallel; close each wave before second-wave validators.
7. Add data/research reviewers only for specialized questions.
8. Use bounded read-only paths, context, and output shape.
9. Suppress unverified findings; output critic evidence packet or guardian
   final verdict.

## 2. Role Rules

- Guardian aggregates the final verdict.
- Guardian-to-critic postman requests authorize specified launches. If blocked,
  return `BLOCKED: perspective launch not permitted`; no direct-review fallback.
- Trivial labels: docs-only, single-line behavior-free, or no test changes.
  Critic states the criterion.
- Critic sends review result to guardian, not orchestrator.
- Reviewer subagents must not edit, commit, push, or approve.
- If fewer required perspectives complete, return `BLOCKED: fewer than required
  perspectives completed` unless guardian pre-authorized degradation.
- Substantive critic replies include `Required perspectives: [list]` and
  `Perspectives launched: [list]`.

## 3. Output

Preserve perspective, paths, evidence, severity, confidence, and gaps. Final
verdicts use guardian aggregation.

## 4. Tier 2 Quality Audit

Only when orchestrator requests Tier 2, guardian assigns one bounded
meta-reviewer, returns `Tier 2 quality audit: complete`, and starts no nested
guardian/critic loop.
