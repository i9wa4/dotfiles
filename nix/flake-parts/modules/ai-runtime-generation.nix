# Disposable Claude/Codex runtime verification for GitHub Actions and local CI
{ inputs, lib, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      runtimeArtifacts = import ../../home-manager/agents/runtime-artifacts.nix {
        inherit
          pkgs
          lib
          inputs
          ;
        homeDir = "/home/ci";
        nodejsPackage = pkgs.nodejs_24;
      };

      aiRuntimeGeneration = pkgs.runCommand "ai-runtime-generation" { } ''
        set -euo pipefail

        RUNTIME_ROOT="$out"
        EMPTY_GHQ_ROOT="$TMPDIR/ghq"

        mkdir -p "$RUNTIME_ROOT/.claude" "$RUNTIME_ROOT/.codex" "$EMPTY_GHQ_ROOT"

        install -Dm644 ${runtimeArtifacts.instructionFiles.claudeMd} "$RUNTIME_ROOT/.claude/CLAUDE.md"
        ln -s ${runtimeArtifacts.claude.rulesDir} "$RUNTIME_ROOT/.claude/rules"
        ln -s ${runtimeArtifacts.claude.agentsDir} "$RUNTIME_ROOT/.claude/agents"
        ln -s ${runtimeArtifacts.claude.scriptsDir} "$RUNTIME_ROOT/.claude/scripts"
        install -Dm644 ${runtimeArtifacts.claude.settingsFile} "$RUNTIME_ROOT/.claude/settings.json"

        install -Dm644 ${runtimeArtifacts.instructionFiles.codexAgentsMd} "$RUNTIME_ROOT/.codex/AGENTS.md"
        ln -s ${runtimeArtifacts.codex.rulesDir} "$RUNTIME_ROOT/.codex/rules"
        ln -s ${runtimeArtifacts.codex.agentsDir} "$RUNTIME_ROOT/.codex/agents"
        ln -s ${runtimeArtifacts.codex.scriptsDir} "$RUNTIME_ROOT/.codex/scripts"
        install -Dm644 ${runtimeArtifacts.codex.hooksFile} "$RUNTIME_ROOT/.codex/hooks.json"
        ${runtimeArtifacts.codex.configGenerator} "$EMPTY_GHQ_ROOT" "$RUNTIME_ROOT/.codex/config.toml"

        test -f "$RUNTIME_ROOT/.claude/CLAUDE.md"
        test -d "$RUNTIME_ROOT/.claude/rules"
        test -d "$RUNTIME_ROOT/.claude/agents"
        test -d "$RUNTIME_ROOT/.claude/scripts"
        test -f "$RUNTIME_ROOT/.claude/settings.json"

        test -f "$RUNTIME_ROOT/.codex/AGENTS.md"
        test -f "$RUNTIME_ROOT/.codex/rules/default.rules"
        test -d "$RUNTIME_ROOT/.codex/agents"
        test -d "$RUNTIME_ROOT/.codex/scripts"
        test -f "$RUNTIME_ROOT/.codex/hooks.json"
        test -f "$RUNTIME_ROOT/.codex/config.toml"

        cmp -s "$RUNTIME_ROOT/.claude/CLAUDE.md" ${runtimeArtifacts.instructionFiles.claudeMd}
        cmp -s "$RUNTIME_ROOT/.codex/AGENTS.md" ${runtimeArtifacts.instructionFiles.codexAgentsMd}
        cmp -s "$RUNTIME_ROOT/.codex/config.toml" ${runtimeArtifacts.codex.baseConfigFile}

        ${pkgs.jq}/bin/jq -e '.language == "English" and .includeGitInstructions == false' \
          "$RUNTIME_ROOT/.claude/settings.json" >/dev/null
        ${pkgs.jq}/bin/jq -e '.hooks.SessionStart | length > 0' \
          "$RUNTIME_ROOT/.codex/hooks.json" >/dev/null

        printf 'verified runtime root: %s\n' "$RUNTIME_ROOT"
        printf '%s\n' \
          "$RUNTIME_ROOT/.claude/CLAUDE.md" \
          "$RUNTIME_ROOT/.claude/rules" \
          "$RUNTIME_ROOT/.claude/agents" \
          "$RUNTIME_ROOT/.claude/scripts" \
          "$RUNTIME_ROOT/.claude/settings.json" \
          "$RUNTIME_ROOT/.codex/AGENTS.md" \
          "$RUNTIME_ROOT/.codex/rules/default.rules" \
          "$RUNTIME_ROOT/.codex/agents" \
          "$RUNTIME_ROOT/.codex/scripts" \
          "$RUNTIME_ROOT/.codex/hooks.json" \
          "$RUNTIME_ROOT/.codex/config.toml"
      '';
    in
    lib.optionalAttrs (lib.hasSuffix "linux" system) {
      checks.ai-runtime-generation = aiRuntimeGeneration;
    };
}
