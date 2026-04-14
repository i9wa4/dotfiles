# Agent skills declarative management via agent-skills-nix
# Edit skills/, review/skills/, or source wiring here.
# This file consumes install-manifest.nix for shared skill installation targets.
# Do not edit ~/.claude/skills or ~/.codex/skills directly.
# cf. https://github.com/Kyure-A/agent-skills-nix
{
  inputs,
  config,
  pkgs,
  ...
}:
let
  installManifest = import ./install-manifest.nix {
    inherit
      config
      pkgs
      ;
  };
  validateSkillSource =
    name: src:
    pkgs.runCommand name { } ''
      cp -r ${src} $out
      chmod -R u+w $out
      ${pkgs.bash}/bin/bash ${./scripts/validate-skill-frontmatter.sh} "$out"
    '';
  local-skills-validated = validateSkillSource "local-skills-validated" ./skills;

  # Normalize upstream anthropic/skills frontmatter for claude-api/SKILL.md.
  # Preserve upstream metadata keys while rewriting invalid YAML description
  # syntax, and keep a fallback for the no-frontmatter case.
  anthropic-skills-patched = pkgs.runCommand "anthropic-skills-patched" { } ''
    cp -r ${inputs.anthropic-skills} $out
    chmod -R u+w $out
    target=$out/skills/claude-api/SKILL.md
    tmp=$(${pkgs.coreutils}/bin/mktemp)
    if [ "$(${pkgs.coreutils}/bin/head -n 1 "$target")" != '---' ]; then
      {
        printf '%s\n' '---'
        printf '%s\n' 'name: claude-api'
        printf '%s\n' 'description: |'
        printf '%s\n' '  Build Claude API / Anthropic SDK apps. Use when code imports anthropic or'
        printf '%s\n' '  @anthropic-ai/sdk, when adding Claude API features, or when integrating'
        printf '%s\n' '  Anthropic-managed agents.'
        printf '%s\n' '---'
        echo
        cat "$target"
      } > "$tmp"
    else
      ${pkgs.gawk}/bin/awk '
        BEGIN {
          state = "start"
        }
        state == "start" {
          if ($0 == "---") {
            state = "frontmatter"
          }
          print
          next
        }
        state == "frontmatter" {
          if ($0 == "---") {
            state = "body"
            print
            next
          }
          if ($0 ~ /^description:[[:space:]]/ && $0 !~ /^description:[[:space:]]*[>|]/) {
            description = $0
            sub(/^description:[[:space:]]*/, "", description)
            print "description: |"
            print "  " description
            next
          }
          print
          next
        }
        {
          print
        }
      ' "$target" > "$tmp"
    fi
    mv "$tmp" "$target"
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
      # Anthropic official agent skills (claude-api/SKILL.md frontmatter
      # normalized, then validated before installation)
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
    // installManifest.skills.sources;

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
        inherit (installManifest.claude.skills)
          dest
          structure
          ;
      };
      # Codex CLI: ~/.codex/skills
      codex = {
        inherit (installManifest.codex.skills)
          dest
          structure
          ;
      };
    };

    # Preserve .system directory (created by agents at runtime)
    excludePatterns = [ "/.system" ];
  };
}
