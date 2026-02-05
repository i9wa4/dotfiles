# Darwin configurations (macOS)
# This module is imported by flake.nix via flake-parts
{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nixpkgs nix-darwin home-manager brew-nix neovim-nightly-overlay vim-overlay;

  # Common overlays for all darwin configurations
  commonOverlays = [
    neovim-nightly-overlay.overlays.default
    (vim-overlay.overlays.features {
      lua = true;
      python3 = true;
    })
  ];

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
  # Reduces duplication between macos-p and macos-w
  mkDarwinConfiguration = {
    hostname,
    system ? "aarch64-darwin",
  }: let
    username = getUsername;
  in
    nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {inherit username;};
      modules = [
        ../nix/common/darwin.nix
        ../nix/hosts/${hostname}/darwin.nix
        home-manager.darwinModules.home-manager
        brew-nix.darwinModules.default
        {
          # Allow unfree packages (e.g., terraform with BSL license)
          nixpkgs.config.allowUnfree = true;
          # Overlays
          nixpkgs.overlays =
            commonOverlays
            ++ [
              brew-nix.overlays.default
            ];
          # Enable brew-nix to symlink apps to /Applications/Nix Apps
          brew-nix.enable = true;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit username;
            };
            users.${username} = import ../nix/hosts/${hostname}/home.nix;
          };
        }
      ];
    };
in {
  # darwin-rebuild switch --flake '.#macos-p' --impure
  # darwin-rebuild switch --flake '.#macos-w' --impure
  # Requires --impure because we use builtins.getEnv to read SUDO_USER
  flake.darwinConfigurations = {
    "macos-p" = mkDarwinConfiguration {hostname = "macos-p";};
    "macos-w" = mkDarwinConfiguration {hostname = "macos-w";};
  };
}
