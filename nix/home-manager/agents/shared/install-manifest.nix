# Resolved install contract for agent outputs and shared skill targets.
# Edit subagents/_metadata.nix or subagents/<name>.md for content; this file
# maps native agent render outputs and shared skill destinations into the
# Claude/Codex install seam.
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
