# Flake apps (task runner, replaces Makefile nix-* targets)
# This module is imported by flake.nix via flake-parts
#
# Usage (quote .#name for zsh):
#   nix run '.#switch'       -- rebuild and activate configuration
#                               (Linux expires Home Manager generations older than 1 day;
#                                macOS expires system generations older than 1 day)
#   nix run '.#update'       -- update flake inputs, latest-tag flake refs, and Waza release pins
#   nix run '.#check'        -- check flake configuration
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
      nix = lib.getExe pkgs.nix;
      tmuxA2aPostmanUpdateScript = ./../../../scripts/nix/flake-input-update-tmux-a2a-postman.sh;
      wazaUpdateScript = ./../../../scripts/nix/package-update-waza.sh;
      tailscaledLabel = "com.tailscale.tailscaled";

      # Neither standalone home-manager (Ubuntu) nor a plain nix-darwin
      # environment.systemPackages entry (macOS) can declare a root-level
      # service on their own, so both service definitions are generated here
      # and (re)installed on every `switch` -- one shared pattern instead of
      # leaning on nix-darwin's services.tailscale module for macOS only.
      tailscaledUnit = pkgs.writeText "tailscaled.service" ''
        [Unit]
        Description=Tailscale node agent
        Documentation=https://tailscale.com/kb/
        Wants=network-pre.target
        After=network-pre.target NetworkManager.service systemd-resolved.service
        StartLimitIntervalSec=0

        [Service]
        ExecStart=${pkgs.tailscale}/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock
        ExecStopPost=${pkgs.tailscale}/bin/tailscaled --cleanup
        Restart=on-failure
        RuntimeDirectory=tailscale
        RuntimeDirectoryMode=0755
        StateDirectory=tailscale
        StateDirectoryMode=0700
        CacheDirectory=tailscale
        CacheDirectoryMode=0750
        Type=notify

        [Install]
        WantedBy=multi-user.target
      '';

      # macOS equivalent of tailscaledUnit above, as a LaunchDaemon plist.
      # cf. nix-darwin's modules/services/tailscale.nix (launchd.daemons.tailscaled),
      # reimplemented directly here to keep the nix-darwin-specific surface at zero.
      # lib.generators.toPlist renders the XML; only this attrset needs editing.
      #
      # /nix is a separate APFS volume that can mount after launchd first
      # evaluates a boot-time job. A job whose ProgramArguments[0] is a
      # /nix/store path can then fail with "Missing executable"; in the
      # observed incident the job did not come back until it was manually
      # booted out and bootstrapped again. Start through /bin/sh and wait for
      # /nix/store first, like the other Nix LaunchDaemons (nix-daemon,
      # activate-system, nix-gc). The waiting program must live outside /nix,
      # so no wrapper script in the store here. /bin/wait4path has no timeout
      # and only checks the /nix/store directory, not the tailscaled path
      # itself.
      tailscaledPlist = pkgs.writeText "com.tailscale.tailscaled.plist" (
        lib.generators.toPlist { escape = true; } {
          Label = tailscaledLabel;
          ProgramArguments = [
            "/bin/sh"
            "-c"
            "/bin/wait4path /nix/store && exec ${lib.escapeShellArg "${pkgs.tailscale}/bin/tailscaled"}"
          ];
          RunAtLoad = true;
          KeepAlive = true;
        }
      );
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

                  # tailscaled LaunchDaemon: idempotent (re)install, safe to
                  # run on every switch. Regenerates the plist so it always
                  # points at the current nixpkgs tailscale store path.
                  sudo install -m644 ${tailscaledPlist} /Library/LaunchDaemons/com.tailscale.tailscaled.plist
                  sudo launchctl bootout system /Library/LaunchDaemons/com.tailscale.tailscaled.plist 2>/dev/null || true
                  sudo launchctl bootstrap system /Library/LaunchDaemons/com.tailscale.tailscaled.plist
                  sudo launchctl enable system/${tailscaledLabel}
                  sudo launchctl kickstart -k system/${tailscaledLabel}
                  sudo launchctl print system/${tailscaledLabel} >/dev/null

                  # Registration is not readiness: the wrapper may still be
                  # waiting for /nix/store, or tailscaled may have exited.
                  tailscale_ready=false
                  tailscale_status_error=
                  for (( attempt = 1; attempt <= 12; attempt++ )); do
                    if tailscale_status_error=$(
                      ${pkgs.coreutils}/bin/timeout --kill-after=2s 5s \
                        ${pkgs.tailscale}/bin/tailscale status --json 2>&1 >/dev/null
                    ); then
                      tailscale_ready=true
                      break
                    fi
                    [ "$attempt" -eq 12 ] || sleep 1
                  done
                  if [ "$tailscale_ready" != true ]; then
                    printf 'tailscaled did not answer the local CLI after 12 attempts\n' >&2
                    if [ -n "$tailscale_status_error" ]; then
                      printf 'Last tailscale status error: %s\n' "$tailscale_status_error" >&2
                    fi
                    sudo launchctl print system/${tailscaledLabel} >&2 || true
                    exit 1
                  fi
                ''
              else
                ''
                  access_token=$(${lib.getExe pkgs.gh} auth token)
                  nix run --access-tokens "github.com=$access_token" \
                    home-manager -- switch -b backup --flake '.#ubuntu' --impure
                  nix run --access-tokens "github.com=$access_token" \
                    home-manager -- expire-generations '-1 days'

                  # tailscaled systemd unit: idempotent (re)install, safe to
                  # run on every switch. Regenerates the unit so it always
                  # points at the current nixpkgs tailscale store path.
                  sudo install -m644 ${tailscaledUnit} /etc/systemd/system/tailscaled.service
                  sudo systemctl daemon-reload
                  sudo systemctl enable --now tailscaled
                  sudo systemctl is-active --quiet tailscaled
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
            sudo apt-get update
            sudo apt-get upgrade -y
            sudo apt-get upgrade ca-certificates
          ''}/bin/apt-upgrade";
        };

      };
    };
}
