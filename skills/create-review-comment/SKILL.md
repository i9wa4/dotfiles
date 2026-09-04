---
name: create-review-comment
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: `$create-review-comment`, ai-create-review-comment, or terse PR-review-comment requests. Infers the PR and routes postman substantive review through guardian/critic without exposing mechanics. DO NOT USE FOR: unrelated tasks, broad rewrites, generated outputs, or posting comments without explicit approval.
---

# Create Review Comment

User-facing trigger for drafting Japanese GitHub PR review comments.
`$create-review-comment`, `$create-review-comment #123`, and
`ai-create-review-comment for this branch` all start target inference and
drafting.

Owns target inference, Japanese draft output, and the no-post-without-approval
gate. Review procedure belongs to `subagent-review`; GitHub mechanics and path
hygiene belong to `dev-platform-workflow`. In `tmux-a2a-postman`,
orchestrator/worker only infer targets and collect PR context before routing
substantive review to guardian.

## 1. Workflow

1. Infer the target PR from the prompt, current branch, or GitHub context. If
   missing or ambiguous, ask only for the minimum target identifier.
2. Read [Workflow](references/workflow.md) before changing
   behavior or giving detailed instructions.
3. For substantive drafting, use `subagent-review` through postman: send the
   review package to guardian, let guardian request critic, and never launch
   reviewer subagents from orchestrator/worker. Do not ask the user for review
   mechanics.
4. Run the checks named in the workflow guide or the nearest repo harness.
5. Output draft comments visibly for user approval. Do not post them unless the
   user explicitly asks.

## 2. References

- [Workflow](references/workflow.md)
