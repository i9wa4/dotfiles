# Home Manager configurations (standalone, for Linux/WSL2)
# This module is imported by flake.nix via flake-parts
{
  inputs,
  commonNixSettings,
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
        inherit username inputs;
      };
      modules = [
        nix-index-database.homeModules.nix-index
        (
          {
            pkgs,
            lib,
            ...
          }:
          {
            nix = {
              # Garbage collection is handled by programs.nh.clean in
              # nix/home-manager/default.nix. Home Manager warns when both
              # programs.nh.clean.enable and nix.gc.automatic are enabled.
              gc = {
                automatic = false;
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
              # tailscale: CLI + tailscaled binary. The systemd unit that runs
              # tailscaled as root is generated and installed by the `switch`
              # app (nix/flake-parts/modules/apps.nix) on every run, since
              # standalone home-manager cannot manage root-level systemd
              # units directly.
              packages = [ pkgs.tailscale ];
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
          }
        )
        ../../home-manager
      ];
    };
}
