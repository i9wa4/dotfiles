# Codex CLI configuration module
# Codex CLI binary is managed externally (e.g. npm install -g @openai/codex)
# ~/.codex/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (auth.json, etc.) live directly in ~/.codex/
{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  ghqRoot = "${homeDir}/ghq";

  mcpServers = import ./mcp-servers.nix { inherit pkgs inputs; };
  deniedBash = import ./denied-bash-commands.nix { inherit pkgs; };
  instructionArtifacts = import ./instruction-artifacts.nix { inherit pkgs; };
  reviewGen = import ./review/review-artifacts-gen.nix { inherit pkgs; };
  instructionFiles = instructionArtifacts {
    sharedCore = ./AGENTS.md;
    claudeOnly = ./CLAUDE.md;
    rulePaths = [
      ./rules/bash.md
      ./rules/github.md
      ./rules/markdown.md
      ./rules/python.md
    ];
  };

  defaultRulesContent = ''
    # Exec policy rules for Codex CLI
    # Generated from nix/home-manager/agents/denied-bash-commands.nix
    # File access restrictions (Read/Write patterns) have no Codex equivalent.

    ${deniedBash.codexCli.rulesContent}
  '';

  generatedDefaultRules = pkgs.writeText "default.rules" defaultRulesContent;

  # Exec policy rules only (.rules files); .md instructions go via AGENTS.md
  codexRulesDir = pkgs.runCommand "codex-rules" { } ''
    mkdir -p $out
    cp ${generatedDefaultRules} $out/default.rules
  '';

  # Convert Claude Code subagent .md files (YAML frontmatter + Markdown body)
  # into Codex CLI .toml agent files (name, description, developer_instructions).
  # The model field is dropped so agents inherit from the parent session.
  # reviewer-* files are skipped here; cx variants from reviewGen are used instead.
  codexAgentsDir = pkgs.runCommand "codex-agents" { } ''
    mkdir -p $out
    # Non-reviewer subagents from ./subagents (researcher-tech, super-codex-reviewer)
    for md in ${./subagents}/*.md; do
      case "$(basename "$md")" in
        reviewer-*) continue ;;  # NOTE: skip reviewers; cx variants used instead
      esac
      basename_="$(basename "$md" .md)"
      agent_name="$(${pkgs.gnused}/bin/sed -n 's/^name: //p' "$md")"
      description="$(${pkgs.gnused}/bin/sed -n 's/^description: //p' "$md")"
      ${pkgs.gawk}/bin/awk \
        'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' \
        "$md" > "$out/_body_tmp"
      printf 'name = "%s"\ndescription = "%s"\ndeveloper_instructions = """\n' \
        "$agent_name" "$description" > "$out/$basename_.toml"
      cat "$out/_body_tmp" >> "$out/$basename_.toml"
      printf '"""\n' >> "$out/$basename_.toml"
      rm "$out/_body_tmp"
    done
    # CX reviewer variants (6 files: reviewer-{role}.md -> reviewer-{role}.toml)
    for md in ${reviewGen.agentFiles.cxDir}/*.md; do
      basename_="$(basename "$md" .md)"
      agent_name="$(${pkgs.gnused}/bin/sed -n 's/^name: //p' "$md")"
      description="$(${pkgs.gnused}/bin/sed -n 's/^description: //p' "$md")"
      ${pkgs.gawk}/bin/awk \
        'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' \
        "$md" > "$out/_body_tmp"
      printf 'name = "%s"\ndescription = "%s"\ndeveloper_instructions = """\n' \
        "$agent_name" "$description" > "$out/$basename_.toml"
      cat "$out/_body_tmp" >> "$out/$basename_.toml"
      printf '"""\n' >> "$out/$basename_.toml"
      rm "$out/_body_tmp"
    done
    # CX Tier 1 deep variants (6 files: reviewer-{role}-deep.md -> reviewer-{role}-deep.toml)
    # NOTE: model field dropped -- Tier 1 model specified at codex exec call time
    for md in ${reviewGen.agentFiles.cxDeepDir}/*.md; do
      basename_="$(basename "$md" .md)"
      agent_name="$(${pkgs.gnused}/bin/sed -n 's/^name: //p' "$md")"
      description="$(${pkgs.gnused}/bin/sed -n 's/^description: //p' "$md")"
      ${pkgs.gawk}/bin/awk \
        'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' \
        "$md" > "$out/_body_tmp"
      printf 'name = "%s"\ndescription = "%s"\ndeveloper_instructions = """\n' \
        "$agent_name" "$description" > "$out/$basename_.toml"
      cat "$out/_body_tmp" >> "$out/$basename_.toml"
      printf '"""\n' >> "$out/$basename_.toml"
      rm "$out/_body_tmp"
    done
  '';

  codexScriptsDir = pkgs.runCommand "codex-scripts" { } ''
    mkdir -p $out
    for f in ${./scripts}/codex-*; do
      ln -s "$f" "$out/$(basename "$f")"
    done
    ln -s ${deniedBash.claudeCode.patternsFile} $out/deny-bash-patterns.sh
  '';

  tomlFormat = pkgs.formats.toml { };
  jsonFormat = pkgs.formats.json { };

  codexHooks = {
    hooks = {
      SessionStart = [
        {
          matcher = "startup|resume";
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/codex-sessionstart-reload.sh";
              statusMessage = "Loading Codex handoff";
            }
          ];
        }
      ];
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/codex-pretooluse-deny-bash.sh";
              statusMessage = "Checking Bash policy";
            }
          ];
        }
      ];
      PostToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/codex-posttooluse-review.sh";
              statusMessage = "Reviewing Bash feedback";
            }
          ];
        }
      ];
      UserPromptSubmit = [
        {
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/codex-userpromptsubmit.sh";
            }
          ];
        }
      ];
      Stop = [
        {
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/codex-stop-save.sh";
              statusMessage = "Saving Codex handoff";
              timeout = 10;
            }
          ];
        }
      ];
    };
  };

  hooksFile = jsonFormat.generate "codex-hooks.json" codexHooks;

  # All gpt-5.x models share this context window size
  codexContextWindow = 272000;

  # Static config (everything except dynamic trusted projects)
  codexConfig = {
    command_attribution = "disable";
    model_auto_compact_token_limit = builtins.floor (codexContextWindow * 0.7); # 70%
    # hide_agent_reasoning = true;
    # model = "gpt-5.3-codex";
    network_access = true;
    project_doc_fallback_filenames = [
      "README.md"
      "CONTRIBUTING.md"
    ];
    web_search = "live";

    analytics.enabled = false;
    feedback.enabled = false;

    features = {
      codex_hooks = true;
      multi_agent = true;
      skills = true;
    };

    mcp_servers = mcpServers;

    tui.status_line = [
      "context-remaining"
      "model-with-reasoning"
      "codex-version"
    ];
  };

  # Base config file in Nix store (used as template by activation script)
  baseConfigFile = tomlFormat.generate "codex-config-base.toml" codexConfig;
in
{
  home.file = {
    # Generated AGENTS.md (shared core + inlined rules)
    ".codex/AGENTS.md".source = instructionFiles.codexAgentsMd;
    # Exec policy rules (.rules files only; .md is not auto-loaded by Codex CLI)
    # NOTE: default.rules remains separate for exec-policy denials
    ".codex/rules".source = codexRulesDir;
    # Subagent definitions (auto-generated .toml from subagents/*.md)
    ".codex/agents".source = codexAgentsDir;
    # Hook scripts (Nix store, rebuild required to update)
    ".codex/scripts".source = codexScriptsDir;
    # Hooks config (Nix store, rebuild required to update)
    ".codex/hooks.json".source = hooksFile;
  };

  # Generate config.toml from Nix base config + dynamic trusted projects
  home.activation.generateCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Generating Codex CLI config..."
    _output="${homeDir}/.codex/config.toml"

    cp -f "${baseConfigFile}" "$_output"
    chmod 644 "$_output"

    ${pkgs.fd}/bin/fd --type d --hidden --no-ignore "^\.git$" "${ghqRoot}" --max-depth 4 2>/dev/null |
      sort |
      while read -r gitdir; do
        repo=$(dirname "$gitdir")
        case "$repo" in
          *'"'*|*'\'*)
            echo "WARNING: skipping repo path unsafe for TOML quoted keys: $repo" >&2
            continue
            ;;
        esac
        echo ""
        echo "[projects.\"$repo/\"]"
        echo "trust_level = \"trusted\""
      done >> "$_output"

    echo "Generated: $_output"
  '';
}
