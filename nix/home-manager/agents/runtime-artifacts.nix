# Shared Claude/Codex runtime artifacts derived from the repo's Nix sources
{
  pkgs,
  lib,
  inputs,
  homeDir,
  nodejsPackage,
}:
let
  families = import ./families/default.nix { inherit pkgs; };
  mcpServers = import ./mcp-servers.nix {
    inherit
      homeDir
      pkgs
      inputs
      nodejsPackage
      ;
  };
  deniedBash = import ./denied-bash-commands.nix { inherit pkgs; };
  instructionArtifacts = import ./instruction-artifacts.nix { inherit pkgs; };
  instructionFiles = instructionArtifacts {
    sharedCore = ./AGENTS.md;
    claudeOnly = ./CLAUDE.md;
    rulePaths = [
      ./rules/bash.md
      ./rules/github.md
      ./rules/markdown.md
      ./rules/python.md
    ];
  };

  claudeScriptsDir = pkgs.runCommand "claude-scripts" { } ''
    mkdir -p $out
    for f in ${./scripts}/*; do
      ln -s "$f" "$out/$(basename "$f")"
    done
    ln -s ${deniedBash.claudeCode.patternsFile} "$out/deny-bash-patterns.sh"
  '';

  mcpServerConfigs = builtins.mapAttrs (
    _: srv: { type = "stdio"; } // (lib.filterAttrs (_: v: v != null && v != [ ] && v != { }) srv)
  ) mcpServers;

  jsonFormat = pkgs.formats.json { };
  tomlFormat = pkgs.formats.toml { };

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
      CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS = "20000";
      CLAUDE_CODE_ENABLE_PROMPT_SUGGESTIONS = "false";
      CLAUDE_CODE_SUBPROCESS_ENV_SCRUB = "1";
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

  claudeSettingsFile = jsonFormat.generate "claude-settings.json" claudeSettings;

  defaultRulesContent = ''
    # Exec policy rules for Codex CLI
    # Generated from nix/home-manager/agents/denied-bash-commands.nix
    # File access restrictions (Read/Write patterns) have no Codex equivalent.

    ${deniedBash.codexCli.rulesContent}
  '';

  generatedDefaultRules = pkgs.writeText "default.rules" defaultRulesContent;

  codexRulesDir = pkgs.runCommand "codex-rules" { } ''
    mkdir -p $out
    cp ${generatedDefaultRules} "$out/default.rules"
  '';

  codexScriptsDir = pkgs.runCommand "codex-scripts" { } ''
    mkdir -p $out
    for f in ${./scripts}/codex-*; do
      ln -s "$f" "$out/$(basename "$f")"
    done
    ln -s ${./scripts}/common-userpromptsubmit.sh "$out/common-userpromptsubmit.sh"
    ln -s ${deniedBash.claudeCode.patternsFile} "$out/deny-bash-patterns.sh"
  '';

  codexHooks = {
    hooks = {
      SessionStart = [
        {
          matcher = "startup|resume";
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/codex-sessionstart-reload.sh";
              statusMessage = "Loading Codex handoff";
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
              command = "$HOME/.codex/scripts/codex-pretooluse-deny-bash.sh";
              statusMessage = "Checking Bash policy";
            }
          ];
        }
      ];
      PostToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/codex-posttooluse-review.sh";
              statusMessage = "Reviewing Bash feedback";
            }
          ];
        }
      ];
      UserPromptSubmit = [
        {
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/common-userpromptsubmit.sh codex";
            }
          ];
        }
      ];
      Stop = [
        {
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/codex-stop-save.sh";
              statusMessage = "Saving Codex handoff";
              timeout = 10;
            }
          ];
        }
      ];
    };
  };

  codexHooksFile = jsonFormat.generate "codex-hooks.json" codexHooks;

  codexContextWindow = 272000;

  codexConfig = {
    command_attribution = "disable";
    model_auto_compact_token_limit = builtins.floor (codexContextWindow * 0.7);
    network_access = true;
    project_doc_fallback_filenames = [
      "README.md"
      "CONTRIBUTING.md"
    ];
    web_search = "live";

    analytics.enabled = false;
    feedback.enabled = false;

    features = {
      codex_hooks = true;
      multi_agent = true;
      skills = true;
    };

    mcp_servers = mcpServers;

    tui = {
      status_line = [
        "context-remaining"
        "model-with-reasoning"
        "codex-version"
      ];
      terminal_title = [ ];
    };
  };

  codexBaseConfigFile = tomlFormat.generate "codex-config-base.toml" codexConfig;

  codexConfigGenerator = pkgs.writeShellScript "generate-codex-config" ''
    set -euo pipefail

    ghq_root="$1"
    output="$2"

    mkdir -p "$(dirname "$output")"
    cp -f "${codexBaseConfigFile}" "$output"
    chmod 644 "$output"

    if [ -d "$ghq_root" ]; then
      # Match both .git directories (main repos) and .git files (worktrees, submodules).
      # max-depth 7 covers ~/ghq/<host>/<org>/<repo>/.worktrees/<branch>/.git (depth 6) with margin.
      # NOTE: Codex CLI's project_trust_key() normalizes via Rust PathBuf.to_string_lossy(),
      # which strips trailing slashes. The TOML key must match exactly (no trailing slash)
      # or else HashMap<String, ProjectConfig> lookup misses and the trust prompt re-appears.
      ${pkgs.fd}/bin/fd --hidden --no-ignore "^\.git$" "$ghq_root" --max-depth 7 2>/dev/null |
        sort |
        while read -r gitdir; do
          repo=$(dirname "$gitdir")
          case "$repo" in
            *'"'*|*'\'*)
              echo "WARNING: skipping repo path unsafe for TOML quoted keys: $repo" >&2
              continue
              ;;
          esac
          echo ""
          echo "[projects.\"$repo\"]"
          echo "trust_level = \"trusted\""
        done >> "$output"
    fi
  '';
in
{
  inherit
    instructionFiles
    mcpServerConfigs
    ;

  claude = {
    rulesDir = ./rules;
    agentsDir = families.claudeAgentsDir;
    scriptsDir = claudeScriptsDir;
    settingsFile = claudeSettingsFile;
  };

  codex = {
    rulesDir = codexRulesDir;
    agentsDir = families.codexAgentsDir;
    scriptsDir = codexScriptsDir;
    hooksFile = codexHooksFile;
    baseConfigFile = codexBaseConfigFile;
    configGenerator = codexConfigGenerator;
  };
}
