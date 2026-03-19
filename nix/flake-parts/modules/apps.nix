# Flake apps (task runner, replaces Makefile nix-* targets)
# This module is imported by flake.nix via flake-parts
#
# Usage (quote .#name for zsh):
#   nix run '.#switch'       -- rebuild and activate configuration
#   nix run '.#update'       -- update flake inputs
#   nix run '.#check'        -- check flake configuration
#   nix run '.#apt-upgrade'  -- apt-get update && upgrade (Linux only)
{ lib, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      isDarwin = lib.hasSuffix "darwin" system;
      isLinux = lib.hasSuffix "linux" system;
    in
    {
      apps = {
        switch = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "switch" ''
            set -euo pipefail
            ${
              if isDarwin then
                ''
                  profile=$(echo -e "macos-p\nmacos-w" | ${lib.getExe pkgs.fzf} --prompt="Select profile: ")
                  sudo darwin-rebuild switch --impure --flake ".#$profile"
                ''
              else
                ''
                  nix run --access-tokens github.com=$(${lib.getExe pkgs.gh} auth token) \
                    home-manager -- switch -b backup --flake '.#ubuntu' --impure
                ''
            }
          ''}/bin/switch";
        };

        update = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "update" ''
            set -euo pipefail
            nix flake update --access-tokens github.com=$(${lib.getExe pkgs.gh} auth token)

            # Update actrun (pre-built binary, not in nixpkgs)
            precommit=nix/flake-parts/modules/pre-commit.nix
            current=$(${lib.getExe pkgs.gnugrep} -oP 'version = "\K[^"]+' "$precommit" | head -1)
            latest=$(${lib.getExe pkgs.gh} api repos/mizchi/actrun/releases/latest --jq '.tag_name' | sed 's/^v//')
            if [ "$current" != "$latest" ]; then
              echo "actrun: $current -> $latest"
              ${lib.getExe pkgs.gnused} -i "s/version = \"$current\"/version = \"$latest\"/" "$precommit"
              for asset in actrun-linux-x64.tar.gz actrun-macos-arm64.tar.gz; do
                url="https://github.com/mizchi/actrun/releases/download/v$latest/$asset"
                hash=$(${lib.getExe pkgs.nurl} -f fetchurl --json "$url" 2>/dev/null \
                  | ${lib.getExe pkgs.jq} -r '.args.hash')
                old_hash=$(${lib.getExe pkgs.gnugrep} -A2 "$asset" "$precommit" \
                  | ${lib.getExe pkgs.gnugrep} -oP 'hash = "\K[^"]+')
                ${lib.getExe pkgs.gnused} -i "s|$old_hash|$hash|" "$precommit"
              done
              echo "actrun: updated to $latest"
            else
              echo "actrun: already at $latest"
            fi
          ''}/bin/update";
        };

        check = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "check" ''
            set -euo pipefail
            nix flake check --all-systems
          ''}/bin/check";
        };
      }
      // lib.optionalAttrs isLinux {
        apt-upgrade = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "apt-upgrade" ''
            set -euo pipefail
            sudo apt-get update && sudo apt-get upgrade -y
          ''}/bin/apt-upgrade";
        };
      };
    };
}
