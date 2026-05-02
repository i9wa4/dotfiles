# Flake apps (task runner, replaces Makefile nix-* targets)
# This module is imported by flake.nix via flake-parts
#
# Usage (quote .#name for zsh):
#   nix run '.#switch'       -- rebuild and activate configuration
#                               (Linux expires Home Manager generations older than 1 day;
#                                macOS expires system generations older than 1 day)
#   nix run '.#update'       -- update flake inputs
#   nix run '.#profile-update' -- install or upgrade entries listed in `profilePackages`
#   nix run '.#check'        -- check flake configuration
#   nix run '.#cleanup'      -- prune low-risk local caches
#   nix run '.#gc-roots-delete'
#                             -- attempt Linux auto GC-root cleanup through the dedicated command
#   nix run '.#storage-report' -- summarize Linux home-directory storage
#   nix run '.#apt-upgrade'  -- apt-get update && upgrade (Linux only)
{ lib, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      isDarwin = lib.hasSuffix "darwin" system;
      isLinux = lib.hasSuffix "linux" system;
      gh = lib.getExe pkgs.gh;
      jq = lib.getExe pkgs.jq;
      nix = lib.getExe pkgs.nix;
      gcRootsReviewScript = ./../../../bin/ubuntu/list-stale-nix-gcroots.sh;
      storagePressureReportScript = ./../../../bin/ubuntu/storage-pressure-report.sh;
      profilePackages = {
        tmux-a2a-postman = "github:i9wa4/tmux-a2a-postman";
        claude-code = ".#claude-code";
        codex = ".#codex";
        ccusage = ".#ccusage";
        ccusage-codex = ".#ccusage-codex";
      };
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
            ${nix} flake update --access-tokens "github.com=$access_token"
            exec ${pkgs.zsh}/bin/zsh -ic 'zinit self-update && zinit update --all'
          ''}/bin/update";
        };

        # What: Reconcile the user's nix profile with `profilePackages`.
        #       Adds entries that are missing and upgrades entries that already exist.
        # When: Run any time, independent of `nix run '.#switch'`.
        # Example: nix run '.#profile-update'
        profile-update = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "profile-update" ''
            set -euo pipefail

            declare -A packages=( ${
              lib.concatStringsSep " " (lib.mapAttrsToList (n: u: "[${n}]='${u}'") profilePackages)
            } )

            for name in "''${!packages[@]}"; do
              url="''${packages[$name]}"
              if { ${nix} profile list --json | ${jq} -e --arg n "$name" '.elements | has($n)'; } >/dev/null; then
                echo "Upgrading $name"
                ${nix} profile upgrade "$name"
              else
                echo "Installing $name ($url)"
                ${nix} profile add "$url"
              fi
            done

            echo "profile-update: done"
          ''}/bin/profile-update";
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
