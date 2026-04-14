# Resolved install contract for agent family outputs and shared skill targets
{
  config,
  pkgs,
}:
let
  homeDir = config.home.homeDirectory;
  families = import ./families/default.nix { inherit pkgs; };
in
{
  claude = {
    agents = {
      target = ".claude/agents";
      source = families.claudeAgentsDir;
    };

    skills = {
      dest = "${homeDir}/.claude/skills";
      structure = "symlink-tree";
    };
  };

  codex = {
    agents = {
      target = ".codex/agents";
      source = families.codexAgentsDir;
    };

    skills = {
      dest = "${homeDir}/.codex/skills";
      structure = "symlink-tree";
    };
  };

  skills = {
    sources = families.skillSources;
  };
}
