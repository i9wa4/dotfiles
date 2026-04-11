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
  validateSkillSource =
    name: src:
    pkgs.runCommand name { } ''
      cp -r ${src} $out
      chmod -R u+w $out
      ${pkgs.bash}/bin/bash ${./scripts/validate-skill-frontmatter.sh} "$out"
    '';
  local-skills-validated = validateSkillSource "local-skills-validated" ./skills;

  # Patch upstream anthropic/skills only when claude-api/SKILL.md is missing
  # frontmatter. Upstream has changed before, so keep this transform idempotent
  # and validate the assembled tree before exposing it to agent-skills.
  anthropic-skills-patched = pkgs.runCommand "anthropic-skills-patched" { } ''
    cp -r ${inputs.anthropic-skills} $out
    chmod -R u+w $out
    target=$out/skills/claude-api/SKILL.md
    if [ "$(${pkgs.coreutils}/bin/head -n 1 "$target")" != '---' ]; then
      tmp=$(${pkgs.coreutils}/bin/mktemp)
      {
        printf '%s\n' '---'
        printf '%s\n' 'name: claude-api'
        printf '%s\n' 'description: Build Claude API / Anthropic SDK apps. Use when code imports `anthropic`/`@anthropic-ai/sdk`, when adding Claude features (prompt caching, streaming, tools), or when integrating the Anthropic SDK in any supported language.'
        printf '%s\n' '---'
        echo
        cat "$target"
      } > "$tmp"
      mv "$tmp" "$target"
    fi
    ${pkgs.bash}/bin/bash ${./scripts/validate-skill-frontmatter.sh} "$out/skills"
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
        path = local-skills-validated;
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
      # Anthropic official agent skills (claude-api/SKILL.md normalized only
      # when frontmatter is missing, then validated before installation)
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
