# Prompt Contracts

Shared prompt-shaping patterns used across the current
`nix/home-manager/agents/` setup. Use this for prompt and output contracts,
not as a new runtime control plane. This repo's runtime authority still lives
in Nix-managed hooks, agents, MCP definitions, and generated home files.

## 1. Core Rules

- Use one concrete task per agent run unless there is a clear reason to batch.
- Prefer compact XML-style prompt blocks over long freeform instructions.
- Tell the agent what done looks like, how to verify it, and when to keep
  going by default.
- Use machine-readable review output only when the downstream consumer
  benefits from it. Otherwise keep the repo's normal findings-first prose
  review style.
- Keep resumable results thread-aware and action-oriented. If a thread ID is
  known, surface it explicitly. If not, do not invent one.
- Treat old command-specific behavior as workflow intent to preserve in
  skills, scripts, or prompts. Do not reintroduce plugin frontmatter,
  `AskUserQuestion`, or `.claude-plugin` assumptions.

## 2. Workflow

1. Pick the smallest prompt shape that fits the task.
2. Add only the blocks the task actually needs.
3. Add a structured review contract only for review surfaces that should emit
   parseable output.
4. For long-running or multi-turn work, write the result so it can be resumed
   cleanly from saved handoff context.
5. Before adding global prompt rules, classify the rule with
   [AI/Human Responsibility Boundaries](ai-human-responsibility-boundaries.md)
   and prefer the narrowest owner surface.

## 3. Reference Index

- [AI/Human Responsibility Boundaries](ai-human-responsibility-boundaries.md)
- [Prompt Blocks](prompt-blocks.md)
- [Review Output Contract](review-output-contract.md)
- [Resume Handoff](resume-handoff.md)
