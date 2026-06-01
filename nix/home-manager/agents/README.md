# Agents Tree Map

This directory is the source tree for the shared Claude Code and Codex CLI
setup.
Humans should edit files here, then rebuild.
Do not hand-edit `~/.claude/` or `~/.codex/`; those are installed runtime
artifacts.

## 1. Start Here

| If you want to change...    | Edit here                                                      | Installed result                                                                   |
| --------------------------- | -------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Persona / language / scope  | `config/tmux-a2a-postman/postman.md` `[common_template]` §2.17 | Delivered into every postman role on each `tmux-a2a-postman pop`                   |
| Dotfiles-owned skill bodies | `skills/<skill>/SKILL.md`                                      | Installed to both engines and indexed by postman.md `skill_path`                   |
| Native review skill         | `skills/subagent-review/SKILL.md`                              | Documents runtime-native reviewer subagent usage without ad hoc dispatcher tiers   |
| Native reviewer prompts     | `subagents/*.md`                                               | Prompt bodies for generated Claude Markdown and Codex TOML agent files             |
| Native reviewer metadata    | `subagents/metadata.nix`                                       | Per-agent model and effort defaults emitted into generated runtime agent files     |
| Shared install targets      | `shared/install-manifest.nix`                                  | Resolves generated Claude agent files and Codex TOML from shared subagent sources  |
| Local reusable skills       | `skills/<skill>/`, `shared/agent-skills.nix`                   | Installed to `~/.claude/skills/` and `~/.codex/skills/`                            |
| Skill description index     | `skills/skill-description-index/`                              | Reclassified for later migration into `skills/agent-skills-management/references/` |
| Hook/runtime scripts        | `scripts/*`                                                    | Installed to `~/.claude/scripts/` and/or `~/.codex/scripts/`                       |
| Shared runtime data         | `shared/mcp-servers.nix`, `shared/denied-bash-commands.nix`    | Empty MCP server set and shared Bash deny hook data emitted into both engines      |
| Claude runtime settings     | `claude/default.nix`                                           | `~/.claude/settings.json`, `~/.claude/.claude.json`, and symlinked runtime dirs    |
| Codex runtime settings      | `codex/default.nix`                                            | `~/.codex/config.toml`, `~/.codex/hooks.json`, and symlinked runtime dirs          |
| Top-level package boundary  | `default.nix`                                                  | Imports the agent modules and installs the shared CLI packages                     |

## 2. How Changes Flow

1. Edit the source markdown, scripts, skills, or Nix modules in this tree.
2. The persona / language / scope contract is delivered through
   `config/tmux-a2a-postman/postman.md` `[common_template]` on each
   `tmux-a2a-postman pop`. Dotfiles-owned skill bodies stay in
   `skills/<skill>/SKILL.md`; postman traffic gets only the generated
   `skill_path` catalog. There is no longer a generated CLAUDE.md or codex
   AGENTS.md installed at the runtime root.
3. `subagents/*.md` is the committed Markdown source of truth for native
   reviewer prompt bodies. `subagents/metadata.nix` is the shared source for
   runtime defaults such as model and effort. `shared/install-manifest.nix`
   generates Claude Markdown into `~/.claude/agents/` and Codex TOML into
   `~/.codex/agents/` from those sources.
4. `skills/subagent-review/SKILL.md` is installed through the normal local skill
   pipeline and documents reviewer usage without generating agent files.
5. `shared/install-manifest.nix` resolves the shared agent install targets and
   skill destinations that the runtime installers consume.
6. `shared/agent-skills.nix` validates skill sources and installs them into both
   runtimes.
7. `claude/default.nix` and `codex/default.nix` materialize the final runtime
   files during activation.

## 3. Refresh And Verify

| Goal                        | Command                                                   |
| --------------------------- | --------------------------------------------------------- |
| Validate the repo           | `nix flake check`                                         |
| Rebuild + activate on Linux | `nix run '.#switch'`                                      |
| Direct Linux activation     | `home-manager switch --flake '.#ubuntu' --impure`         |
| Rebuild + activate on macOS | `nix run '.#switch'`                                      |
| Direct macOS activation     | `sudo darwin-rebuild switch --flake '.#macos-p' --impure` |
| Direct macOS activation     | `sudo darwin-rebuild switch --flake '.#macos-w' --impure` |

## 4. Authoring Notes

- Keep reviewer agent prompt bodies and runtime metadata in `subagents/`. Do
  not hand-author or track generated Claude Markdown or Codex TOML copies.
  Runtime model defaults are explicit in `subagents/metadata.nix`; Codex
  `model = null` means the generated TOML omits `model` and inherits the parent
  session. Keep reviewer usage guidance in `skills/subagent-review/SKILL.md`.
- After setting up Claude Code on a new machine or after adding new projects,
  use `/agent-harness-engineering` and its Claude workspace trust workflow;
  otherwise interactive `PreToolUse` hooks can be skipped until workspace trust
  is recorded.

## 5. Rule Of Thumb

- If you are changing prompt wording, start with the markdown source files.
- If you are changing hook behavior, runtime settings, or install targets, edit
  the `.nix` modules.
- If a file lives under `shared/` and is named `install-manifest.nix`,
  `agent-skills.nix`, `mcp-servers.nix`, or `denied-bash-commands.nix`, it is
  composition or shared data code rather than final installed prompt text.
- Treat `~/.claude/` and `~/.codex/` as outputs of this tree, not as the
  editing surface.
