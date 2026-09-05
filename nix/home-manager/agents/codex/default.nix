# Codex CLI configuration module
# Codex CLI binary is installed from llm-agents in nix/home-manager/default.nix.
# ~/.codex/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (auth.json, etc.) live directly in ~/.codex/
{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  ghqRoot = "${homeDir}/ghq";
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
  # Shared Bash deny surface includes aws sso login; see shared/bash-commands-denied.nix.
  deniedBash = import ../shared/bash-commands-denied.nix { inherit pkgs; };

  # Codex consumes runtime-agnostic shared scripts and generated Bash deny
  # patterns. The shared PreToolUse hook is the repo-owned command-deny
  # authority for Codex; filesystem and network boundaries remain Codex
  # sandbox/approval settings.
  # List each script explicitly; do not use wildcards, because this makes the
  # consumed hook surface reviewable in this file.
  codexScriptsDir = pkgs.runCommand "codex-scripts" { } ''
    mkdir -p $out
    ln -s ${../scripts}/pretooluse-deny-bash.sh $out/pretooluse-deny-bash.sh
    ln -s ${deniedBash.claudeCode.patternsFile} $out/deny-bash-patterns.sh
  '';

  tomlFormat = pkgs.formats.toml { };
  jsonFormat = pkgs.formats.json { };

  codexHooks = {
    hooks = {
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/pretooluse-deny-bash.sh";
              statusMessage = "Checking Bash policy";
            }
          ];
        }
      ];
    };
  };

  hooksFile = jsonFormat.generate "codex-hooks.json" codexHooks;

  # All gpt-5.x models share this context window size
  codexContextWindow = 272000;

  # Static config (everything except dynamic trusted projects).
  # Codex lightweight history and config controls are not the same as
  # interactive session rollout JSONL files under ~/.codex/sessions/**/*.jsonl.
  # The shared storage policy keeps lightweight history separate, retains about
  # 50 days of closed rollout JSONL by file age, excludes live open session
  # files, preserves the session data that ccusage codex reads directly, and
  # keeps ~/.codex/log/codex-tui.log outside that rollout-retention rule.
  codexConfig = {
    command_attribution = "disable";
    model_auto_compact_token_limit = builtins.floor (codexContextWindow * 0.7); # 70%
    # hide_agent_reasoning = true;
    # model = "gpt-5.3-codex";
    network_access = true;
    project_doc_fallback_filenames = [
      "README.md"
      "CONTRIBUTING.md"
    ];
    web_search = "live";

    analytics.enabled = false;
    feedback.enabled = false;

    features = {
      apps = true;
      fast_mode = false;
    };

    apps = {
      _default = {
        enabled = false;
        destructive_enabled = false;
        open_world_enabled = false;
      };

      slack = {
        enabled = true;
        default_tools_approval_mode = "prompt";
      };
      gmail = {
        enabled = true;
        default_tools_approval_mode = "prompt";
      };
      google_calendar = {
        enabled = true;
        default_tools_approval_mode = "prompt";
      };
      google_drive = {
        enabled = true;
        default_tools_approval_mode = "prompt";
      };
    };

    mcp_servers = mcpServers;

    tui = {
      status_line = [
        "context-remaining"
        "model-with-reasoning"
        "permissions"
        "approval-mode"
        "codex-version"
      ];
      # Keep tmux pane_title reserved for role identity, not Codex TUI chrome.
      terminal_title = [ ];
    };
  };

  # Base config file in Nix store (used as template by activation script)
  baseConfigFile = tomlFormat.generate "codex-config-base.toml" codexConfig;
  managedConfigStart = "# BEGIN DOTFILES NIX MANAGED CODEX CONFIG";
  managedConfigEnd = "# END DOTFILES NIX MANAGED CODEX CONFIG";

  generateConfigScript = pkgs.writeShellApplication {
    name = "codex-generate-config";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.fd
      pkgs.python3
    ];
    text = builtins.readFile ../scripts/codex-generate-config.sh;
  };
in
{
  home.file = {
    # Persona / language / scope is delivered through postman.md
    # common_template on each tmux-a2a-postman pop. Dotfiles-owned skills are
    # listed by the generated skill_path catalog; catch-all repository
    # background intentionally lives in docs rather than a `skills/repo-local`
    # catch-all skill.
    # AGENTS.md is the single authored source for the minimal local-invocation
    # fallback: installed here for `codex` directly, and reused byte-for-byte
    # as ~/.claude/CLAUDE.md in claude/default.nix (no second hand-written
    # file). See shared/AGENTS.md.
    ".codex/AGENTS.md".source = ../shared/AGENTS.md;
    # Shared Bash command-deny policy is installed through .codex/scripts and
    # .codex/hooks.json, not duplicated into embedded Codex rules.
    # Generated Codex agent files from the Markdown source (rebuild required to update)
    "${installManifest.codex.agents.target}".source = installManifest.codex.agents.source;
    # Hook scripts (Nix store, rebuild required to update)
    ".codex/scripts".source = codexScriptsDir;
    # Hooks config (Nix store, rebuild required to update)
    ".codex/hooks.json".source = hooksFile;
  };

  # Generate config.toml from Nix base config + dynamic trusted projects
  home.activation.generateCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CODEX_BASE_CONFIG="${baseConfigFile}" \
      CODEX_GENERATE_CONFIG_PY="${../scripts}/codex-generate-config.py" \
      CODEX_GHQ_ROOT="${ghqRoot}" \
      CODEX_MANAGED_START='${managedConfigStart}' \
      CODEX_MANAGED_END='${managedConfigEnd}' \
      CODEX_OUTPUT="${homeDir}/.codex/config.toml" \
      ${generateConfigScript}/bin/codex-generate-config
  '';

}
