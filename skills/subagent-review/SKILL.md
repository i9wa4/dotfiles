---
name: subagent-review
license: MIT
description: "USE FOR: Native five-perspective subagent review for substantive guardian/critic checks. DO NOT USE FOR: dispatcher fan-out, model/tier choice, implementation."
---

# Subagent Review

**UTILITY SKILL:** Use the current runtime's five native reviewer perspectives
for guardian/critic review. The active role owns synthesis and approval.

Do not implement, delegate approval, run dispatcher fan-out, select
models/tiers, or build cross-engine reviewer pools.

Normal lane: orchestrator -> guardian -> critic -> guardian -> orchestrator.

Guardian is the Codex review owner. Critic is the Claude subordinate reviewer.
Guardian packages evidence for critic, waits for the recommendation, then
returns a guardian verdict.

Default set: security, architecture, historian, code, and QA. In substantive
reviews, guardian uses these five Codex-native perspectives and critic uses
these five Claude-native perspectives. This replaces the old 10-reviewer
dispatcher without provider plumbing.

## Workflow

1. Run the cheapest relevant verifier first for code/config diffs.
2. For substantive reviews, use the five default native perspectives before
   synthesizing. For trivial follow-ups, direct review is acceptable if stated.
3. Add data or technical research reviewers only for specialized questions; do
   not replace the five defaults.
4. Use the current runtime's native subagent mechanism. No generated
   dispatcher, model/tier selection, or cross-engine pool.
5. Give each subagent a bounded read-only request with paths, context, and
   expected output shape.
6. Synthesize evidence yourself. Suppress unverified findings, deduplicate
   overlaps, and produce the active guardian verdict or critic recommendation.

## Role Rules

- Guardian uses Codex native reviewers, owns the final verdict, and treats
  critic's recommendation as evidence.
- Critic uses Claude native reviewers and returns a subordinate recommendation.
- Critic sends the review recommendation to guardian, not orchestrator.
- Reviewer subagents must not implement, edit files, commit, push, or act as
  the final approval authority.
- If subagent evidence is incomplete, continue direct review and report that.

## Output

Preserve reviewer perspective, target paths, checked evidence, severity,
confidence, and unresolved gaps. Final guardian verdicts and critic
recommendations use the guardian-mediated surface, not raw subagent output.
