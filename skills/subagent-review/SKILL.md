---
name: subagent-review
license: MIT
description: "USE FOR: Guardian and critic peer reviews using five native reviewer perspectives, with guardian aggregation. DO NOT USE FOR: implementation, dispatcher fan-out, model/tier overrides, or public posting."
---

# Subagent Review

**UTILITY SKILL:** Use the current runtime's five native reviewer perspectives
for guardian/critic review. Do not implement, delegate approval, dispatch
fan-out, override models/tiers, or build cross-engine reviewer pools.

Normal message lane: orchestrator -> guardian -> critic -> guardian ->
orchestrator.

Guardian and critic are peer review roles. Guardian aggregates the final result.

Default set: security, architecture, historian, code, and QA.

## 1. Boundary

This skill owns reviewer perspectives, guardian/critic review flow, synthesis,
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

- Guardian uses Codex reviewers and aggregates the final verdict.
- Critic uses Claude native reviewers and returns independent review evidence.
- Critic sends the review result to guardian for aggregation, not orchestrator.
- Reviewer subagents must not edit, commit, push, or approve.
- If evidence is incomplete, continue direct review.

## 4. Output

Preserve perspective, paths, checked evidence, severity, confidence, and gaps.
Final verdicts use the guardian-mediated aggregation surface, not raw subagent
output.
