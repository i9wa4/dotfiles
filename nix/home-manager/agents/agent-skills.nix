# Agent skills declarative management via agent-skills-nix
# cf. https://github.com/Kyure-A/agent-skills-nix
{
  inputs,
  config,
  pkgs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  families = import ./families/default.nix { inherit pkgs; };

  # Patch upstream anthropic/skills: prepend YAML frontmatter to
  # skills/claude-api/SKILL.md. Upstream ships this file without frontmatter,
  # which Codex CLI rejects at startup ("missing YAML frontmatter delimited
  # by ---"). Claude Code tolerates the missing header, but we patch once so
  # both runtimes load the skill cleanly.
  anthropic-skills-patched = pkgs.runCommand "anthropic-skills-patched" { } ''
    cp -r ${inputs.anthropic-skills} $out
    chmod -R u+w $out
    {
      printf '%s\n' '---'
      printf '%s\n' 'name: claude-api'
      printf '%s\n' 'description: Build Claude API / Anthropic SDK apps. Use when code imports `anthropic`/`@anthropic-ai/sdk`, when adding Claude features (prompt caching, streaming, tools), or when integrating the Anthropic SDK in any supported language.'
      printf '%s\n' '---'
      echo
      cat ${inputs.anthropic-skills}/skills/claude-api/SKILL.md
    } > $out/skills/claude-api/SKILL.md
  '';
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
        subdir = "nix/home-manager/agents/skills";
      };
      # tmux-a2a-postman skills
      tmux-a2a-postman = {
        path = inputs.tmux-a2a-postman;
        subdir = "skills";
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
      # Anthropic official agent skills (claude-api/SKILL.md patched in-place
      # to add missing YAML frontmatter required by Codex CLI)
      anthropic = {
        path = anthropic-skills-patched;
        subdir = "skills";
      };
      # Streamlit official agent skills
      streamlit = {
        path = inputs.streamlit-skills;
        subdir = "developing-with-streamlit/skills";
      };
      # Databricks official agent skills (ai-dev-kit)
      # cf. https://github.com/databricks-solutions/ai-dev-kit/tree/main/databricks-skills
      databricks = {
        path = inputs.databricks-agent-skills;
        subdir = "databricks-skills";
      };
      # cf. https://github.com/databricks-solutions/ai-dev-kit/tree/main/.claude/skills
      databricks-claude = {
        path = inputs.databricks-agent-skills;
        subdir = ".claude/skills";
        filter.nameRegex = "python-dev"; # exclude databricks-python-sdk (duplicate)
      };
      # Databricks official agent skills (databricks org)
      # cf. https://github.com/databricks/databricks-agent-skills
      databricks-official = {
        path = inputs.databricks-official-skills;
        subdir = "skills";
        filter.nameRegex = "databricks(-apps|-pipelines)?"; # exclude databricks-jobs (duplicate)
      };
      # draw.io skill (jgraph/drawio-mcp)
      # cf. https://github.com/jgraph/drawio-mcp
      drawio-mcp = {
        path = inputs.drawio-mcp;
        subdir = "skill-cli";
      };
      # HashiCorp agent skills (split by plugin)
      # cf. https://github.com/hashicorp/agent-skills
      hashicorp-terraform-codegen = {
        path = inputs.hashicorp-agent-skills;
        subdir = "terraform/code-generation/skills";
      };
      hashicorp-terraform-module = {
        path = inputs.hashicorp-agent-skills;
        subdir = "terraform/module-generation/skills";
      };
      hashicorp-terraform-provider = {
        path = inputs.hashicorp-agent-skills;
        subdir = "terraform/provider-development/skills";
      };
    }
    // families.skillSources;

    # Enable all skills from all sources
    skills = {
      enableAll = true;
      # Explicit skill definitions (for rename or custom config)
      explicit.databricks-jobs-bundles = {
        from = "databricks-official";
        path = "databricks-jobs";
        rename = "databricks-jobs-bundles"; # avoid duplicate with ai-dev-kit
      };
    };

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
