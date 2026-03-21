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
  deniedBash = import ./denied-bash-commands.nix { inherit pkgs; };

  defaultRulesContent = ''
    # Exec policy rules for Codex CLI
    # Generated from nix/home-manager/agents/denied-bash-commands.nix
    # File access restrictions (Read/Write patterns) have no Codex equivalent.

    ${deniedBash.codexCli.rulesContent}
  '';

  generatedDefaultRules = pkgs.writeText "default.rules" defaultRulesContent;

  # Exec policy rules only (.rules files); .md instructions go via AGENTS.md
  codexRulesDir = pkgs.runCommand "codex-rules" { } ''
    mkdir -p $out
    cp ${generatedDefaultRules} $out/default.rules
  '';

  # Convert Claude Code subagent .md files (YAML frontmatter + Markdown body)
  # into Codex CLI .toml agent files (name, description, developer_instructions).
  # The model field is dropped so agents inherit from the parent session.
  codexAgentsDir = pkgs.runCommand "codex-agents" { } ''
    mkdir -p $out
    for md in ${./subagents}/*.md; do
      basename="$(basename "$md" .md)"
      agent_name="$(${pkgs.gnused}/bin/sed -n 's/^name: //p' "$md")"
      description="$(${pkgs.gnused}/bin/sed -n 's/^description: //p' "$md")"
      body="$(${pkgs.gawk}/bin/awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$md")"
      printf 'name = "%s"\ndescription = "%s"\ndeveloper_instructions = """\n%s\n"""\n' \
        "$agent_name" "$description" "$body" > "$out/$basename.toml"
    done
  '';

  codexScriptsDir = pkgs.runCommand "codex-scripts" { } ''
    mkdir -p $out
    for f in ${./scripts}/codex-*; do
      ln -s "$f" "$out/$(basename "$f")"
    done
  '';

  tomlFormat = pkgs.formats.toml { };
  jsonFormat = pkgs.formats.json { };

  codexHooks = {
    hooks = {
      UserPromptSubmit = [
        {
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/codex-userpromptsubmit.sh";
            }
          ];
        }
      ];
    };
  };

  hooksFile = jsonFormat.generate "codex-hooks.json" codexHooks;

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
      codex_hooks = true;
      multi_agent = true;
      skills = true;
    };

    mcp_servers = mcpServers;

    tui.status_line = [
      "context-remaining"
      "model-with-reasoning"
      "codex-version"
    ];
  };

  # Base config file in Nix store (used as template by activation script)
  baseConfigFile = tomlFormat.generate "codex-config-base.toml" codexConfig;
in
{
  home.file = {
    # AGENTS.md (Nix store, rebuild required to update)
    ".codex/AGENTS.md".source = ./AGENTS.md;
    # Exec policy rules (.rules files only; .md is not auto-loaded by Codex CLI)
    # NOTE: Codex CLI may also read agents/rules/*.md via AGENTS.md references
    ".codex/rules".source = codexRulesDir;
    # Subagent definitions (auto-generated .toml from subagents/*.md)
    ".codex/agents".source = codexAgentsDir;
    # Hook scripts (Nix store, rebuild required to update)
    ".codex/scripts".source = codexScriptsDir;
    # Hooks config (Nix store, rebuild required to update)
    ".codex/hooks.json".source = hooksFile;
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
