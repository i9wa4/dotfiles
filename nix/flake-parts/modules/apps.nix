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
