---
name: repo-local
license: MIT
description: |
  USE FOR: Fallback routing to the focused dotfiles skills and docs when no
  narrower skill clearly owns the task. Use to identify the right owner for
  repo-local workflow, safety, workspace, harness, or skill-management
  guidance. DO NOT USE FOR: worktree creation, harness edits, skill edits,
  postman routing changes, or replacing a focused skill.
---

# Repo Local

**POINTER SKILL:** Use this only to route dotfiles repo questions to the
focused owner. Do not keep broad operating policy here.

**USE FOR:** Choosing the focused skill or document when the task is
repo-local but the owner is unclear.

**DO NOT USE FOR:** direct implementation, worktree creation, harness config,
skill editing, postman routing, generated runtime outputs, or replacing
repo-specific source of truth.

## Routing

- Worktrees, tmux workspaces, pane operations, and issue/PR worktree safety:
  use `agent-workspace`.
- Claude/Codex runtime config, hooks, Nix/Home Manager agent harness, and
  postman routing: use `agent-harness-engineering`.
- Adding, editing, validating, or publishing `skills/*`: use
  `agent-skill-management`.
- GitHub issue/PR retrieval, comments, commit messages, and public-surface path
  hygiene: use `github`.
- Markdown formatting and Japanese Markdown constraints: use `markdown`.
- Durable AI operating rules and task artifact workflow:
  `docs/repo-ai-operating-contract.md`.
- Repository operating concepts and background:
  `docs/dotfiles-operating-concepts.md`.
- Current worktree behavior:
  `docs/worktree-development.md` and
  `skills/agent-workspace/references/worktree-workflow.md`.

## Workflow

1. Identify the smallest focused owner from the routing list above.
2. Load that focused skill and follow its workflow.
3. If no focused owner exists, inspect the relevant docs and keep any change
   small, documented, and verified.

## References

- [Pointer Notes](references/preserved-guidance.md)

## Troubleshooting

If this skill appears to be the only owner for new durable behavior, prefer
creating or extending a focused skill instead of expanding `repo-local`.
