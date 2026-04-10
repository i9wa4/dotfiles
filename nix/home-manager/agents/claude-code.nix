# Claude Code configuration module
# Claude Code binary is managed externally (e.g. npm install -g @anthropic-ai/claude-code)
# ~/.claude/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (projects/, todos/, etc.) live directly in ~/.claude/
{
  config,
  pkgs,
  inputs,
  lib,
  nodejsPackage,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  runtimeArtifacts = import ./runtime-artifacts.nix {
    inherit
      pkgs
      lib
      inputs
      homeDir
      nodejsPackage
      ;
  };
in
{
  home = {
    file = {
      # Composite CLAUDE.md generated from AGENTS.md + Claude-only fragment
      ".claude/CLAUDE.md".source = runtimeArtifacts.instructionFiles.claudeMd;
      # Nix store directory symlinks (rebuild required to update)
      ".claude/rules".source = runtimeArtifacts.claude.rulesDir;
      ".claude/agents".source = runtimeArtifacts.claude.agentsDir;
      ".claude/scripts".source = runtimeArtifacts.claude.scriptsDir;
    };

    activation = {
      # Copy settings.json as a writable file (not symlink).
      # Claude Code's /config editor writes user preferences back to settings.json;
      # a Nix store symlink would be read-only.
      claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        install -Dm644 ${runtimeArtifacts.claude.settingsFile} "$HOME/.claude/settings.json"
      '';

      # Register MCP servers by writing directly to ~/.claude/.claude.json.
      # Replaces .mcpServers with the Nix-managed set (SSOT); stale entries are removed.
      claudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        TARGET="$HOME/.claude/.claude.json"
        SERVERS=${lib.escapeShellArg (builtins.toJSON runtimeArtifacts.mcpServerConfigs)}
        [ -f "$TARGET" ] || { mkdir -p "$(dirname "$TARGET")"; printf '{}' > "$TARGET"; }
        ${pkgs.jq}/bin/jq --argjson servers "$SERVERS" '.mcpServers = $servers' "$TARGET" > "$TARGET.tmp" \
          && mv "$TARGET.tmp" "$TARGET"
      '';

      claudeObservationPermissions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        STATE_ROOT="''${XDG_STATE_HOME:-$HOME/.local/state}/claude"
        if [ -d "$STATE_ROOT" ]; then
          find "$STATE_ROOT" \
            \( -name 'observations*.jsonl' -o -name 'project.json' -o -name 'projects.json' \) \
            -type f -exec chmod 600 {} \;
          find "$STATE_ROOT" -type d -exec chmod 700 {} \;
        fi
      '';
    };
  };
}
