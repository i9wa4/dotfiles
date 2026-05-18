---
name: create-review-comment
license: MIT
description: |
  USE FOR: `$create-review-comment`, ai-create-review-comment, or terse requests to review a PR and draft Japanese GitHub review comments. Infers the target PR when possible and starts the normal subagent-review-backed workflow without exposing guardian/critic mechanics. DO NOT USE FOR: unrelated tasks, broad rewrites, generated runtime outputs, or posting comments without explicit user approval.
---

# Create Review Comment

**UTILITY SKILL:** Draft Japanese GitHub PR review comments for
`$create-review-comment`, ai-create-review-comment, or terse review-comment
requests. Infer the PR and do not expose guardian or critic mechanics.

**USE FOR:** review-comment drafting requests, Japanese GitHub PR review
comment drafts, related edits, verification, and handoff in this domain.

**DO NOT USE FOR:** unrelated domains, broad rewrites, generated runtime
outputs, replacing repo source of truth, or posting comments without explicit
user approval.

## Boundary

This is a thin user-facing trigger. It owns target inference, Japanese draft
output, and the no-post-without-explicit-approval gate. Review procedure
belongs to `subagent-review`; GitHub mechanics and path hygiene belong to
`github`.

## Workflow

1. Infer the target PR from the prompt, current branch, or GitHub context. If
   missing or ambiguous, ask only for the minimum target identifier.
2. Read [Preserved Guidance](references/preserved-guidance.md) before changing
   behavior or giving detailed instructions.
3. For substantive review-comment drafting, use the separate
   `subagent-review` engine internally; do not embed or redefine it. Do not
   ask the user for guardian, critic, reviewer-pool, model, or provider
   details.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Output draft comments visibly for user approval. Do not post them unless the
   user explicitly asks.

## Examples

`$create-review-comment`, `$create-review-comment #123`, and
`ai-create-review-comment for this branch` all start target inference and
review-comment drafting.

## References

- [Preserved Guidance](references/preserved-guidance.md)

## Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
