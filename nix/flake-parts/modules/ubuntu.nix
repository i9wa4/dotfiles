# Home Manager configurations (standalone, for Linux/WSL2)
# This module is imported by flake.nix via flake-parts
{
  inputs,
  commonNixSettings,
  mkPkgsUnstable,
  ...
}:
let
  inherit (inputs) nixpkgs home-manager nix-index-database;
in
{
  # home-manager switch --flake '.#ubuntu' --impure
  # For Ubuntu / WSL2 (standalone home-manager without nix-darwin)
  flake.homeConfigurations."ubuntu" =
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        localSystem = system;
        config.allowUnfree = true;
      };
      pkgs-unstable = mkPkgsUnstable system;
      # SSM sessions set USER=root even for non-root users (EUID != 0).
      # Fallback chain: LOGNAME -> HOME basename -> USER (least reliable)
      username =
        let
          user = builtins.getEnv "USER";
          logname = builtins.getEnv "LOGNAME";
          home = builtins.getEnv "HOME";
          homeUser = baseNameOf home;
        in
        if logname != "" then
          logname
        else if homeUser != "" && homeUser != "root" then
          homeUser
        else if user != "" then
          user
        else
          abort "Cannot determine username: set LOGNAME environment variable";
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit username inputs pkgs-unstable;
      };
      modules = [
        nix-index-database.homeModules.nix-index
        (
          {
            pkgs,
            lib,
            ...
          }:
          let
            storageReportScript = pkgs.writeShellScriptBin "storage-report-daily" ''
              report_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/storage-report"
              umask 077
              mkdir -p "$report_dir"
              exec ${pkgs.bash}/bin/bash ${./../../../bin/ubuntu/storage-pressure-report.sh} --self --summary >"$report_dir/latest.log"
            '';
          in
          {
            nix = {
              # Garbage collection via systemd timer (daily at noon, delete older than 1 day)
              # cf. nix-darwin's nix.gc.interval in nix-darwin/default.nix
              gc = {
                automatic = true;
                dates = "12:00";
                options = "--delete-older-than 1d";
              };
              settings = commonNixSettings // {
                # Nix store optimisation via hard links (writes to ~/.config/nix/nix.conf)
                # cf. nix-darwin's nix.optimise.automatic in nix-darwin/default.nix
                # NOTE: nix.optimise module does not exist in HM standalone
                auto-optimise-store = true;
              };
            };
            # Linux-specific home-manager settings
            home = {
              packages = [
                # zsh: installed by home-manager programs.zsh (zsh.nix)
                pkgs.wslu # WSL utilities (harmless on non-WSL)
              ];
              # Timezone data (not needed on macOS)
              sessionVariables.TZDIR = "${pkgs.tzdata}/share/zoneinfo";
              # Start ssh-agent if not running
              # cf. https://inno-tech-life.com/dev/infra/wsl2-ssh-agent/
              activation.startSshAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                if [ -z "''${SSH_AUTH_SOCK:-}" ]; then
                  eval $(${pkgs.openssh}/bin/ssh-agent)
                fi
              '';
            };
            # Daily storage-pressure-report for the current user
            # cf. nix.gc above (auto GC also runs daily via home-manager)
            systemd.user.services."storage-report" = {
              Unit.Description = "Linux home-directory storage pressure report";
              Service = {
                Type = "oneshot";
                ExecStart = "${storageReportScript}/bin/storage-report-daily";
                StandardError = "journal";
              };
            };
            systemd.user.timers."storage-report" = {
              Unit.Description = "Daily Linux home storage pressure report";
              Timer = {
                OnCalendar = "daily";
                Persistent = true;
              };
              Install.WantedBy = [ "timers.target" ];
            };
          }
        )
        ../../home-manager
      ];
    };
}
