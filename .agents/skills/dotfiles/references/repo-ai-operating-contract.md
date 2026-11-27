# Repo AI Operating Contract

This page records dotfiles-specific runtime ownership. The selected PanePals
`panepals.md`, six upstream Skills and CLI help own their own generic roles,
communication, Git/GitHub, records and review procedures. This repository
chooses the exact binary revision, distribution source and runtime wiring; it
does not copy those procedures into another local policy.

## 1. Local sources

- `nix/home-manager/agents/shared/AGENTS.md` supplies the short notification
  bootstrap. Complete received archives carry the selected role contract.
- `nix/home-manager/agents/shared/agent-skills.nix` installs authored personal
  Skills and pinned PanePals thin entries in both supported runtimes. The
  binary and entries must be selected from one upstream revision. This
  repo-local dotfiles Skill is discovered from `.agents/skills/dotfiles` in
  Codex and `.claude/skills/dotfiles` in Claude Code, without global install.
- `nix/home-manager/agents/shared/bash-commands-denied.nix` and the shared
  PreToolUse hook implement Bash denials. Claude and Codex runtime emitters
  preserve one shared intent while documenting product-specific settings.
- tmux pane titles identify native PanePals roles. The role graph and authority
  come from the selected configuration; a personal VDE layout does not change
  them. An explicit custom `panepals.md` is a complete override.

## 2. Repository safeguards

Inspect actual sources and current status before changing behavior. Keep edits
in an isolated worktree, use the smallest relevant verification, and do not
commit generated dependencies, virtual environments, secret values or local
machine identifiers. Use repository-relative paths or stable URLs on public
GitHub surfaces. Use Nix-managed or portable tooling for macOS and Ubuntu
where shared behavior matters. A source diff, Nix check, machine activation
and live-agent validation are distinct evidence; do not infer one from another.

The local hooks and installed Skills cannot grant human authorization or change
PanePals role authority. Existing scoped human authorization persists. Runtime
permissions, explicit approval and a concrete target still govern effects. For
the wider architecture see [Operating Concepts](operating-concepts.md),
[Harness](harness-guidance.md) and
[Command Approval Design](agent-command-approval-design.md).
