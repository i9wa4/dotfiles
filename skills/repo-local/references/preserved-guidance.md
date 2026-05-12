# Pointer Notes

`repo-local` is intentionally small. It exists only to help agents find the
focused skill or document that owns a repo-local topic.

## Focused Owners

- `agent-workspace`: worktrees, tmux workspace boot, pane operations, and
  issue/PR worktree safety.
- `agent-harness-engineering`: Claude/Codex runtime config, hooks, Nix/Home
  Manager agent modules, skill installation pipeline, and postman routing.
- `agent-skill-management`: source-owned `skills/*` changes and validation.
- `github`: GitHub CLI usage, comments, issues, PRs, and commit-message rules.
- `markdown`: Markdown formatting and Japanese Markdown constraints.

## Document Owners

- `docs/repo-ai-operating-contract.md`: durable AI operating rules, `mkmd`
  artifacts, review routing, hooks, and installed runtime behavior.
- `docs/dotfiles-operating-concepts.md`: high-level philosophy and background
  for the repo harness.
- `docs/worktree-development.md`: command-level worktree behavior.
- `skills/agent-workspace/references/worktree-workflow.md`: focused
  agent-facing worktree workflow.

Do not add broad workflow, safety, worktree, harness, or skill-authoring rules
back into this reference. Move them to the focused owner instead.
