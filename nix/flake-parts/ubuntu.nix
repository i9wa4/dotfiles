# Home Manager configurations (standalone, for Linux/WSL2)
# This module is imported by flake.nix via flake-parts
{
  inputs,
  commonOverlays,
  commonNixSettings,
  ...
}: let
  inherit (inputs) nixpkgs home-manager nix-index-database;
in {
  # home-manager switch --flake '.#ubuntu' --impure
  # For Ubuntu / WSL2 (standalone home-manager without nix-darwin)
  flake.homeConfigurations."ubuntu" = let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = commonOverlays;
    };
    # SSM sessions set USER=root even for non-root users (EUID != 0).
    # Fallback chain: LOGNAME -> HOME basename -> USER (least reliable)
    username = let
      user = builtins.getEnv "USER";
      logname = builtins.getEnv "LOGNAME";
      home = builtins.getEnv "HOME";
      homeUser = baseNameOf home;
    in
      if logname != ""
      then logname
      else if homeUser != "" && homeUser != "root"
      then homeUser
      else if user != ""
      then user
      else abort "Cannot determine username: set LOGNAME environment variable";
  in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit username inputs;
      };
      modules = [
        nix-index-database.homeModules.nix-index
        ({
          pkgs,
          lib,
          ...
        }: {
          nix = {
            # Garbage collection via systemd timer (daily at noon, delete older than 1 day)
            # cf. nix-darwin's nix.gc.interval in nix-darwin/default.nix
            gc = {
              automatic = true;
              dates = "12:00";
              options = "--delete-older-than 1d";
            };
            settings =
              commonNixSettings
              // {
                # Nix store optimisation via hard links (writes to ~/.config/nix/nix.conf)
                # cf. nix-darwin's nix.optimise.automatic in nix-darwin/default.nix
                # NOTE: nix.optimise module does not exist in HM standalone
                auto-optimise-store = true;
              };
          };
          # Linux-specific home-manager settings
          home = {
            packages = [
              pkgs.zsh
              pkgs.wslu # WSL utilities (harmless on non-WSL)
              pkgs.udev-gothic # Font (macOS installs via nix-darwin fonts.packages)
            ];
            # Timezone data (not needed on macOS)
            sessionVariables.TZDIR = "${pkgs.tzdata}/share/zoneinfo";
            # Start ssh-agent if not running
            # cf. https://inno-tech-life.com/dev/infra/wsl2-ssh-agent/
            activation.startSshAgent = lib.hm.dag.entryAfter ["writeBoundary"] ''
              if [ -z "''${SSH_AUTH_SOCK:-}" ]; then
                eval $(${pkgs.openssh}/bin/ssh-agent)
              fi
            '';
          };
        })
        ../home
      ];
    };
}
