---
name: subagent-review
license: MIT
description: "USE FOR: Guardian/critic reviews using guardian-specified native reviewer perspectives. DO NOT USE FOR: implementation, dispatcher fan-out, model/tier overrides, or public posting."
---

# Subagent Review

Use runtime-native reviewer perspectives for guardian/critic review. Do not
implement, approve, dispatch fan-out, or override models/tiers.

Defaults: security, architecture, historian, code, QA.

## 1. Workflow

1. Run the cheapest relevant verifier first.
2. For substantive reviews, both roles use subagents before synthesis.
   Guardian uses all five Codex perspectives. Critic launches the
   guardian-specified set; omitted `Required perspectives` means all five.
   Guardian narrows the set; critic never self-selects.
3. Direct review is only for guardian-labeled trivial follow-ups.
4. Run each wave in parallel; close it before second-wave validators.
5. Add data or research reviewers only for specialized questions.
6. Give each subagent bounded read-only paths, context, and output shape.
7. Suppress unverified findings, deduplicate, and produce the role output:
   critic evidence packet or guardian final verdict.

## 2. Role Rules

- Guardian uses Codex reviewers and aggregates the final verdict.
- Critic launches guardian-specified perspectives in parallel for substantive
  reviews. Omitted `Required perspectives` means all five. Guardian, not
  critic, decides narrower sets.
- A guardian-to-critic postman request authorizes the specified launches. If
  runtime policy blocks launch, return `BLOCKED:
  perspective launch not permitted`; no implicit direct-review fallback.
- Trivial follow-ups may use direct review only when guardian labels them
  trivial: docs-only, single-line behavior-free, or no test changes. Critic
  states the criterion.
- Critic sends the review result to guardian for aggregation, not orchestrator.
- Reviewer subagents must not edit, commit, push, or approve.
- If fewer required perspectives complete, return `BLOCKED: fewer than
  required perspectives completed` unless guardian pre-authorized degradation.
  Substantive critic replies include `Required perspectives: [list]` and
  `Perspectives launched: [list]`.

## 3. Output

Preserve perspective, paths, evidence, severity, confidence, and gaps. Final
verdicts use guardian aggregation.
