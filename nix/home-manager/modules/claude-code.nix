# Claude Code configuration module
# Claude Code binary is managed externally (e.g. npm install -g @anthropic-ai/claude-code)
# ~/.claude/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (projects/, todos/, etc.) live directly in ~/.claude/
{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  mcpServers = import ./mcp-servers.nix { inherit pkgs inputs; };
  prohibitedBash = import ./prohibited-bash-commands.nix;

  jsonFormat = pkgs.formats.json { };

  claudeSettings = {
    attribution = {
      commit = "";
      pr = "";
    };
    cleanupPeriodDays = 36000;
    env = {
      BASH_DEFAULT_TIMEOUT_MS = "3000000";
      BASH_MAX_TIMEOUT_MS = "3000000";
      CLAUDE_AUTOCOMPACT_PCT_OVERRIDE = "70";
      CLAUDE_CODE_DISABLE_AUTO_MEMORY = "true";
      CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "true";
      CLAUDE_CODE_DISABLE_TERMINAL_TITLE = "true";
      CLAUDE_CODE_ENABLE_TELEMETRY = "false";
      CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS = "25000";
      CLAUDE_CODE_ENABLE_PROMPT_SUGGESTIONS = "false";
      ENABLE_TOOL_SEARCH = "auto:3";
      IS_DEMO = "true";
    };
    hooks = {
      UserPromptSubmit = [
        {
          hooks = [
            {
              type = "command";
              command = "printf '{\"additionalContext\":\"Current time: %s\"}' \"$(date +%Y-%m-%dT%H:%M:%S%z)\"";
            }
          ];
        }
      ];
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "~/.claude/scripts/claude-pretooluse-bash-deny.sh";
            }
          ];
        }
        {
          matcher = "Write|Edit|NotebookEdit";
          hooks = [
            {
              type = "command";
              command = "~/.claude/scripts/claude-pretooluse-write-deny.sh";
            }
          ];
        }
        {
          matcher = "*";
          hooks = [
            {
              type = "command";
              command = "~/.claude/scripts/claude-observe.sh pre";
            }
          ];
        }
      ];
      PostToolUse = [
        {
          matcher = "*";
          hooks = [
            {
              type = "command";
              command = "~/.claude/scripts/claude-observe.sh post";
            }
          ];
        }
      ];
      SessionStart = [
        {
          matcher = "compact|resume|clear";
          hooks = [
            {
              type = "command";
              command = "~/.claude/scripts/claude-sessionstart-reload.sh";
            }
          ];
        }
      ];
      PreCompact = [
        {
          hooks = [
            {
              type = "command";
              command = "~/.claude/scripts/claude-precompact-save.sh";
            }
          ];
        }
      ];
    };
    includeGitInstructions = false;
    language = "English";
    # MCP servers moved here from --mcp-config CLI flag (externally managed binary)
    mcpServers = builtins.mapAttrs (
      _: srv: { type = "stdio"; } // (lib.filterAttrs (_: v: v != null && v != [ ] && v != { }) srv)
    ) mcpServers;
    permissions = {
      deny = (map (cmd: "Bash(${cmd.claudeGlob})") prohibitedBash) ++ [
        "Read(**/*key*)"
        "Read(**/*token*)"
        "Read(.env*)"
        "Read(~/.ssh/**)"
        "Write(**/secrets/**)"
        "Write(.env*)"
      ];
    };
    statusLine = {
      type = "command";
      command = "~/.claude/scripts/claude-statusline.sh";
    };
  };

  settingsFile = jsonFormat.generate "claude-settings.json" claudeSettings;
in
{
  home.file = {
    # CLAUDE.md (Nix store, rebuild required to update)
    ".claude/CLAUDE.md".source = ../../../agents/CLAUDE.md;
    # Nix store directory symlinks (rebuild required to update)
    ".claude/rules".source = ../../../agents/rules;
    ".claude/agents".source = ../../../agents/subagents;
    ".claude/scripts".source = ../../../agents/scripts;
  };

  # Copy settings.json as a writable file (not symlink).
  # Claude Code needs write access for MCP server runtime state.
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -Dm644 ${settingsFile} "$HOME/.claude/settings.json"
  '';
}
