# Agent skills declarative management via agent-skills-nix
# cf. https://github.com/Kyure-A/agent-skills-nix
{
  inputs,
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
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
        subdir = "agents/skills";
      };
      # dbt-labs official agent skills (split by skill group)
      dbt = {
        path = inputs.dbt-agent-skills;
        subdir = "skills/dbt/skills";
      };
      dbt-migration = {
        path = inputs.dbt-agent-skills;
        subdir = "skills/dbt-migration/skills";
      };
      # Anthropic official agent skills
      anthropic = {
        path = inputs.anthropic-skills;
        subdir = "skills";
      };
      # Streamlit official agent skills
      streamlit = {
        path = inputs.streamlit-skills;
        subdir = "developing-with-streamlit/skills";
      };
      # Databricks official agent skills
      # cf. https://github.com/databricks-solutions/ai-dev-kit/tree/main/databricks-skills
      databricks = {
        path = inputs.databricks-agent-skills;
        subdir = "databricks-skills";
      };
      # cf. https://github.com/databricks-solutions/ai-dev-kit/tree/main/.claude/skills
      databricks-claude = {
        path = inputs.databricks-agent-skills;
        subdir = ".claude/skills";
      };
    };

    # Enable all skills from all sources
    skills.enableAll = true;

    # Target destinations (symlink-tree uses activation rsync)
    targets = {
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
    excludePatterns = [ "/.system" ];
  };
}
