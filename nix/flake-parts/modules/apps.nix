# Flake apps (task runner, replaces Makefile nix-* targets)
# This module is imported by flake.nix via flake-parts
#
# Usage (quote .#name for zsh):
#   nix run '.#switch'       -- rebuild and activate configuration
#   nix run '.#update'       -- update flake inputs
#   nix run '.#update' -- --min-age-days 7
#                             -- update flake inputs with a minimum-age gate
#   nix run '.#check'        -- check flake configuration
#   nix run '.#cleanup'      -- prune low-risk local caches
#   nix run '.#apt-upgrade'  -- apt-get update && upgrade (Linux only)
{ lib, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      isDarwin = lib.hasSuffix "darwin" system;
      isLinux = lib.hasSuffix "linux" system;
      gh = lib.getExe pkgs.gh;
      nix = lib.getExe pkgs.nix;
      python = lib.getExe pkgs.python3;
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
            export GH_BIN=${gh}
            export NIX_BIN=${nix}
            exec ${python} ${./update-flake.py} "$@"
          ''}/bin/update";
        };

        check = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "check" ''
            set -euo pipefail
            nix flake check --all-systems
          ''}/bin/check";
        };

        cleanup = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "cleanup" ''
            set -euo pipefail

            remove_dir() {
              target="$1"
              if [ -d "$target" ]; then
                echo "Removing $target"
                rm -rf "$target"
              else
                echo "Skipping missing $target"
              fi
            }

            cache_root="''${XDG_CACHE_HOME:-$HOME/.cache}"
            uv_cache_dir="$(${lib.getExe pkgs.uv} cache dir)"

            if command -v pgrep >/dev/null 2>&1 && pgrep -x uv >/dev/null 2>&1; then
              echo "Skipping uv cache prune in $uv_cache_dir (active uv process detected)"
            else
              echo "Pruning uv cache in $uv_cache_dir"
              ${lib.getExe pkgs.uv} cache prune
            fi

            remove_dir "$cache_root/pre-commit"
            remove_dir "$cache_root/ruff"
            remove_dir "$HOME/.npm"

            if [ -d "$HOME/Library/Caches" ]; then
              remove_dir "$HOME/Library/Caches/pre-commit"
              remove_dir "$HOME/Library/Caches/ruff"
            fi

            echo "Cleanup complete."
          ''}/bin/cleanup";
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
