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

    # Enable specific skills (individual selection)
    skills.enable = [
      # Local skills (all)
      "local.atlassian"
      "local.bigquery"
      "local.claude-config-optimizer"
      "local.codex-config-optimizer"
      "local.daily-report"
      "local.databricks"
      "local.dbt"
      "local.draw-io"
      "local.git"
      "local.github"
      "local.jupyter-notebook"
      "local.nix"
      "local.orchestrator"
      "local.python"
      "local.restricted-bigquery-dbt-environment"
      "local.skill-creator"
      "local.slack"
      "local.subagent-review"
      "local.terraform"
      "local.tmux"
      # dbt-labs skills (all)
      "dbt.adding-dbt-unit-test"
      "dbt.answering-natural-language-questions-with-dbt"
      "dbt.building-dbt-semantic-layer"
      "dbt.configuring-dbt-mcp-server"
      "dbt.fetching-dbt-docs"
      "dbt.migrating-dbt-core-to-fusion"
      "dbt.running-dbt-commands"
      "dbt.troubleshooting-dbt-job-errors"
      "dbt.using-dbt-for-analytics-engineering"
      # Anthropic skills (selected)
      "anthropic.frontend-design"
      "anthropic.pptx"
      "anthropic.pdf"
      "anthropic.xlsx"
      "anthropic.doc-coauthoring"
      "anthropic.internal-comms"
    ];

    # Target destinations (symlink-tree uses activation rsync)
    targets = {
      # Claude Code: ~/.claude/skills
      claude-home = {
        dest = "${homeDir}/.claude/skills";
        structure = "symlink-tree";
      };
      claude-config = {
        dest = "${homeDir}/.config/claude/skills";
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
