# Flake apps (task runner, replaces Makefile nix-* targets)
# This module is imported by flake.nix via flake-parts
#
# Usage (quote .#name for zsh):
#   nix run '.#switch'       -- rebuild and activate configuration
#                               (Linux expires Home Manager generations older than 1 day;
#                                macOS expires system generations older than 1 day)
#   nix run '.#update'       -- update flake inputs, latest-tag flake refs, and Waza release pins
#   nix run '.#check'        -- check flake configuration
#   nix run '.#cleanup' -- --dry-run
#                             -- preview low-risk local cache cleanup
#   nix run '.#cleanup'      -- prune low-risk local caches
#   nix run '.#gc-roots-delete' -- --apply
#                             -- attempt Linux auto GC-root cleanup through the dedicated command
#   nix run '.#storage-report' -- summarize Linux home-directory storage
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
      cleanupScript = ./../../../bin/cleanup-safe-caches.sh;
      gcRootsReviewScript = ./../../../bin/ubuntu/list-stale-nix-gcroots.sh;
      storagePressureReportScript = ./../../../bin/ubuntu/storage-pressure-report.sh;
      rootLvmExtendScript = ./../../../bin/ubuntu/extend-root-lvm.sh;
      tmuxA2aPostmanUpdateScript = ./../../packages/tmux-a2a-postman-nix-update.sh;
      wazaUpdateScript = ./../../packages/waza-nix-update.sh;
      actrunUpdateScript = ./../../packages/actrun-nix-update.sh;
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

        # What: Prune only the explicit safe_cache surface for user-owned caches.
        # When: Run for low-risk reclaim without touching review_first or preserve buckets.
        # Preview: nix run '.#cleanup' -- --dry-run
        cleanup = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "cleanup" ''
            set -euo pipefail
            export CLEANUP_UV=${lib.getExe pkgs.uv}
            exec ${pkgs.bash}/bin/bash ${cleanupScript} "$@"
          ''}/bin/cleanup";
        };
      }
      // lib.optionalAttrs isLinux {
        # What: Keep Linux stale GC-root cleanup on one explicit command separate from switch.
        # When: Run it directly to attempt guarded stale-root deletion as the current user.
        # Example: nix run '.#gc-roots-delete' -- --apply
        gc-roots-delete = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "gc-roots-delete" ''
            set -euo pipefail
            exec ${pkgs.bash}/bin/bash ${gcRootsReviewScript} "$@"
          ''}/bin/gc-roots-delete";
        };

        # What: Summarize Linux home-directory storage pressure for the current user or all users.
        # Uses the shared safe_cache / review_first / preserve vocabulary from docs/storage-hygiene.md.
        # When: Run before cleanup so you know which homes and paths are using the most space.
        # Example: nix run '.#storage-report' -- --self --summary
        storage-report = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "storage-report" ''
            set -euo pipefail
            exec ${pkgs.bash}/bin/bash ${storagePressureReportScript} "$@"
          ''}/bin/storage-report";
        };

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
