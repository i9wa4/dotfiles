# Resolved install contract for committed native agent files and shared skill
# targets. Edit subagents/claude/*.md or subagents/codex/*.toml for native
# reviewer agent source; this file maps those directories into the
# Claude/Codex install surface.
{
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  claude = {
    agents = {
      target = ".claude/agents";
      source = ../subagents/claude;
    };

    skills = {
      dest = "${homeDir}/.claude/skills";
      structure = "symlink-tree";
    };
  };

  codex = {
    agents = {
      target = ".codex/agents";
      source = ../subagents/codex;
    };

    skills = {
      dest = "${homeDir}/.codex/skills";
      structure = "symlink-tree";
    };
  };

  skills = {
    sources = { };
  };
}
