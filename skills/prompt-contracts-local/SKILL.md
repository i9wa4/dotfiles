---
name: prompt-contracts-local
license: MIT
description: |
  Compatibility trigger for task prompt, review contract, prompt block, and resume-handoff requests. Route discovery to agent-harness-engineering, which owns the details.
---

# Prompt Contracts Local

**COMPATIBILITY TRIGGER:** This standalone skill has been demoted. The detailed
owner for task prompts, review contracts, and resume-handoff patterns for
Claude Code and Codex CLI agent workflows is `agent-harness-engineering`.

**USE FOR:** Discovery compatibility when a task names `prompt-contracts-local`
or asks for task prompts, review contracts, prompt blocks, or resume-handoff
patterns in this repo.

**DO NOT USE FOR:** maintaining separate prompt-contract guidance, unrelated
domains, broad rewrites outside the request, generated runtime outputs, or
replacing the `agent-harness-engineering` source of truth.

## Workflow

1. Switch to `skills/agent-harness-engineering/SKILL.md` for the active
   workflow.
2. For detailed prompt-contract guidance, read these target references:
   `prompt-contracts-preserved-guidance.md`, `prompt-blocks.md`,
   `review-output-contract.md`, and `resume-handoff.md`.
3. Follow the validation and handoff rules from `agent-harness-engineering`.

## Examples

For a request in this domain, route to `agent-harness-engineering`, load the
prompt-contract reference that matches the task, run focused checks, and
summarize the result.

## References

Detailed references now live under
`skills/agent-harness-engineering/references/`.

## Troubleshooting

If this compatibility trigger and `agent-harness-engineering` disagree, follow
`agent-harness-engineering` and record the exception in the handoff.
