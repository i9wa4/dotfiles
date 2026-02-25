# Codex CLI configuration module
# ~/.codex/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (auth.json, etc.) live directly in ~/.codex/
{
  pkgs,
  lib,
  config,
  ...
}: let
  homeDir = config.home.homeDirectory;
  ghqRoot = "${homeDir}/ghq";
  dotfilesDir = "${ghqRoot}/github.com/i9wa4/dotfiles";
  symlink = config.lib.file.mkOutOfStoreSymlink;
in {
  home.file = {
    ".codex/AGENTS.md".source = symlink "${dotfilesDir}/config/agents/AGENTS.md";
    ".codex/rules".source = symlink "${dotfilesDir}/config/agents/rules";
  };

  # Generate config.toml from config.common.toml + trusted projects
  home.activation.generateCodexConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "Generating Codex CLI config..."
    _common="${dotfilesDir}/config/codex/config.common.toml"
    _output="${homeDir}/.codex/config.toml"

    if [ -f "$_common" ]; then
      cp -f "$_common" "$_output"

      ${pkgs.fd}/bin/fd --type d --hidden --no-ignore "^\.git$" "${ghqRoot}" --max-depth 4 2>/dev/null |
        sort |
        while read -r gitdir; do
          repo=$(dirname "$gitdir")
          echo ""
          echo "[projects.\"$repo/\"]"
          echo "trust_level = \"trusted\""
        done >> "$_output"

      echo "Generated: $_output"
    else
      echo "Warning: $_common not found"
    fi
  '';
}
