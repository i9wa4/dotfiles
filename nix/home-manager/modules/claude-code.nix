# Claude Code configuration module
# Claude Code binary is managed externally (e.g. npm install -g @anthropic-ai/claude-code)
# ~/.claude/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (projects/, todos/, etc.) live directly in ~/.claude/
{
  pkgs,
  inputs,
  ...
}:
let
  mcpServers = import ./mcp-servers.nix { inherit pkgs inputs; };

  jsonFormat = pkgs.formats.json { };

  claudeSettings = {
    cleanupPeriodDays = 36000;
    env = {
      BASH_DEFAULT_TIMEOUT_MS = "3000000";
      BASH_MAX_TIMEOUT_MS = "3000000";
      CLAUDE_CODE_DISABLE_AUTO_MEMORY = "true";
      CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "true";
      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "true";
      CLAUDE_CODE_DISABLE_TERMINAL_TITLE = "true";
      CLAUDE_CODE_ENABLE_TASKS = "true";
      CLAUDE_CODE_ENABLE_TELEMETRY = "false";
      CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS = "25000";
      ENABLE_TOOL_SEARCH = "auto:3";
      IS_DEMO = "true";
    };
    attribution = {
      commit = "";
      pr = "";
    };
    permissions = {
      deny = [
        "Bash(git -C *)"
        "Bash(git push*)"
        "Bash(git rebase*)"
        "Bash(git reset*)"
        "Bash(rm *)"
        "Bash(sudo *)"
        "Read(**/*key*)"
        "Read(**/*token*)"
        "Read(.env*)"
        "Read(~/.ssh/**)"
        "Write(**/secrets/**)"
        "Write(.env*)"
      ];
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
    # MCP servers moved here from --mcp-config CLI flag (externally managed binary)
    mcpServers = builtins.mapAttrs (_: srv: { type = "stdio"; } // srv) mcpServers;
  };

  settingsFile = jsonFormat.generate "claude-settings.json" claudeSettings;
in
{
  home.file = {
    # CLAUDE.md (Nix store, rebuild required to update)
    ".claude/CLAUDE.md".source = ../../../config/agents/AGENTS.md;
    # settings.json (Nix store, rebuild required to update)
    ".claude/settings.json".source = settingsFile;
    # Nix store directory symlinks (rebuild required to update)
    ".claude/rules".source = ../../../config/agents/rules;
    ".claude/agents".source = ../../../config/agents/subagents;
    ".claude/scripts".source = ../../../config/agents/scripts;
  };
}
