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
    # Homebrew casks as Nix packages (no Homebrew needed)
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
    };
    # Latest neovim/vim from source
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    vim-overlay.url = "github:kawarimidoll/vim-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    brew-nix,
    neovim-nightly-overlay,
    vim-overlay,
  }: let
    # Supported systems (x86_64-darwin excluded - Apple Silicon only)
    systems = ["aarch64-darwin" "x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # nix fmt
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # nix develop
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          pre-commit
          shellcheck
          gitleaks
          shfmt
          stylua
          # Python (for pre-commit hooks)
          uv
        ];
      };
    });

    # darwin-rebuild switch --flake '.#macos-p' --impure
    # Requires --impure because we use builtins.getEnv to read SUDO_USER
    darwinConfigurations."macos-p" = let
      # SUDO_USER is automatically set by sudo to the original username
      username = let
        sudoUser = builtins.getEnv "SUDO_USER";
      in
        if sudoUser != ""
        then sudoUser
        else throw "Must run with sudo (SUDO_USER not set). Run: sudo darwin-rebuild switch --flake '.#macos-p' --impure";
    in
      nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit username;};
        modules = [
          ./darwin/configuration.nix
          home-manager.darwinModules.home-manager
          brew-nix.darwinModules.default
          {
            # Allow unfree packages (e.g., terraform with BSL license)
            nixpkgs.config.allowUnfree = true;
            # Overlays
            nixpkgs.overlays = [
              brew-nix.overlays.default
              neovim-nightly-overlay.overlays.default
              (vim-overlay.overlays.features {
                lua = true;
                python3 = true;
              })
            ];
            # Enable brew-nix to symlink apps to /Applications/Nix Apps
            brew-nix.enable = true;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit username;};
            home-manager.users.${username} = import ./home/home.nix;
          }
        ];
      };

    # home-manager switch --flake '.#ubuntu' --impure
    # For Ubuntu / WSL2 (standalone home-manager without nix-darwin)
    homeConfigurations."ubuntu" = let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          neovim-nightly-overlay.overlays.default
          (vim-overlay.overlays.features {
            lua = true;
            python3 = true;
          })
        ];
      };
      # On Linux, USER is available directly (no sudo needed for home-manager)
      username = builtins.getEnv "USER";
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit username;};
        modules = [
          ./home/home.nix
        ];
      };
  };
}
