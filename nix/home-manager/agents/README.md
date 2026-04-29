# Agents Tree Map

This directory is the source tree for the shared Claude Code and Codex CLI
setup.
Humans should edit files here, then rebuild.
Do not hand-edit `~/.claude/` or `~/.codex/`; those are installed runtime
artifacts.

## Start Here

| If you want to change...      | Edit here                                                                  | Installed result                                                                   |
| ----------------------------- | -------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Persona / language / scope    | `config/tmux-a2a-postman/postman.md` `[common_template]` §2.24            | Delivered into every postman role on each `tmux-a2a-postman pop`                  |
| Repo-local skill bodies       | `skills/<skill>/SKILL.md`                                                  | Installed to `~/.claude/skills/` and inlined into postman.md `[common_template]`  |
| Shared subagents              | `subagents/*.md`, `families/subagents/metadata.nix`                       | Generated into `~/.claude/agents/` and `~/.codex/agents/`                          |
| Review stack prompts/skills   | `review/refs/`, `review/skills/`, `review/review-artifacts-gen.nix`       | Generated reviewer agents and `subagent-review-*` skills                           |
| Family merge layer            | `families/default.nix`, `families/subagents/`, `families/review/`         | Merges family-local agent outputs before installation                              |
| Shared install targets        | `install-manifest.nix`                                                     | Resolves the common Claude/Codex agent targets and skill destinations              |
| Local reusable skills         | `skills/<skill>/`, `agent-skills.nix`                                      | Installed to `~/.claude/skills/` and `~/.codex/skills/`                            |
| Hook/runtime scripts          | `scripts/*`                                                                | Installed to `~/.claude/scripts/` and/or `~/.codex/scripts/`                       |
| Claude runtime settings       | `claude-code.nix`, `mcp-servers.nix`, `denied-bash-commands.nix`           | `~/.claude/settings.json`, `~/.claude/.claude.json`, and symlinked runtime dirs    |
| Codex runtime settings        | `codex-cli.nix`, `mcp-servers.nix`, `denied-bash-commands.nix`             | `~/.codex/config.toml`, `~/.codex/hooks.json`, `~/.codex/rules/`, and runtime dirs |
| Top-level package boundary    | `default.nix`                                                              | Imports the agent modules and installs the shared CLI packages                     |

## How Changes Flow

1. Edit the source markdown, scripts, skills, or Nix modules in this tree.
2. The persona / language / scope contract and the repo-local skill bodies
   are delivered through `config/tmux-a2a-postman/postman.md`
   `[common_template]` on each `tmux-a2a-postman pop`. There is no longer
   a generated CLAUDE.md or codex AGENTS.md installed at the runtime root.
3. `families/subagents/metadata.nix` defines the shared Claude/Codex metadata
   for the subagent family while `subagents/*.md` stays the prompt-body source.
4. `families/default.nix` merges family-local agent outputs for the installed
   Claude and Codex agent directories.
5. `install-manifest.nix` resolves the shared agent install targets and skill
   destinations that the runtime installers consume.
6. `agent-skills.nix` validates skill sources and installs them into both
   runtimes.
7. `claude-code.nix` and `codex-cli.nix` materialize the final runtime files
   during activation.

## Refresh And Verify

| Goal                        | Command                                                   |
| --------------------------- | --------------------------------------------------------- |
| Validate the repo           | `nix flake check`                                         |
| Rebuild + activate on Linux | `nix run '.#switch'`                                      |
| Direct Linux activation     | `home-manager switch --flake '.#ubuntu' --impure`         |
| Rebuild + activate on macOS | `nix run '.#switch'`                                      |
| Direct macOS activation     | `sudo darwin-rebuild switch --flake '.#macos-p' --impure` |
| Direct macOS activation     | `sudo darwin-rebuild switch --flake '.#macos-w' --impure` |

## Authoring Notes

- Keep reviewer and subagent implementation details near `review/` and
  `subagents/`, not in the top-level runtime prompt files.
- After setting up Claude Code on a new machine or after adding new projects,
  run `/claude-workspace-trust-fix`; otherwise interactive `PreToolUse` hooks
  can be skipped until workspace trust is recorded.

## Rule Of Thumb

- If you are changing prompt wording, start with the markdown source files.
- If you are changing hook behavior, runtime settings, or install targets, edit
  the `.nix` modules.
- If a file is named `install-manifest.nix`, `families/default.nix`,
  `render-*.nix`, or `review-artifacts-gen.nix`, it is composition code
  rather than final installed prompt text.
- Treat `~/.claude/` and `~/.codex/` as outputs of this tree, not as the
  editing surface.
