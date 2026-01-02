{
  description = "i9wa4 dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
  }: {
    # nix fmt
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
    formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.alejandra;

    # darwin-rebuild switch --flake .
    darwinConfigurations."us-MacBook-Air" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
