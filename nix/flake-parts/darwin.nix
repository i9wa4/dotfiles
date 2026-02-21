# Darwin configurations (macOS)
# This module is imported by flake.nix via flake-parts
{
  inputs,
  commonOverlays,
  ...
}: let
  inherit (inputs) nix-darwin home-manager nix-index-database;

  # Helper to get username from environment
  # SUDO_USER is automatically set by sudo to the original username
  getUsernameFromSudo = throw "Must run with sudo (SUDO_USER not set). Run: sudo darwin-rebuild switch --flake '.#<hostname>' --impure";
  getUsername = let
    sudoUser = builtins.getEnv "SUDO_USER";
  in
    if sudoUser != ""
    then sudoUser
    else getUsernameFromSudo;

  # Helper to create darwin configurations
  # All host-specific config is inlined via parameters (no hosts/ directory needed)
  mkDarwinConfiguration = {
    hostname,
    system ? "aarch64-darwin",
    casks ? [],
  }: let
    username = getUsername;
  in
    nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {inherit username inputs commonOverlays;};
      modules = [
        ../nix-darwin
        home-manager.darwinModules.home-manager
        nix-index-database.darwinModules.nix-index
        {
          # Host identification
          networking.hostName = hostname;

          # Homebrew casks
          homebrew.casks = casks;

          # Home Manager integration
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit username inputs;
            };
            users.${username} = {
              imports = [../home];
              programs.vscode = {
                enable = true;
                profiles.default.userSettings = {
                  "breadcrumbs.enabled" = false;
                  "editor.fontFamily" = "'UDEV Gothic 35LG', monospace";
                  "editor.minimap.enabled" = false;
                  "editor.mouseWheelZoom" = true;
                  "terminal.integrated.fontFamily" = "'UDEV Gothic 35LG', monospace";
                };
              };
            };
          };
        }
      ];
    };
in {
  # darwin-rebuild switch --flake '.#macos-p' --impure
  # darwin-rebuild switch --flake '.#macos-w' --impure
  # Requires --impure because we use builtins.getEnv to read SUDO_USER
  flake.darwinConfigurations = let
    commonCasks = [
      "docker-desktop"
      "drawio"
      "google-chrome"
      "stats"
      "visual-studio-code"
      "wezterm"
      "zoom"
    ];
  in {
    "macos-p" = mkDarwinConfiguration {
      hostname = "macos-p";
      casks = commonCasks;
    };
    "macos-w" = mkDarwinConfiguration {
      hostname = "macos-w";
      casks = commonCasks ++ ["openvpn-connect"];
    };
  };
}
