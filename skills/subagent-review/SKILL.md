---
name: subagent-review
license: MIT
description: "USE FOR: Guardian/critic reviews using five native perspectives with guardian aggregation. DO NOT USE FOR: implementation, dispatcher fan-out, model overrides, or public posting."
---

# Review

**UTILITY SKILL:** Use five native perspectives for guardian/critic review. Do
not implement, approve, fan out dispatchers, override models/tiers, or build
cross-engine pools.

Lane: orchestrator -> guardian -> critic -> guardian -> orchestrator.

Guardian and critic are peer roles. Guardian aggregates the result.

Defaults: security, architecture, historian, code, QA.

## 1. Boundary

This skill owns reviewer perspectives, flow, synthesis, severity, and output.
`postman.md` owns live route, verdicts, no-bypass gates, public approval.
`github` owns GitHub mechanics; `create-review-comment` owns user-facing PR
drafts.

## 2. Workflow

1. Run the cheapest relevant verifier first.
2. For substantive reviews, use the five defaults before synthesis. Direct
   review is acceptable for stated trivial follow-ups.
3. Run each wave in parallel; close it before second-wave validators.
4. Add specialized reviewers only for specialized questions; do not replace the
   defaults.
5. Use native subagents only. No dispatcher, model/tier overrides, or
   cross-engine pool. Defaults live in `subagents/metadata.nix`.
6. Give bounded read-only paths, context, and output shape.
7. Suppress unverified findings, deduplicate, and produce the verdict.

## 3. Roles

- Guardian uses Codex reviewers and aggregates the verdict.
- Critic uses Claude reviewers and returns independent review evidence.
- Critic sends the review result to guardian for aggregation, not orchestrator.
- Reviewer subagents must not edit, commit, push, or approve.
- If evidence is incomplete, continue direct review.

## 4. Output

Preserve perspective, paths, evidence, severity, confidence, and gaps.
Final verdicts use the guardian-mediated aggregation surface, not raw subagent
output.

## 5. Tier 2 Quality Audit

Run a deep meta-review only when orchestrator explicitly requests a Tier 2
quality audit. Guardian assigns one bounded meta-reviewer and returns the
aggregated assessment with `Tier 2 quality audit: complete`. Do not start
another guardian/critic loop.
