# Dotfiles Operating Concepts

This repository manages the macOS Apple Silicon and Ubuntu 24.04/WSL2
engineering environment with Nix. The checked-in configuration binds terminal,
editor, shell, Claude Code, Codex and tmux behavior to repeatable machine
profiles. The repo-local [dotfiles Skill](../SKILL.md) is its maintenance entry;
`.claude/skills/dotfiles` points to the same source for Claude Code. It is not
globally installed or loaded in unrelated repositories.

## 1. Source ownership

- `flake.nix` and `flake.lock` pin dependencies. `nix/flake-parts/modules/`
  chooses host composition and top-level outputs. `nix/nix-darwin/` owns common
  macOS system settings. `nix/home-manager/` owns user-session tools and
  cross-platform behavior.
- `nix/home-manager/agents/shared/agent-skills.nix` selects the three
  dotfiles-authored personal/global Skills, the pinned PanePals distribution,
  active third-party Skills and reference-only provider packs. It emits Claude
  and Codex installations; generated home directories are outputs, not sources.
- `nix/home-manager/agents/shared/AGENTS.md` is the small notification
  bootstrap for both clients. The pinned PanePals binary supplies the team
  contract, HelpDocs, Skill bodies and resources. A complete custom
  `panepals.md` shadows its builtin default; adopting a new default therefore
  requires an explicit source/installation decision.
- `nix/home-manager/agents/shared/bash-commands-denied.nix` and the matching
  hook implement the shared Bash deny policy. Runtime-specific settings belong
  to `agents/claude/default.nix` and `agents/codex/default.nix`, with a stated
  reason for a product-only difference.
- `config/tmux/` owns visible pane titles and status. The pane title identifies
  a native PanePals role; filesystem hierarchy supports parent/child workspace
  routing. `config/vde/layout.yml` owns personal engine and layout choices.

## 2. Operational boundaries

Use Nix-managed or portable tools where shared behavior matters. Keep secrets,
local virtual environments, generated outputs and machine-specific values out
of public source. Keep active edits in a dedicated worktree. Preserve unrelated
and dirty worktrees. Generic Git/GitHub, records, review and communication
procedures belong to the matching PanePals Skills or CLI help, while this Skill
owns repository setup, Nix, hooks, editor/terminal settings and integration.
Source changes, Nix evaluation, installed-machine activation and live agent
behavior are different evidence stages; report each separately.

## 3. Claude/Codex parity map

The shared Nix sources target comparable worker behavior. These rows describe
current source configuration; they do not prove live machine activation.
Update them when changing either runtime's setting.

| Intent                     | Claude source                            | Codex source                                     | State                              |
| -------------------------- | ---------------------------------------- | ------------------------------------------------ | ---------------------------------- |
| Co-author attribution off  | `attribution.commit/pr=""`               | `command_attribution="disable"`                  | Aligned                            |
| Fast mode off              | `CLAUDE_CODE_DISABLE_FAST_MODE=1`        | `features.fast_mode=false`                       | Aligned                            |
| Feedback survey off        | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1`  | `feedback.enabled=false`                         | Aligned                            |
| Terminal title writes off  | `CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1`   | `tui.terminal_title=[]`                          | Aligned                            |
| Autocompact at 70%         | `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70`     | `model_auto_compact_token_limit` at 70%          | Aligned                            |
| Native terminal scrollback | `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1` | VDE `--no-alt-screen`                            | Aligned through different settings |
| Git guidance               | `includeGitInstructions=false`           | PanePals `git-github-operations` Skill installed | Shared source of authority         |
| Ask-to-continue tool       | `AskUserQuestion` denied                 | No equivalent configured tool                    | Claude-only control                |

`nix/home-manager/agents/claude/default.nix`,
`nix/home-manager/agents/codex/default.nix` and `config/vde/layout.yml`
are the authoritative settings. Both runtimes use the shared Bash deny source
and curated Skill sources. Claude's MCP servers and Codex Apps remain separate
product surfaces.

For the concrete agent setup see `nix/home-manager/agents/README.md`,
[Harness](harness-guidance.md) and
[Repo AI Contract](repo-ai-operating-contract.md).
