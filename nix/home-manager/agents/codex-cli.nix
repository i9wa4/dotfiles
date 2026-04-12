# Codex CLI configuration module
# Codex CLI binary is managed externally (e.g. npm install -g @openai/codex)
# ~/.codex/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (auth.json, etc.) live directly in ~/.codex/
{
  pkgs,
  lib,
  config,
  inputs,
  nodejsPackage,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  ghqRoot = "${homeDir}/ghq";
  families = import ./families/default.nix { inherit pkgs; };

  mcpServers = import ./mcp-servers.nix {
    inherit
      homeDir
      pkgs
      inputs
      ;
  };
  # Shared Bash deny surface includes aws sso login; see denied-bash-commands.nix.
  deniedBash = import ./denied-bash-commands.nix { inherit pkgs; };
  instructionArtifacts = import ./instruction-artifacts.nix { inherit pkgs; };
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

  codexScriptsDir = pkgs.runCommand "codex-scripts" { } ''
    mkdir -p $out
    for f in ${./scripts}/codex-*; do
      ln -s "$f" "$out/$(basename "$f")"
    done
    ln -s ${./scripts}/common-userpromptsubmit.sh $out/common-userpromptsubmit.sh
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
              command = "$HOME/.codex/scripts/common-userpromptsubmit.sh codex";
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

    tui = {
      status_line = [
        "context-remaining"
        "model-with-reasoning"
        "codex-version"
      ];
      # Keep tmux pane_title reserved for role identity, not Codex TUI chrome.
      terminal_title = [ ];
    };
  };

  # Base config file in Nix store (used as template by activation script)
  baseConfigFile = tomlFormat.generate "codex-config-base.toml" codexConfig;
  managedConfigStart = "# BEGIN DOTFILES NIX MANAGED CODEX CONFIG";
  managedConfigEnd = "# END DOTFILES NIX MANAGED CODEX CONFIG";
in
{
  home.file = {
    # Generated AGENTS.md (shared core + inlined rules)
    ".codex/AGENTS.md".source = instructionFiles.codexAgentsMd;
    # Exec policy rules (.rules files only; .md is not auto-loaded by Codex CLI)
    # NOTE: default.rules remains separate for exec-policy denials
    ".codex/rules".source = codexRulesDir;
    # Subagent definitions (family-managed .toml/markdown generation)
    ".codex/agents".source = families.codexAgentsDir;
    # Hook scripts (Nix store, rebuild required to update)
    ".codex/scripts".source = codexScriptsDir;
    # Hooks config (Nix store, rebuild required to update)
    ".codex/hooks.json".source = hooksFile;
  };

  # Generate config.toml from a bounded Nix-managed block without auto-trusting repos
  home.activation.generateCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        echo "Generating Codex CLI config..."
        _output="${homeDir}/.codex/config.toml"
        _managed_start='${managedConfigStart}'
        _managed_end='${managedConfigEnd}'
        mkdir -p "$(dirname "$_output")"

        # Preserve marker-less user config verbatim outside the managed block.
        # Refresh only the bounded Nix-managed block on subsequent activations.
        # Keep existing managed project tables, but drop managed trust grants.
        CODEX_BASE_CONFIG="${baseConfigFile}" \
          CODEX_GHQ_ROOT="${ghqRoot}" \
          CODEX_MANAGED_START="$_managed_start" \
          CODEX_MANAGED_END="$_managed_end" \
          CODEX_OUTPUT="$_output" \
          ${pkgs.python3}/bin/python <<'PY'
    import os
    import re
    from pathlib import Path


    TABLE_HEADER_RE = re.compile(r"^\[[^\]]+\]\s*(?:#.*)?$")
    PROJECT_HEADER_RE = re.compile(r'^\[projects\."(?P<repo_path>[^"]+)"\]\s*(?:#.*)?$')
    TRUST_LEVEL_RE = re.compile(r'^\s*trust_level\s*=')
    TRUSTED_LEVEL_RE = re.compile(r'^\s*trust_level\s*=\s*"trusted"\s*(?:#.*)?$')


    output_path = Path(os.environ["CODEX_OUTPUT"])
    base_config_path = Path(os.environ["CODEX_BASE_CONFIG"])
    ghq_root = os.environ["CODEX_GHQ_ROOT"].rstrip("/")
    managed_start = os.environ["CODEX_MANAGED_START"]
    managed_end = os.environ["CODEX_MANAGED_END"]
    base_config = base_config_path.read_text()
    existing_text = output_path.read_text() if output_path.exists() else ""
    has_existing_config = bool(existing_text.strip())


    def strip_managed_block(text):
        lines = text.splitlines(keepends=True)
        start_index = None
        end_index = None

        for index, line in enumerate(lines):
            stripped = line.rstrip("\n")
            if start_index is None and stripped == managed_start:
                start_index = index
                continue
            if start_index is not None and stripped == managed_end:
                end_index = index
                break

        if start_index is None or end_index is None:
            return text, False, ""

        managed_text = "".join(lines[start_index + 1 : end_index])
        kept = lines[:start_index] + lines[end_index + 1 :]
        return "".join(kept), True, managed_text


    def collect_project_tables(text):
        lines = text.splitlines(keepends=True)
        tables = {}
        index = 0

        while index < len(lines):
            match = PROJECT_HEADER_RE.match(lines[index].strip())
            if match is None:
                index += 1
                continue
            repo_path = match.group("repo_path")
            index += 1
            body_lines = []
            while index < len(lines):
                stripped = lines[index].strip()
                if stripped == managed_start or stripped == managed_end:
                    break
                if TABLE_HEADER_RE.match(stripped):
                    break
                body_lines.append(lines[index])
                index += 1
            tables.setdefault(repo_path, []).append(body_lines)

        return tables


    def render_project_table(repo_path, body_groups):
        body_lines = []
        for group in body_groups:
            for line in group:
                if TRUST_LEVEL_RE.match(line):
                    continue
                body_lines.append(line)

        while body_lines and not body_lines[-1].strip():
            body_lines.pop()

        if not body_lines:
            return None

        rendered = [f'[projects."{repo_path}"]\n']
        rendered.extend(body_lines)
        rendered_text = "".join(rendered)
        if not rendered_text.endswith("\n"):
            rendered_text += "\n"

        return rendered_text


    preserved_text, had_managed_block, managed_text = strip_managed_block(existing_text)
    project_tables = collect_project_tables(managed_text)


    def is_legacy_managed_repo(repo_path):
        return repo_path == ghq_root or repo_path.startswith(f"{ghq_root}/")


    def scrub_legacy_markerless_project_tables(text):
        lines = text.splitlines(keepends=True)
        kept = []
        index = 0

        while index < len(lines):
            match = PROJECT_HEADER_RE.match(lines[index].strip())
            if match is None:
                kept.append(lines[index])
                index += 1
                continue

            repo_path = match.group("repo_path")
            header_line = lines[index]
            index += 1
            body_lines = []

            while index < len(lines):
                stripped = lines[index].strip()
                if stripped == managed_start or stripped == managed_end:
                    break
                if TABLE_HEADER_RE.match(stripped):
                    break
                body_lines.append(lines[index])
                index += 1

            if not is_legacy_managed_repo(repo_path):
                kept.append(header_line)
                kept.extend(body_lines)
                continue

            filtered_body = [
                line for line in body_lines if not TRUSTED_LEVEL_RE.match(line)
            ]
            while filtered_body and not filtered_body[-1].strip():
                filtered_body.pop()

            if not filtered_body:
                continue

            kept.append(header_line)
            kept.extend(filtered_body)
            if not "".join(filtered_body).endswith("\n"):
                kept.append("\n")

        return "".join(kept)

    output_sections = []
    if has_existing_config and not had_managed_block:
        preserved_text = scrub_legacy_markerless_project_tables(preserved_text)
    preserved_text = preserved_text.rstrip("\n")
    if preserved_text:
        output_sections.append(preserved_text)

    if not has_existing_config or had_managed_block:
        managed_sections = [base_config.rstrip("\n")]
        for repo_path, body_groups in project_tables.items():
            rendered = render_project_table(repo_path, body_groups)
            if rendered is None:
                continue
            managed_sections.append(rendered.rstrip("\n"))

        output_sections.append(
            "\n".join(
                [
                    managed_start,
                    "\n\n".join(managed_sections),
                    managed_end,
                ]
            )
        )

    output_text = "\n\n".join(output_sections)
    if output_text:
        output_text += "\n"

    output_path.write_text(output_text)
    PY

        chmod 644 "$_output"
        echo "Generated: $_output"
  '';
}
