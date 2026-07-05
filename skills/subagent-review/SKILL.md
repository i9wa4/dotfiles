---
name: subagent-review
license: MIT
metadata:
  version: "1.0.0"
description: "USE FOR: Guardian/critic reviews using guardian-specified native reviewer perspectives. DO NOT USE FOR: implementation, dispatcher fan-out, model/tier overrides, or public posting."
---

# Subagent Review

Runtime-native reviewer perspectives (defaults: security, architecture,
historian, code, QA). No implementation, approval, fan-out, or overrides.

## 1. Workflow

1. Run the cheapest relevant verifier first.
2. Each role: five subagent perspectives + one self-review (six inputs).
   Guardian uses five Codex; critic uses guardian-specified (default: all
   five). Guardian narrows; critic never self-selects.
3. Self-review accompanies the wave, never replaces it. Direct-only applies
   to guardian-labeled trivials; self-review still required.
4. Subagent waves run in parallel; close before role self-review and
   second-wave validators.
5. Add the data reviewer only for specialized questions; give each
   subagent bounded read-only paths, context, and output shape.
6. Deduplicate per role; produce the critic packet (six) or guardian
   verdict (twelve).

## 2. Role Rules

- Guardian: five Codex subagents + one self-review (six); aggregates all six
  into the intermediary result. MUST request critic for substantive reviews.
- Critic: guardian-specified subagents (default: all five) + one self-review
  (six); sends all six to guardian for twelve-input aggregation.
- Guardian aggregates twelve (six + six) into the final verdict.
- Postman request to critic authorizes launches. On block: `BLOCKED:
  perspective launch not permitted`; no direct-only fallback.
- Trivials may omit subagents when guardian so labels. Self-review still
  required. Critic states the criterion.
- Critic sends result to guardian, not orchestrator.
- Reviewer subagents must not edit, commit, push, or approve.
- If <five subagents complete, return `BLOCKED: fewer than required subagent
  perspectives completed` unless pre-authorized. Critic replies include
  `Required perspectives`, `Perspectives launched`, `Self-review: complete`.

## 3. Output

Perspective, paths, evidence, severity, confidence, gaps.
