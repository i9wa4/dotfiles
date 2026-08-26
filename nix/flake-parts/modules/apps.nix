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
      jq = lib.getExe pkgs.jq;
      nix = lib.getExe pkgs.nix;
      tmuxA2aPostmanUpdateScript = ./../../../scripts/nix/flake-input-update-tmux-a2a-postman.sh;
      wazaUpdateScript = ./../../../scripts/nix/package-update-waza.sh;
      actrunUpdateScript = ./../../../scripts/nix/package-update-actrun.sh;

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
      tailscaledPlist = pkgs.writeText "com.tailscale.tailscaled.plist" (
        lib.generators.toPlist { escape = true; } {
          Label = "com.tailscale.tailscaled";
          ProgramArguments = [ "${pkgs.tailscale}/bin/tailscaled" ];
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
                  sudo launchctl unload /Library/LaunchDaemons/com.tailscale.tailscaled.plist 2>/dev/null || true
                  sudo launchctl load -w /Library/LaunchDaemons/com.tailscale.tailscaled.plist
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
