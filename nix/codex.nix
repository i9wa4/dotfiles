# Codex CLI configuration module
# Generates config.toml from config.common.toml + trusted projects
{
  pkgs,
  lib,
  username,
  ...
}: let
  homeDir =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  ghqRoot = "${homeDir}/ghq";
  codexConfigDir = "${ghqRoot}/github.com/i9wa4/dotfiles/config/codex";
in {
  home.activation.generateCodexConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "Generating Codex CLI config..."
    _common="${codexConfigDir}/config.common.toml"
    _output="${codexConfigDir}/config.toml"

    if [ -f "$_common" ]; then
      cp -f "$_common" "$_output"

      ${pkgs.fd}/bin/fd --type d --hidden --no-ignore "^\.git$" "${ghqRoot}" --max-depth 4 2>/dev/null |
        sed 's|/\.git$||' |
        sort |
        while read -r repo; do
          [ -z "$repo" ] && continue
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
