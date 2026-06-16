# Flake apps (task runner, replaces Makefile nix-* targets)
# This module is imported by flake.nix via flake-parts
#
# Usage (quote .#name for zsh):
#   nix run '.#switch'       -- rebuild and activate configuration
#                               (Linux expires Home Manager generations older than 1 day;
#                                macOS expires system generations older than 1 day)
#   nix run '.#update'       -- update flake inputs, latest-tag flake refs, and Waza release pins
#   nix run '.#check'        -- check flake configuration
#   nix run '.#cleanup'      -- prune low-risk local caches
#   nix run '.#gc-roots-delete'
#                             -- attempt Linux auto GC-root cleanup through the dedicated command
#   nix run '.#storage-report' -- summarize Linux home-directory storage
#   nix run '.#root-lvm-extend' -- check/extend Ubuntu root LVM free space
#   nix run '.#apt-upgrade'  -- apt-get update && upgrade (Linux only)
#   nix run '.#docker-socket' -- --setup  -- configure Ubuntu Docker socket activation
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
      gcRootsReviewScript = ./../../../bin/ubuntu/list-stale-nix-gcroots.sh;
      storagePressureReportScript = ./../../../bin/ubuntu/storage-pressure-report.sh;
      rootLvmExtendScript = ./../../../bin/ubuntu/extend-root-lvm.sh;
      dockerEngineSocketScript = ./../../../bin/ubuntu/docker-engine-socket.sh;
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

                  if [ -x /opt/homebrew/bin/brew ]; then
                    brewfile=$(${pkgs.coreutils}/bin/mktemp)
                    trap 'rm -f "$brewfile"' EXIT

                    SUDO_USER="$(${pkgs.coreutils}/bin/id -un)" \
                      ${pkgs.nix}/bin/nix eval --impure --raw ".#darwinConfigurations.$profile.config.homebrew.brewfile" \
                      > "$brewfile"

                    PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
                      /opt/homebrew/bin/brew bundle install --file="$brewfile" --no-upgrade --cleanup --force-cleanup
                  fi

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
            ${
              if isLinux then
                ''
                  remove_dir "$cache_root/go-build"
                  remove_dir "$cache_root/nix"
                ''
              else
                ""
            }
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
        # What: Keep Linux stale GC-root cleanup on one explicit command separate from switch.
        # When: Run it directly to attempt guarded stale-root deletion as the current user.
        # Example: nix run '.#gc-roots-delete'
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

        # What: Configure rootful Docker on Ubuntu for socket-activated devcontainers.
        # Keeps daemon setup as an explicit sudo operation because standalone Home Manager
        # cannot own root systemd units, /var/run/docker.sock, or docker group state.
        # Example: nix run '.#docker-socket' -- --setup
        docker-socket = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "docker-socket" ''
            set -euo pipefail
            exec ${pkgs.bash}/bin/bash ${dockerEngineSocketScript} "$@"
          ''}/bin/docker-socket";
        };
      };
    };
}
