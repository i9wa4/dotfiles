# Home Manager configurations (standalone, for Linux/WSL2)
# This module is imported by flake.nix via flake-parts
{inputs, ...}: let
  inherit (inputs) nixpkgs home-manager neovim-nightly-overlay vim-overlay claude-chill;

  # Common overlays for all home configurations
  commonOverlays = [
    neovim-nightly-overlay.overlays.default
    (vim-overlay.overlays.features {
      lua = true;
      python3 = true;
    })
    (final: _prev: {
      claude-chill = claude-chill.packages.${final.system}.default;
    })
  ];
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
    # On Linux, USER is available directly (no sudo needed for home-manager)
    username = builtins.getEnv "USER";
  in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit username inputs;
      };
      modules = [
        ../home
      ];
    };
}
