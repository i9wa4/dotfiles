# Codex CLI configuration module
# Codex CLI binary is managed externally (e.g. npm install -g @openai/codex)
# ~/.codex/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (auth.json, etc.) live directly in ~/.codex/
{
  pkgs,
  lib,
  config,
  inputs,
  nodejsPackage,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  ghqRoot = "${homeDir}/ghq";
  runtimeArtifacts = import ./runtime-artifacts.nix {
    inherit
      pkgs
      lib
      inputs
      homeDir
      nodejsPackage
      ;
  };
in
{
  home.file = {
    # Generated AGENTS.md (shared core + inlined rules)
    ".codex/AGENTS.md".source = runtimeArtifacts.instructionFiles.codexAgentsMd;
    # Exec policy rules (.rules files only; .md is not auto-loaded by Codex CLI)
    # NOTE: default.rules remains separate for exec-policy denials
    ".codex/rules".source = runtimeArtifacts.codex.rulesDir;
    # Subagent definitions (family-managed .toml/markdown generation)
    ".codex/agents".source = runtimeArtifacts.codex.agentsDir;
    # Hook scripts (Nix store, rebuild required to update)
    ".codex/scripts".source = runtimeArtifacts.codex.scriptsDir;
    # Hooks config (Nix store, rebuild required to update)
    ".codex/hooks.json".source = runtimeArtifacts.codex.hooksFile;
  };

  # Generate config.toml from Nix base config + dynamic trusted projects
  home.activation.generateCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Generating Codex CLI config..."
    _output="${homeDir}/.codex/config.toml"

    ${runtimeArtifacts.codex.configGenerator} "${ghqRoot}" "$_output"

    echo "Generated: $_output"
  '';
}
