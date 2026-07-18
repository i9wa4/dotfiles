# Agent skills declarative management via agent-skills-nix.
# Edit top-level skills/ for hand-authored, publishable skills. Native reviewer
# agent prompts live as Markdown under agents/subagents/; `subagent-review`
# itself is a normal local skill under skills/subagent-review/. This file
# consumes install-manifest.nix for the shared skill installation targets.
# Do not edit ~/.claude/skills or ~/.codex/skills directly.
# cf. https://github.com/Kyure-A/agent-skills-nix
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.i9wa4.agentSkills;
  sourceType = lib.types.submodule (_: {
    options = {
      input = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Flake input name providing this source.";
      };

      path = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Local path fallback instead of `input`.";
      };

      subdir = lib.mkOption {
        type = lib.types.str;
        default = ".";
        description = "Subdirectory under the input/path that contains skills.";
      };

      idPrefix = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional prefix to prepend to discovered skill IDs.";
      };

      filter = {
        maxDepth = lib.mkOption {
          type = lib.types.nullOr lib.types.ints.positive;
          default = null;
          description = "Maximum recursion depth when discovering SKILL.md directories.";
        };

        nameRegex = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Optional regex to restrict discovered skill paths.";
        };
      };
    };
  });

  installManifest = import ./install-manifest.nix {
    inherit
      config
      pkgs
      ;
  };
  matchAny = names: "^(${lib.concatStringsSep "|" names})$";
  googleCoreDataSkills = [
    "alloydb-basics"
    "bigquery-ai-ml"
    "bigquery-basics"
    "bigquery-bigframes"
    "bigtable-basics"
    "cloud-run-basics"
    "cloud-sql-basics"
    "datalineage-bigquery-asset-impact-analysis"
    "gcloud"
    "gke-basics"
    "gke-networking"
    "gke-observability"
    "gke-security"
    "gke-storage"
    "google-cloud-recipe-auth"
    "google-cloud-recipe-foundation-builder"
  ];
  azureCoreDataSkills = [
    "azure-ai"
    "azure-aigateway"
    "azure-compute"
    "azure-deploy"
    "azure-diagnostics"
    "azure-kusto"
    "azure-messaging"
    "azure-prepare"
    "azure-rbac"
    "azure-resource-lookup"
    "azure-storage"
    "azure-validate"
    "entra-agent-id"
    "entra-app-registration"
    "microsoft-foundry"
  ];
  validateSkillSource =
    name: src:
    pkgs.runCommand name { } ''
      cp -r ${src} $out
      chmod -R u+w $out
      ${pkgs.bash}/bin/bash ${../../../../scripts/validation/validate-skill-frontmatter.sh} "$out"
    '';
  local-skills-validated = validateSkillSource "local-skills-validated" ../../../../skills;

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
    ${pkgs.bash}/bin/bash ${../../../../scripts/validation/validate-skill-frontmatter.sh} "$out/skills"
  '';
  activeBaseSources = {
    # Local skills from this dotfiles repository, including the active
    # external-references router for dormant provider-pack inventory.
    local = {
      path = local-skills-validated;
    };
    # tmux-a2a-postman skills
    tmux-a2a-postman = {
      path = inputs.tmux-a2a-postman;
      subdir = "skills";
    };
    # Anthropic official agent skills (claude-api/SKILL.md frontmatter
    # normalized, then validated before installation)
    anthropic = {
      path = anthropic-skills-patched;
      subdir = "skills";
      filter.nameRegex = "claude-api";
    };
    # Upstash Context7 CLI skill. MCP servers remain disabled in
    # mcp-servers.nix; this skill uses the existing ctx7 CLI/global package
    # path.
    context7 = {
      path = inputs.context7;
      subdir = "skills";
      filter.nameRegex = "context7-cli";
    };
  };
  referenceOnlySources = {
    # dbt-labs official agent skills.
    dbt = {
      path = inputs.dbt-agent-skills;
      subdir = "skills/dbt/skills";
    };
    # Microsoft Azure skills. The filtered subset remains documented here for
    # future promotion decisions without loading it by default.
    azure = {
      path = inputs.azure-skills;
      subdir = "skills";
      filter.nameRegex = matchAny azureCoreDataSkills;
    };
    # Databricks official agent skills
    # cf. https://github.com/databricks/databricks-agent-skills
    databricks-official = {
      path = inputs.databricks-agent-skills;
      subdir = "skills";
    };
    # kepano/obsidian-skills: Obsidian-related skills (defuddle,
    # json-canvas, obsidian-bases, obsidian-cli, obsidian-markdown).
    # cf. https://github.com/kepano/obsidian-skills
    obsidian = {
      path = inputs.obsidian-skills;
      subdir = "skills";
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
    # Google skills, limited to core Cloud and data-platform workflows.
    # cf. https://github.com/google/skills
    google = {
      path = inputs.google-skills;
      subdir = "skills/cloud";
      filter.nameRegex = matchAny googleCoreDataSkills;
    };
    # AWS Agent Toolkit skills. Keep the full skills/ inventory reference-only
    # so nested upstream AWS skill categories are flattened for lookup without
    # making the AWS provider pack active.
    # Install skill bodies only; plugin and MCP integration remain out of scope.
    # cf. https://github.com/aws/agent-toolkit-for-aws
    aws = {
      path = inputs.aws-agent-toolkit;
      subdir = "skills";
    };
  };
  collisionNames = left: right: lib.attrNames (lib.intersectAttrs left right);
  sourceNameCollisions = lib.filter (collision: collision.names != [ ]) [
    {
      left = "activeBaseSources";
      right = "referenceOnlySources";
      names = collisionNames activeBaseSources referenceOnlySources;
    }
    {
      left = "activeBaseSources";
      right = "i9wa4.agentSkills.extraSources";
      names = collisionNames activeBaseSources cfg.extraSources;
    }
  ];
  formatCollision =
    collision: "${collision.left} and ${collision.right}: ${lib.concatStringsSep ", " collision.names}";
  activeSources = activeBaseSources // cfg.extraSources;
  codexMinimalSourceNames = [
    "local"
    "tmux-a2a-postman"
    "anthropic"
    "context7"
  ];
  codexMinimalSources = lib.getAttrs codexMinimalSourceNames activeSources;
  codexMinimalCatalog = inputs.agent-skills.lib.agent-skills.discoverCatalog codexMinimalSources;
  codexMinimalAllowlist = inputs.agent-skills.lib.agent-skills.allowlistFor {
    catalog = codexMinimalCatalog;
    sources = codexMinimalSources;
    enableAll = [
      "local"
      "tmux-a2a-postman"
    ];
    enable = [
      "claude-api"
      "context7-cli"
    ];
  };
  codexMinimalSelection = inputs.agent-skills.lib.agent-skills.selectSkills {
    catalog = codexMinimalCatalog;
    allowlist = codexMinimalAllowlist;
    skills = { };
    sources = codexMinimalSources;
  };
  codexMinimalBundle = inputs.agent-skills.lib.agent-skills.mkBundle {
    inherit pkgs;
    selection = codexMinimalSelection;
  };
  referenceOnlySourceNames = lib.attrNames referenceOnlySources;
  referenceOnlyCatalog = inputs.agent-skills.lib.agent-skills.discoverCatalog referenceOnlySources;
  referenceOnlyAllowlist = inputs.agent-skills.lib.agent-skills.allowlistFor {
    catalog = referenceOnlyCatalog;
    sources = referenceOnlySources;
    enableAll = referenceOnlySourceNames;
  };
  referenceOnlySelection = inputs.agent-skills.lib.agent-skills.selectSkills {
    catalog = referenceOnlyCatalog;
    allowlist = referenceOnlyAllowlist;
    skills = { };
    sources = referenceOnlySources;
  };
  referenceOnlyBundle = inputs.agent-skills.lib.agent-skills.mkBundle {
    inherit pkgs;
    selection = referenceOnlySelection;
    name = "agent-skills-reference-only-bundle";
  };
  referenceOnlyFlatNames = map builtins.baseNameOf (lib.attrNames referenceOnlySelection);
  referenceOnlyDuplicateFlatNames = lib.filter (
    name: (builtins.length (lib.filter (candidate: candidate == name) referenceOnlyFlatNames)) > 1
  ) (lib.unique referenceOnlyFlatNames);
  referenceOnlyFlatBundle =
    pkgs.runCommand "agent-skills-reference-only-flat-bundle" { preferLocalBuild = true; }
      ''
        mkdir -p "$out"
        printf '%s\n' 'managed-by: i9wa4.agent-skills.reference-only' \
          > "$out/${installManifest.reference.skills.ownershipMarker}"
        printf '%s\n' ${lib.concatMapStringsSep " " lib.escapeShellArg referenceOnlyFlatNames} \
          > "$out/${installManifest.reference.skills.ownershipMarker}.manifest"
        ${lib.concatMapStringsSep "\n" (
          id:
          let
            flatName = builtins.baseNameOf id;
          in
          ''
            ln -s ${lib.escapeShellArg "${referenceOnlyBundle}/${id}"} "$out/${flatName}"
          ''
        ) (lib.attrNames referenceOnlySelection)}
      '';
in
{
  imports = [
    inputs.agent-skills.homeManagerModules.default
  ];

  options.i9wa4.agentSkills.extraSources = lib.mkOption {
    type = lib.types.attrsOf sourceType;
    default = { };
    description = ''
      Additional agent-skills-nix sources injected by wrapper flakes.
      Public dotfiles keeps this empty; private wrappers may add private
      sources without adding private inputs to this public flake.
    '';
  };

  config = {
    assertions = [
      {
        assertion = sourceNameCollisions == [ ];
        message = "agent skill source names must be unique across merge inputs; collisions: ${lib.concatStringsSep "; " (map formatCollision sourceNameCollisions)}";
      }
      {
        assertion = referenceOnlyDuplicateFlatNames == [ ];
        message = "reference-only skill flat names must be unique; collisions: ${lib.concatStringsSep ", " referenceOnlyDuplicateFlatNames}";
      }
    ];

    programs.agent-skills = {
      enable = true;

      # Skill sources installed into active loader paths. Broad provider packs
      # stay in `referenceOnlySources` above so the flake pins remain
      # discoverable without expanding the default runtime skill surface.
      # A wrapper may promote a reference-only source with the same key through
      # `extraSources`; that promotion reaches Claude through this source set.
      # Codex intentionally uses the separate source and skill-selection
      # allowlists below, so promoted sources reach Codex only when both
      # `codexMinimalSourceNames` and `codexMinimalAllowlist` are changed too.
      sources = activeSources;

      # Enable all skills from the curated active source set.
      skills.enableAll = true;

      # Target destinations (symlink-tree uses activation rsync)
      targets = {
        # Claude Code: ~/.claude/skills
        claude-home = {
          inherit (installManifest.claude.skills)
            dest
            structure
            ;
        };
        # Codex CLI materializes the allowlisted bundle below instead of using
        # the full active source set. This keeps wrapper-injected provider packs
        # out of Codex's startup skill context unless explicitly allowed.
        codex = {
          enable = false;
          inherit (installManifest.codex.skills)
            dest
            structure
            ;
        };
      };

      # Preserve .system directory (created by agents at runtime)
      excludePatterns = [ "/.system" ];
    };

    home.activation.agent-skills-codex-minimal =
      lib.hm.dag.entryAfter [ "agent-skills" "writeBoundary" ]
        ''
          dest="${installManifest.codex.skills.dest}"
          if [ -L "$dest" ]; then
            rm -rf "$dest"
          fi
          mkdir -p "$dest"
          ${pkgs.rsync}/bin/rsync -a --delete --exclude '/.system' \
            "${codexMinimalBundle}/" "$dest/"
          chmod u+w "$dest"
          echo "agent-skills: installed minimal Codex skill bundle to $dest"
        '';

    home.activation.agent-skills-reference-only =
      lib.hm.dag.entryAfter [ "agent-skills" "writeBoundary" ]
        ''
          dest="${installManifest.reference.skills.dest}"
          ownershipMarker="${installManifest.reference.skills.ownershipMarker}"
          marker="$dest/$ownershipMarker"

          if [ -L "$dest" ]; then
            echo "agent-skills: refusing to replace symlinked reference skill tree at $dest" >&2
            exit 1
          fi
          if [ -e "$dest" ] && [ ! -d "$dest" ]; then
            echo "agent-skills: refusing to replace non-directory reference skill tree at $dest" >&2
            exit 1
          fi
          if [ -d "$dest" ] && [ ! -e "$marker" ]; then
            unmanaged=0
            for entry in "$dest"/* "$dest"/.[!.]* "$dest"/..?*; do
              if [ ! -e "$entry" ] && [ ! -L "$entry" ]; then
                continue
              fi
              target="$(${pkgs.coreutils}/bin/readlink "$entry" || true)"
              case "$target" in
                *-agent-skills-reference-only-bundle/*) ;;
                *)
                  echo "agent-skills: refusing to prune unmanaged reference skill entry: $entry" >&2
                  unmanaged=1
                  ;;
              esac
            done
            if [ "$unmanaged" -ne 0 ]; then
              echo "agent-skills: add $marker only after confirming $dest is owned by Home Manager" >&2
              exit 1
            fi
          fi
          mkdir -p "$dest"
          ${pkgs.rsync}/bin/rsync -a --delete \
            "${referenceOnlyFlatBundle}/" "$dest/"
          chmod u+w "$dest"
          echo "agent-skills: installed flat reference-only skill bundle to $dest"
        '';

  };
}
