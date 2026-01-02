{
  description = "i9wa4 dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
  }: {
    # nix fmt
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
    formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.alejandra;

    # darwin-rebuild switch --flake '.#macos-p' --impure
    darwinConfigurations."macos-p" = let
      # When running with sudo, HOME becomes /var/root, so we use SUDO_USER instead
      # SUDO_USER contains the original username when running under sudo
      dotfilesDir = let
        sudoUser = builtins.getEnv "SUDO_USER";
        userHome =
          if sudoUser != ""
          then "/Users/${sudoUser}"
          else builtins.getEnv "HOME";
      in
        userHome + "/ghq/github.com/i9wa4/dotfiles";
      userConfig = import (dotfilesDir + "/user.nix");
      username = userConfig.username;
    in
      nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit username;};
            home-manager.users.${username} = import ./home/home.nix;
          }
        ];
      };
  };
}
