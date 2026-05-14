---
name: repo-local
license: MIT
description: |
  USE FOR: Lightweight dotfiles repo guardrails that are not owned by a focused skill; co-load with task-specific skills for scoped repo work. DO NOT USE FOR: worktree workflow, postman routing, agent harness design, skill authoring, markdown style, unrelated tasks, or generated runtime outputs.
---

# Repo Local

**UTILITY SKILL:** Apply this skill only as a small repo-wide guardrail layer.
Use focused skills as the source of truth for task procedures.

**USE FOR:** scoped dotfiles repo work where a task-specific skill also applies,
basic repository safety reminders, and pointers to the right owner.

**DO NOT USE FOR:** worktree workflow, postman routing, agent harness design,
skill authoring, markdown style, unrelated domains, broad rewrites outside the
request, generated runtime outputs, or replacing focused skills.

## Ownership

- Worktrees, tmux workspace navigation, and issue branch safety:
  `agent-workspace`.
- Claude/Codex config, hooks, postman routing, and installed agent harness:
  `agent-harness-engineering` plus the postman skills.
- Skill source edits and validation: `agent-skill-management`.
- Markdown formatting: `markdown`.
- Durable operating background: `docs/dotfiles-operating-concepts.md` and
  `docs/repo-ai-operating-contract.md`.

## Workflow

1. Load the focused skill that owns the requested work.
2. Inspect the relevant files, current repo conventions, and `git status`.
3. Make the smallest scoped change that satisfies the request.
4. Run the nearest focused validation.
5. Report verification results and any remaining risk.

## Guardrails

- Keep Linux and macOS behavior in mind; prefer Nix-managed or
  POSIX-compatible tools for shared repo workflows.
- Do not commit generated outputs, dependency directories, local virtual
  environments, or machine-specific values.
- Prefer simple dotfiles file management unless the target behavior really
  needs Home Manager or another heavier mechanism.

## Troubleshooting

If this skill and a focused skill disagree, follow the focused skill and record
the exception in the handoff.
