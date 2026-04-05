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

                        if [ "''${1:-}" = "--help" ] || [ "''${1:-}" = "-h" ]; then
                          cat <<'EOF'
            Usage: nix run '.#update' -- [--min-age-days DAYS]

            Updates all flake inputs from the repo root.

            Without flags, this runs a normal root-level update.
            With --min-age-days DAYS, the new flake.lock is kept only if every changed
            input has locked.lastModified at least DAYS old.
            EOF
                          exit 0
                        fi

                        min_age_days=""
                        while [ "$#" -gt 0 ]; do
                          case "$1" in
                            --min-age-days)
                              shift
                              min_age_days="''${1:-}"
                              case "$min_age_days" in
                                ""|*[!0-9]*)
                                  echo "--min-age-days requires a non-negative integer" >&2
                                  exit 2
                                  ;;
                              esac
                              ;;
                            *)
                              echo "Unknown argument: $1" >&2
                              exit 2
                              ;;
                          esac
                          shift
                        done

                        if [ -z "$min_age_days" ]; then
                          nix flake update --access-tokens github.com=$(${gh} auth token)
                          exit 0
                        fi

                        min_age_seconds=$((min_age_days * 24 * 60 * 60))
                        backup_lock=$(mktemp)
                        report_file=$(mktemp)

                        cleanup() {
                          rm -f "$backup_lock" "$report_file"
                        }
                        trap cleanup EXIT

                        cp flake.lock "$backup_lock"

                        if ! nix flake update --access-tokens github.com=$(${gh} auth token)
                        then
                          cp "$backup_lock" flake.lock
                          echo "Update command failed; restored flake.lock" >&2
                          exit 1
                        fi

                        set +e
                        ${python} - "$backup_lock" flake.lock "$min_age_seconds" "$min_age_days" > "$report_file" <<'PY'
            import datetime
            import json
            import sys
            import time

            before_path, after_path, min_age_seconds, min_age_days = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])

            with open(before_path, "r", encoding="utf-8") as fh:
                before = json.load(fh)
            with open(after_path, "r", encoding="utf-8") as fh:
                after = json.load(fh)

            before_nodes = before["nodes"]
            after_nodes = after["nodes"]
            now = int(time.time())
            changed = []

            for name, new_node in after_nodes.items():
                old_node = before_nodes.get(name, {})
                new_locked = new_node.get("locked") or {}
                old_locked = old_node.get("locked") or {}
                if new_locked == old_locked:
                    continue
                if not new_locked:
                    continue
                last_modified = new_locked.get("lastModified")
                age_seconds = None if last_modified is None else max(0, now - int(last_modified))
                changed.append(
                    {
                        "name": name,
                        "owner": new_locked.get("owner"),
                        "repo": new_locked.get("repo"),
                        "type": new_locked.get("type"),
                        "rev": new_locked.get("rev") or new_locked.get("narHash") or new_locked.get("ref") or "unknown",
                        "last_modified": last_modified,
                        "age_seconds": age_seconds,
                    }
                )

            if not changed:
                print("No input version changes detected.")
                sys.exit(0)

            print(f"Changed inputs after update ({len(changed)}):")
            blocked = []
            for item in changed:
                target = item["name"]
                if item["owner"] and item["repo"]:
                    target = f"{target} ({item['owner']}/{item['repo']})"
                if item["last_modified"] is None:
                    print(f"UNKNOWN: {target} -> {item['rev']} (missing locked.lastModified)")
                    blocked.append(item)
                    continue
                age_days = item["age_seconds"] / 86400
                last_modified = datetime.datetime.fromtimestamp(item["last_modified"], tz=datetime.timezone.utc).strftime("%Y-%m-%d")
                status = "OK"
                if item["age_seconds"] < min_age_seconds:
                    status = "TOO_FRESH"
                    blocked.append(item)
                print(f"{status}: {target} -> {item['rev']} (age {age_days:.1f}d, lastModified {last_modified} UTC)")

            if blocked:
                print("")
                print(f"Blocked because one or more updated inputs are newer than {min_age_days} days.")
                sys.exit(1)

            print("")
            print(f"All changed inputs satisfy the minimum age window ({min_age_days} days).")
            PY
                        status=$?
                        set -e

                        cat "$report_file"

                        if [ "$status" -ne 0 ]; then
                          cp "$backup_lock" flake.lock
                          echo "Restored flake.lock because one or more updated inputs were newer than $min_age_days days." >&2
                          exit "$status"
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
