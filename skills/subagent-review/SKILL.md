---
name: subagent-review
license: MIT
description: "USE FOR: Native five-perspective guardian/critic review. DO NOT USE FOR: implementation, dispatcher fan-out, model/tier choice, or public comment posting."
---

# Subagent Review

**UTILITY SKILL:** Use the current runtime's five native reviewer perspectives
for guardian/critic review. The active role owns synthesis and approval. Do
not implement, delegate approval, run dispatcher fan-out, select models/tiers,
or build cross-engine reviewer pools.

Normal lane: orchestrator -> guardian -> critic -> guardian -> orchestrator.

Guardian is the Codex review owner. Critic is the Claude subordinate reviewer.
Guardian packages evidence for critic, waits for the recommendation, then
returns the verdict.

Default set: security, architecture, historian, code, and QA. In substantive
reviews, guardian uses these five Codex-native perspectives and critic uses
these five Claude-native perspectives.

## Boundary

This skill owns reviewer perspectives, guardian/critic handoff, synthesis,
severity, and output expectations. `postman.md` owns only the live route, reply
flow, verdicts, no-bypass gates, and public-posting approval gates. `github`
owns GitHub mechanics; `create-review-comment` owns user-facing PR comment
drafts.

## Workflow

1. Run the cheapest relevant verifier first.
2. For substantive reviews, use the five defaults before synthesizing. Direct
   review is acceptable for trivial follow-ups if stated.
3. Add data or research reviewers only for specialized questions; do not
   replace the defaults.
4. Use native subagents only. No dispatcher, model/tier selection, or
   cross-engine pool.
5. Give each subagent bounded read-only paths, context, and output shape.
6. Suppress unverified findings, deduplicate, and produce the verdict or
   recommendation.

## Role Rules

- Guardian uses Codex reviewers, owns the final verdict, and treats the
  critic recommendation as evidence.
- Critic uses Claude native reviewers and returns a recommendation.
- Critic sends the review recommendation to guardian, not orchestrator.
- Reviewer subagents must not edit, commit, push, or approve.
- If evidence is incomplete, continue direct review.

## Output

Preserve perspective, paths, checked evidence, severity, confidence, and gaps.
Final verdicts and recommendations use the guardian-mediated surface, not raw
subagent output.
