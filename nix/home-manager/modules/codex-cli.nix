# Codex CLI configuration module
# Codex CLI binary is managed externally (e.g. npm install -g @openai/codex)
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

  mcpServers = import ./mcp-servers.nix { inherit pkgs inputs; };

  prohibitedBash = import ./prohibited-bash-commands.nix;

  mkPrefixRule =
    cmd:
    let
      patternItems = builtins.concatStringsSep ", " (map (s: "\"${s}\"") cmd.argv);
    in
    ''
      prefix_rule(
          pattern = [${patternItems}],
          decision = "forbidden",
          justification = "${cmd.justification}",
      )
    '';

  defaultRulesContent = ''
    # Exec policy rules for Codex CLI
    # Generated from nix/home-manager/modules/prohibited-bash-commands.nix
    # Equivalent of Claude Code permissions.deny (Bash entries only)
    # File access restrictions (Read/Write patterns) have no Codex equivalent.

    ${builtins.concatStringsSep "\n" (map mkPrefixRule prohibitedBash)}
  '';

  generatedDefaultRules = pkgs.writeText "default.rules" defaultRulesContent;

  # Combined rules directory: agents/rules/*.md + generated default.rules
  codexRulesDir = pkgs.runCommand "codex-rules" { } ''
    mkdir -p $out
    cp ${../../../agents/rules}/* $out/
    cp ${generatedDefaultRules} $out/default.rules
  '';

  tomlFormat = pkgs.formats.toml { };

  # All gpt-5.x models share this context window size
  codexContextWindow = 272000;

  # Static config (everything except dynamic trusted projects)
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
      multi_agent = true;
      skills = true;
    };

    mcp_servers = mcpServers;
  };

  # Base config file in Nix store (used as template by activation script)
  baseConfigFile = tomlFormat.generate "codex-config-base.toml" codexConfig;
in
{
  home.file = {
    # AGENTS.md (Nix store, rebuild required to update)
    ".codex/AGENTS.md".source = ../../../agents/AGENTS.md;
    # Rules directory: agents/rules/*.md + generated default.rules
    ".codex/rules".source = codexRulesDir;
  };

  # Generate config.toml from Nix base config + dynamic trusted projects
  home.activation.generateCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Generating Codex CLI config..."
    _output="${homeDir}/.codex/config.toml"

    cp -f "${baseConfigFile}" "$_output"
    chmod 644 "$_output"

    ${pkgs.fd}/bin/fd --type d --hidden --no-ignore "^\.git$" "${ghqRoot}" --max-depth 4 2>/dev/null |
      sort |
      while read -r gitdir; do
        repo=$(dirname "$gitdir")
        echo ""
        echo "[projects.\"$repo/\"]"
        echo "trust_level = \"trusted\""
      done >> "$_output"

    echo "Generated: $_output"
  '';
}
