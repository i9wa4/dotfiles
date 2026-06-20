---
name: subagent-review
license: MIT
description: "USE FOR: Five-perspective guardian/critic review routing. DO NOT USE FOR: implementation, dispatcher fan-out, model/tier overrides, or public posting."
---

# Subagent Review

**UTILITY SKILL:** Use the current runtime's five native reviewer perspectives
for guardian/critic review. Do not implement, delegate approval, dispatch
fan-out, override models/tiers, or build cross-engine reviewer pools.

Normal lane: orchestrator -> guardian -> critic -> guardian -> orchestrator.

Guardian is the Codex review owner. Critic is the Claude subordinate reviewer.

Default set: security, architecture, historian, code, and QA.

## 1. Boundary

This skill owns reviewer perspectives, guardian/critic handoff, synthesis,
severity, and output expectations. `postman.md` owns live route, reply flow,
verdicts, no-bypass gates, and public-posting approval gates. `github` owns
GitHub mechanics; `create-review-comment` owns user-facing PR comment drafts.

## 2. Workflow

1. Run the cheapest relevant verifier first.
2. For substantive reviews, use the five defaults before synthesizing. Direct
   review is acceptable for trivial follow-ups if stated.
3. Run each wave in parallel; close it before second-wave validators.
4. Add data or research reviewers only for specialized questions; do not
   replace the defaults.
5. Use native subagents only. No dispatcher, model/tier overrides, or
   cross-engine pool. Per-agent defaults live in `subagents/metadata.nix`.
6. Give each subagent bounded read-only paths, context, and output shape.
7. Suppress unverified findings, deduplicate, and produce the verdict or
   recommendation.

## 3. Role Rules

- Guardian uses Codex reviewers, owns the final verdict, and treats the
  critic recommendation as evidence.
- Critic uses Claude native reviewers and returns a recommendation.
- Critic sends the review recommendation to guardian, not orchestrator.
- Reviewer subagents must not edit, commit, push, or approve.
- If evidence is incomplete, continue direct review.

## 4. Output

Preserve perspective, paths, checked evidence, severity, confidence, and gaps.
Final verdicts and recommendations use the guardian-mediated surface, not raw
subagent output.
