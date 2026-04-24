# Claude Code configuration module
# Claude Code binary is managed externally (e.g. npm install -g @anthropic-ai/claude-code)
# ~/.claude/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (projects/, todos/, etc.) live directly in ~/.claude/
{
  config,
  pkgs,
  inputs,
  lib,
  nodejsPackage,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  installManifest = import ./install-manifest.nix {
    inherit
      config
      pkgs
      ;
  };
  mcpServers = import ./mcp-servers.nix {
    inherit
      homeDir
      pkgs
      inputs
      ;
  };
  # Shared Bash deny surface includes aws sso login; see denied-bash-commands.nix.
  deniedBash = import ./denied-bash-commands.nix { inherit pkgs; };
  instructionArtifacts = import ./instruction-artifacts.nix { inherit pkgs; };
  instructionFiles = instructionArtifacts {
    sharedCore = ./AGENTS.md;
    claudeOnly = ./CLAUDE.md;
    rulePaths = [ ];
  };

  # Generated patterns file name (change here to relocate)
  bashDenyPatternsName = "deny-bash-patterns.sh";

  # Merge repo scripts + generated patterns file into a single directory
  scriptsDir = pkgs.runCommand "claude-scripts" { } ''
    mkdir -p $out
    for f in ${./scripts}/*; do
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
          matcher = "*";
          hooks = [
            {
              type = "command";
              command = "$CLAUDE_CONFIG_DIR/scripts/claude-observe.sh pre";
            }
          ];
        }
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "$CLAUDE_CONFIG_DIR/scripts/claude-pretooluse-deny-bash.sh";
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
      PostToolUse = [
        {
          matcher = "*";
          hooks = [
            {
              type = "command";
              command = "$CLAUDE_CONFIG_DIR/scripts/claude-observe.sh post";
            }
          ];
        }
      ];
      PostToolUseFailure = [
        {
          matcher = "*";
          hooks = [
            {
              type = "command";
              command = "$CLAUDE_CONFIG_DIR/scripts/claude-observe.sh post";
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
              command = "$CLAUDE_CONFIG_DIR/scripts/claude-sessionstart-reload.sh";
            }
          ];
        }
      ];
      PreCompact = [
        {
          hooks = [
            {
              type = "command";
              command = "$CLAUDE_CONFIG_DIR/scripts/claude-precompact-save.sh";
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
      # Composite CLAUDE.md generated from AGENTS.md + Claude-only fragment
      ".claude/CLAUDE.md".source = instructionFiles.claudeMd;
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

      claudeObservationPermissions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        STATE_ROOT="''${XDG_STATE_HOME:-$HOME/.local/state}/claude"
        if [ -d "$STATE_ROOT" ]; then
          find "$STATE_ROOT" \
            \( -name 'observations*.jsonl' -o -name 'project.json' -o -name 'projects.json' \) \
            -type f |
            while IFS= read -r file; do
              chmod 600 "$file"
              chmod 700 "$(dirname "$file")"
            done
        fi
      '';
    };
  };
}
