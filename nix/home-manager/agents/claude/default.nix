# Claude Code configuration module
# Claude Code binary is managed externally (e.g. npm install -g @anthropic-ai/claude-code)
# ~/.claude/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (projects/, todos/, etc.) live directly in ~/.claude/
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  installManifest = import ../shared/install-manifest.nix {
    inherit
      config
      pkgs
      ;
  };
  mcpServers = import ../shared/mcp-servers.nix {
    inherit
      pkgs
      inputs
      ;
  };
  # Shared Bash deny surface includes aws sso login; see shared/denied-bash-commands.nix.
  deniedBash = import ../shared/denied-bash-commands.nix { inherit pkgs; };

  # Generated patterns file name (change here to relocate)
  bashDenyPatternsName = "deny-bash-patterns.sh";

  # Merge repo scripts + generated patterns file into a single directory
  scriptsDir = pkgs.runCommand "claude-scripts" { } ''
    mkdir -p $out
    for f in ${../scripts}/*; do
      ln -s "$f" "$out/$(basename "$f")"
    done
    ln -s ${deniedBash.claudeCode.patternsFile} $out/${bashDenyPatternsName}
  '';

  # Transform MCP servers for claude mcp add-json (add type, filter empty attrs)
  mcpServerConfigs = builtins.mapAttrs (
    _: srv: { type = "stdio"; } // (lib.filterAttrs (_: v: v != null && v != [ ] && v != { }) srv)
  ) mcpServers;

  jsonFormat = pkgs.formats.json { };

  claudeSettings = {
    attribution = {
      commit = "";
      pr = "";
    };
    # Claude runtime state stays review_first; Claude's own age-based cleanup
    # bounds stale state without turning it into safe_cache.
    cleanupPeriodDays = 50;
    env = {
      BASH_DEFAULT_TIMEOUT_MS = "3000000";
      BASH_MAX_TIMEOUT_MS = "3000000";
      CLAUDE_AUTOCOMPACT_PCT_OVERRIDE = "70";
      CLAUDE_CODE_DISABLE_AUTO_MEMORY = "true";
      CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = "1";
      CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "true";
      CLAUDE_CODE_DISABLE_TERMINAL_TITLE = "true";
      CLAUDE_CODE_ENABLE_TELEMETRY = "false";
      CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS = "20000";
      CLAUDE_CODE_ENABLE_PROMPT_SUGGESTIONS = "false";
      # `1` forces permission mode to "default" and silently overrides
      # `--dangerously-skip-permissions`, so every Bash call falls back to
      # an "ask" prompt -- which the user can never auto-approve, hence the
      # exit 126 storm we just debugged. Disable until we can declare an
      # explicit `allowedTools` set.
      CLAUDE_CODE_SUBPROCESS_ENV_SCRUB = "0";
      ENABLE_TOOL_SEARCH = "auto:3";
      IS_DEMO = "true";
    };
    hooks = {
      UserPromptSubmit = [
        {
          hooks = [
            {
              type = "command";
              command = "$CLAUDE_CONFIG_DIR/scripts/common-userpromptsubmit.sh claude";
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
              command = "$CLAUDE_CONFIG_DIR/scripts/pretooluse-deny-bash.sh";
            }
          ];
        }
        {
          matcher = "Write|Edit|NotebookEdit";
          hooks = [
            {
              type = "command";
              command = "$CLAUDE_CONFIG_DIR/scripts/claude-pretooluse-deny-write.sh";
            }
          ];
        }
      ];
    };
    includeGitInstructions = false;
    language = "English";
    outputStyle = "Explanatory";
    permissions = {
      deny = deniedBash.claudeCode.denyPermissions ++ [
        "Read(**/*key*)"
        "Read(**/*token*)"
        "Read(.env*)"
        "Read(~/.ssh/**)"
        "Write(**/secrets/**)"
        "Write(.env*)"
      ];
    };
    showThinkingSummaries = true;
    statusLine = {
      type = "command";
      command = "$CLAUDE_CONFIG_DIR/scripts/claude-statusline.sh";
    };
  };

  settingsFile = jsonFormat.generate "claude-settings.json" claudeSettings;
in
{
  home = {
    file = {
      # Persona / language / scope is delivered through postman.md
      # common_template (§2.24) on each tmux-a2a-postman pop. Skill bodies
      # are loaded from ~/.claude/skills/ at session start. No CLAUDE.md
      # is installed at the runtime root anymore.
      # Nix store directory symlinks (rebuild required to update)
      "${installManifest.claude.agents.target}".source = installManifest.claude.agents.source;
      ".claude/scripts".source = scriptsDir;
    };

    activation = {
      # Copy settings.json as a writable file (not symlink).
      # Claude Code's /config editor writes user preferences back to settings.json;
      # a Nix store symlink would be read-only.
      claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        install -Dm644 ${settingsFile} "$HOME/.claude/settings.json"
      '';

      # Register MCP servers by writing directly to ~/.claude/.claude.json.
      # Replaces .mcpServers with the Nix-managed set (SSOT); stale entries are removed.
      claudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        TARGET="$HOME/.claude/.claude.json"
        SERVERS=${lib.escapeShellArg (builtins.toJSON mcpServerConfigs)}
        [ -f "$TARGET" ] || { mkdir -p "$(dirname "$TARGET")"; printf '{}' > "$TARGET"; }
        ${pkgs.jq}/bin/jq --argjson servers "$SERVERS" '.mcpServers = $servers' "$TARGET" > "$TARGET.tmp" \
          && mv "$TARGET.tmp" "$TARGET"
      '';

    };
  };
}
