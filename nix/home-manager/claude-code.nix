# Claude Code configuration module
# Uses programs.claude-code from home-manager unstable
# ~/.claude/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (projects/, todos/, etc.) live directly in ~/.claude/
{
  pkgs,
  inputs,
  ...
}: let
  mcpServers = import ./mcp-servers.nix {inherit pkgs inputs;};
in {
  programs.claude-code = {
    enable = true;
    package = pkgs.llm-agents.claude-code;

    # CLAUDE.md
    memory.source = ../../config/agents/AGENTS.md;

    # NOTE: rulesDir/agentsDir intentionally NOT used here.
    # They create per-file Nix store symlinks under ~/.claude/rules/ and
    # ~/.claude/agents/. When ~/.agents is an OOS symlink to the same source
    # directory, HM follows through and replaces repo files with Nix store
    # symlinks. Using home.file with directory-level Nix store source avoids this.

    # MCP servers (compiled into --mcp-config CLI flag on the wrapped binary)
    mcpServers = builtins.mapAttrs (_: srv: {type = "stdio";} // srv) mcpServers;

    settings = {
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
        ENABLE_TOOL_SEARCH = "auto:1";
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
                command = "printf '{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":\"Current time: %s\"}}' \"$(date +%Y-%m-%dT%H:%M:%S%z)\"";
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
      statusLine = {
        type = "command";
        command = "~/.claude/scripts/claude-statusline.sh";
      };
    };
  };

  # Nix store directory symlinks (rebuild required to update)
  home.file = {
    ".claude/rules".source = ../../config/agents/rules;
    ".claude/agents".source = ../../config/agents/subagents;
    ".claude/scripts".source = ../../config/agents/scripts;
  };
}

