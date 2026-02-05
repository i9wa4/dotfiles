{
  description = "i9wa4 dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    git-hooks,
    treefmt-nix,
    nix-darwin,
    home-manager,
    brew-nix,
    neovim-nightly-overlay,
    vim-overlay,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # Supported systems (x86_64-darwin excluded - Apple Silicon only)
      systems = ["aarch64-darwin" "x86_64-linux" "aarch64-linux"];

      # Import flake-parts modules
      imports = [
        git-hooks.flakeModule
        treefmt-nix.flakeModule
        ./nix/pre-commit.nix
        ./nix/treefmt.nix
      ];

      # Per-system outputs (formatter, devShells, packages, etc.)
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        # nix develop
        devShells = {
          # Local development (includes CI tools + pre-commit hooks)
          default = pkgs.mkShell {
            packages = [
              pkgs.python3
              pkgs.uv
            ];
            shellHook = ''
              uv sync --frozen
              ${config.pre-commit.installationScript}
            '';
          };
          # CI environment (no pre-commit hooks needed, but includes gitleaks for history scan)
          ci = pkgs.mkShell {
            packages = [
              pkgs.gitleaks
              pkgs.python3
              pkgs.uv
            ];
            shellHook = ''
              uv sync --frozen
            '';
          };
        };
      };

      # Flake-level outputs (darwinConfigurations, homeConfigurations, etc.)
      flake = let
        # Common overlays for all darwin/home configurations
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
              ./nix/common/darwin.nix
              ./nix/hosts/${hostname}/darwin.nix
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
                  users.${username} = import ./nix/hosts/${hostname}/home.nix;
                };
              }
            ];
          };
      in {
        # darwin-rebuild switch --flake '.#macos-p' --impure
        # darwin-rebuild switch --flake '.#macos-w' --impure
        # Requires --impure because we use builtins.getEnv to read SUDO_USER
        darwinConfigurations = {
          "macos-p" = mkDarwinConfiguration {hostname = "macos-p";};
          "macos-w" = mkDarwinConfiguration {hostname = "macos-w";};
        };

        # home-manager switch --flake '.#ubuntu' --impure
        # For Ubuntu / WSL2 (standalone home-manager without nix-darwin)
        homeConfigurations."ubuntu" = let
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
              inherit username;
            };
            modules = [
              ./nix/common/home.nix
            ];
          };
      };
    };
}
