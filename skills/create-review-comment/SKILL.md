---
name: create-review-comment
license: MIT
description: |
  USE FOR: `$create-review-comment`, ai-create-review-comment, or terse PR-review-comment requests. Infers the PR and routes postman substantive review through guardian/critic without exposing mechanics. DO NOT USE FOR: unrelated tasks, broad rewrites, generated outputs, or posting comments without explicit approval.
---

# Create Review Comment

**UTILITY SKILL:** Draft Japanese GitHub PR review comments. Infer the PR,
route correctly, and keep guardian/critic mechanics internal.

**USE FOR:** review-comment drafting, related edits, verification, and handoff.

**DO NOT USE FOR:** unrelated domains, broad rewrites, generated runtime
outputs, replacing source of truth, or posting without explicit approval.

## 1. Boundary

This user-facing trigger owns target inference, Japanese draft output, and the
no-post-without-approval gate. Review procedure belongs to
`subagent-review`; GitHub mechanics and path hygiene belong to `github`.
In `tmux-a2a-postman`, orchestrator/worker only infer targets and collect PR
context before routing substantive review to guardian.

## 2. Workflow

1. Infer the target PR from the prompt, current branch, or GitHub context. If
   missing or ambiguous, ask only for the minimum target identifier.
2. Read [Preserved Guidance](references/preserved-guidance.md) before changing
   behavior or giving detailed instructions.
3. For substantive drafting, use `subagent-review` through postman: send the
   review package to guardian, let guardian request critic, and never launch
   reviewer subagents from orchestrator/worker. Do not ask the user for review
   mechanics.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Output draft comments visibly for user approval. Do not post them unless the
   user explicitly asks.

## 3. Examples

`$create-review-comment`, `$create-review-comment #123`, and
`ai-create-review-comment for this branch` all start target inference and
review-comment drafting.

## 4. References

- [Preserved Guidance](references/preserved-guidance.md)

## 5. Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
