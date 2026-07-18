# Resolved install contract for native agent files and shared skill targets.
# Edit subagents/*.md for reviewer prompt bodies and subagents/metadata.nix for
# per-runtime model/effort defaults. Claude and Codex agent files are generated
# from those shared sources.
{
  config,
  pkgs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  subagentPromptSource = ../subagents;
  subagentMetadata = import ../subagents/metadata.nix;
  subagentMetadataJson = pkgs.writeText "subagent-metadata.json" (builtins.toJSON subagentMetadata);
  agentRenderer = ../../../../scripts/nix/agent-render-native.py;
  renderedAgentsSource = pkgs.runCommand "native-agents-from-markdown" { } ''
    set -eu
    mkdir -p "$out/claude" "$out/codex"
    ${pkgs.python3}/bin/python3 ${agentRenderer} \
      ${subagentPromptSource} \
      ${subagentMetadataJson} \
      "$out/claude" \
      "$out/codex"
  '';
  claudeAgentsSource = "${renderedAgentsSource}/claude";
  codexAgentsSource = "${renderedAgentsSource}/codex";
in
{
  claude = {
    agents = {
      target = ".claude/agents";
      source = claudeAgentsSource;
    };

    skills = {
      dest = "${homeDir}/.claude/skills";
      structure = "symlink-tree";
    };
  };

  codex = {
    agents = {
      target = ".codex/agents";
      source = codexAgentsSource;
    };

    skills = {
      dest = "${homeDir}/.codex/skills";
      structure = "symlink-tree";
    };
  };
}
