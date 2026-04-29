# Resolved install contract for agent outputs and shared skill targets.
# Edit subagents/_metadata.nix or subagents/<name>.md for content; this file
# only maps render-agents.nix outputs into the shared Claude/Codex install seam.
{
  config,
  pkgs,
}:
let
  homeDir = config.home.homeDirectory;
  agents = import ./render-agents.nix { inherit pkgs; };
in
{
  claude = {
    agents = {
      target = ".claude/agents";
      source = agents.claudeAgentsDir;
    };

    skills = {
      dest = "${homeDir}/.claude/skills";
      structure = "symlink-tree";
    };
  };

  codex = {
    agents = {
      target = ".codex/agents";
      source = agents.codexAgentsDir;
    };

    skills = {
      dest = "${homeDir}/.codex/skills";
      structure = "symlink-tree";
    };
  };

  skills = {
    sources = agents.skillSources;
  };
}
