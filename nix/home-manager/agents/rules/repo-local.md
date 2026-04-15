# Repo-Local Operating Rules

These are the residual repo-local runtime rules that still need to load in
Claude and Codex sessions even when `tmux-a2a-postman` carries the common role
contract for postman-driven work.

## 1. Workflow

- Read a file in full at a time, not separately
- Do not delete unmentioned handlers, functions, or sections
- Do not add unnecessary error handling, backward compatibility, or defensive
  code
- Respect YAGNI and KISS principles
- Prefer the smallest next step that produces a verifiable result; when
  changing behavior and a cheap failing test or reproducer is possible, start
  there
- Propose additional changes and wait for approval
- When explaining things to humans, use ELI5-like plain language without losing
  accuracy
- Verify changes took effect before reporting success; show actual output as
  evidence
- Verify findings against the actual repo/code before reporting. Flag confidence
  level.
- Follow README.md and CONTRIBUTING.md if they exist
- For `tmux-a2a-postman` role work, follow
  `config/tmux-a2a-postman/postman.md` and
  `docs/repo-ai-operating-contract.md` instead of restating that node contract
  from memory

## 2. Safety

- This dotfiles repo targets both Linux and macOS; prefer Nix-managed tools
  or POSIX-compatible commands to avoid platform differences
- Do not pollute global environment (use venv, nvm, rbenv, etc.)
- Do not commit generated files (lock files, `node_modules/`, `.venv/`, etc.)
- Do not use complex tooling (home-manager modules) when simple solutions
  (symlinks, plain files) suffice for config file management in dotfiles
- Never hardcode user-specific values (usernames, hostnames, machine names) in
  shared Nix configs; use `config.home.username` or pass values as arguments
- Some panes are read-only. Before attempting edits, check write
  permissions. If blocked, delegate the edit to the appropriate agent.

## 3. Files

- Create working files (not tracked by git) with `mkmd` (`mkmd --help`)
- Match comment language in target file
- Check entire file for consistency; if unclear, check surrounding files
- Use uppercase for annotations: NOTE:, TODO:, FIXME:, WARNING:

## 4. Rollback

- Do not refactor or "improve" other code during rollback
- Revert ONLY the specified changes
- Confirm exact files and lines before reverting

## 5. Environment

- Always running inside a tmux pane
- Your role name: `tmux display-message -p '#{pane_title}'`
