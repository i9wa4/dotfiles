# Agent skills declarative management via agent-skills-nix
# cf. https://github.com/Kyure-A/agent-skills-nix
{
  inputs,
  pkgs,
  username,
  ...
}: let
  homeDir =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
in {
  imports = [
    inputs.agent-skills.homeManagerModules.default
  ];

  programs.agent-skills = {
    enable = true;

    # Skill sources
    sources = {
      # Local skills from this dotfiles repository
      local = {
        path = inputs.self;
        subdir = "config/agents/skills";
      };
      # dbt-labs official agent skills
      dbt = {
        path = inputs.dbt-agent-skills;
        subdir = "skills";
      };
      # Anthropic official agent skills
      anthropic = {
        path = inputs.anthropic-skills;
        subdir = "skills";
      };
    };

    # Enable all skills from all sources
    skills.enableAll = true;

    # Target destinations (symlink-tree uses activation rsync)
    targets = {
      # Agents: ~/.agents/skills
      agents-home = {
        dest = "${homeDir}/.agents/skills";
        structure = "symlink-tree";
      };
      # Claude Code: ~/.claude/skills
      claude-home = {
        dest = "${homeDir}/.claude/skills";
        structure = "symlink-tree";
      };
      # Codex CLI: ~/.codex/skills
      codex = {
        dest = "${homeDir}/.codex/skills";
        structure = "symlink-tree";
      };
    };

    # Preserve .system directory (created by agents at runtime)
    excludePatterns = ["/.system"];
  };
}
