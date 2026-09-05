# Resolved install contract for shared skill targets.
{
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  claude = {
    skills = {
      dest = "${homeDir}/.claude/skills";
      structure = "symlink-tree";
    };
  };

  codex = {
    skills = {
      dest = "${homeDir}/.codex/skills";
      structure = "symlink-tree";
    };
  };

  reference = {
    skills = {
      dest = "${homeDir}/.local/share/skills";
      structure = "owned-symlink-tree";
      ownershipMarker = ".i9wa4-agent-skills-reference-only";
    };
  };
}
