---
name: prompt-contracts-local
license: MIT
description: |
  Prompt, review-contract, and resume-handoff guidance for agent workflows in
  this Nix-managed setup. Use when:
  - Composing task prompts for agents in this repo
  - Designing structured review or adversarial-review prompt contracts
  - Writing resumable task prompts or result handoffs
  - Re-expressing useful old command-specific workflows as skill-side prompt
    patterns
---

# prompt-contracts-local

This skill captures the shared prompt-shaping patterns used across the current
`nix/home-manager/agents/` setup.

Use it for prompt and output contracts, not as a new runtime control plane.
This repo's runtime authority still lives in Nix-managed hooks, agents, MCP
definitions, and generated home files.

Core rules:

- Use one concrete task per agent run unless there is a clear reason to batch.
- Prefer compact XML-style prompt blocks over long freeform instructions.
- Tell the agent what done looks like, how to verify it, and when to keep going
  by default.
- Use machine-readable review output only when the downstream consumer benefits
  from it. Otherwise keep the repo's normal findings-first prose review style.
- Keep resumable results thread-aware and action-oriented. If a thread ID is
  known, surface it explicitly. If not, do not invent one.
- Treat old command-specific behavior as workflow intent to preserve in skills,
  scripts, or prompts. Do not reintroduce plugin frontmatter, `AskUserQuestion`,
  or `.claude-plugin` assumptions.

Recommended workflow:

1. Pick the smallest prompt shape that fits the task.
2. Add only the blocks the task actually needs.
3. Add a structured review contract only for review surfaces that should emit
   parseable output.
4. For long-running or multi-turn work, write the result so it can be resumed
   cleanly from saved handoff context.

Open these references as needed:

- [references/prompt-blocks.md](references/prompt-blocks.md)
- [references/review-output-contract.md](references/review-output-contract.md)
- [references/resume-handoff.md](references/resume-handoff.md)
