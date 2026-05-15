---
name: subagent-review
license: MIT
description: "USE FOR: Native subagent review for substantive guardian/critic code or plan checks. DO NOT USE FOR: dispatcher fan-out, model/tier choice, implementation."
---

# Subagent Review

**UTILITY SKILL:** Use native reviewer subagents as focused helpers for
guardian/critic review. The active role still owns synthesis and approval.

No implementation, approval delegation, dispatcher fan-out, model/tier
selection, or cross-engine reviewer pools.

Normal review lane:

```text
orchestrator -> guardian -> critic -> guardian -> orchestrator
```

Guardian is the Codex higher-level review owner. Critic is the Claude
subordinate final-pass reviewer. Guardian sends critic a compact package, waits
for critic's recommendation, then relays a guardian-owned verdict.

## Workflow

1. Run the cheapest relevant verifier before requesting reviewer help when a
   code or config diff is present.
2. For substantive reviews, default to native reviewer subagents. For a trivial
   follow-up, direct review is acceptable if you state why.
3. Select only the reviewer perspectives needed for the current risk:
   security, architecture, historian, code, data, QA, or technical research.
4. Use the current runtime's native subagent mechanism. No generated
   dispatcher, model selection, tier selection, or cross-engine pool.
5. Give each subagent a bounded read-only request with paths, issue/PR context,
   and expected output shape.
6. Synthesize evidence yourself. Suppress unverified findings, deduplicate
   overlaps, and produce the active guardian verdict or critic recommendation.

## Role Rules

- Guardian uses Codex native reviewers, owns the final verdict, and treats
  critic's recommendation as evidence.
- Critic uses Claude native reviewers and returns a subordinate recommendation.
- Critic sends the review recommendation to guardian, not orchestrator.
- Reviewer subagents must not implement, edit files, commit, push, or act as
  the final approval authority.
- If subagent evidence is incomplete or unavailable, continue direct review and
  report the limitation.

## Output

Preserve reviewer perspective, target paths, checked evidence, findings with
severity and confidence, and unresolved gaps. For final guardian verdicts or
critic recommendations, use the normal guardian-mediated review surface instead
of forwarding raw subagent output.
