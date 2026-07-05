# Flake apps (task runner, replaces Makefile nix-* targets)
# This module is imported by flake.nix via flake-parts
#
# Usage (quote .#name for zsh):
#   nix run '.#switch'       -- rebuild and activate configuration
#                               (Linux expires Home Manager generations older than 1 day;
#                                macOS expires system generations older than 1 day)
#   nix run '.#update'       -- update flake inputs, latest-tag flake refs, and Waza release pins
#   nix run '.#check'        -- check flake configuration
#   nix run '.#root-lvm-extend' -- check/extend Ubuntu root LVM free space
#   nix run '.#apt-upgrade'  -- apt-get update && upgrade (Linux only)
{ lib, ... }:
{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      isDarwin = lib.hasSuffix "darwin" system;
      isLinux = lib.hasSuffix "linux" system;
      gh = lib.getExe pkgs.gh;
      jq = lib.getExe pkgs.jq;
      nix = lib.getExe pkgs.nix;
      rootLvmExtendScript = ./../../../scripts/ubuntu/extend-root-lvm.sh;
      tmuxA2aPostmanUpdateScript = ./../../../scripts/nix/flake-input-update-tmux-a2a-postman.sh;
      wazaUpdateScript = ./../../../scripts/nix/package-update-waza.sh;
      actrunUpdateScript = ./../../../scripts/nix/package-update-actrun.sh;
    in
    {
      apps = {
        # What: Rebuild and activate the current machine configuration, then expire old generations without post-switch store GC.
        # When: Run after changing dotfiles, Home Manager modules, or nix-darwin modules.
        # Example: nix run '.#switch'
        switch = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "switch" ''
            set -euo pipefail

            ${
              if isDarwin then
                ''
                  profile=$(echo -e "macos-p\nmacos-w" | ${lib.getExe pkgs.fzf} --prompt="Select profile: ")

                  sudo -H darwin-rebuild switch --impure --flake ".#$profile"
                  sudo -H ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations 1d
                ''
              else
                ''
                  access_token=$(${lib.getExe pkgs.gh} auth token)
                  nix run --access-tokens "github.com=$access_token" \
                    home-manager -- switch -b backup --flake '.#ubuntu' --impure
                  nix run --access-tokens "github.com=$access_token" \
                    home-manager -- expire-generations '-1 days'
                ''
            }
          ''}/bin/switch";
        };

        update = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "update" ''
            set -euo pipefail
            access_token=$(${gh} auth token)
            TMUX_A2A_POSTMAN_GH=${gh} TMUX_A2A_POSTMAN_SORT=${pkgs.coreutils}/bin/sort \
              ${pkgs.bash}/bin/bash ${tmuxA2aPostmanUpdateScript}
            ${nix} flake update --access-tokens "github.com=$access_token"
            WAZA_GH=${gh} WAZA_NIX=${nix} \
              ${pkgs.bash}/bin/bash ${wazaUpdateScript}
            ACTRUN_GH=${gh} ACTRUN_NIX=${nix} ACTRUN_JQ=${jq} \
              ${pkgs.bash}/bin/bash ${actrunUpdateScript}
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
        # What: Check or extend Ubuntu root LVM free space after an installer leaves / small.
        # When: Run --check after Ubuntu setup; run --apply only after reviewing the target VG/LV.
        # Example: nix run '.#root-lvm-extend' -- --check
        root-lvm-extend = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "root-lvm-extend" ''
            set -euo pipefail
            exec ${pkgs.bash}/bin/bash ${rootLvmExtendScript} "$@"
          ''}/bin/root-lvm-extend";
        };

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
