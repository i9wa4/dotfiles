{
  description = "i9wa4 dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
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
        ./nix/pre-commit.nix
      ];

      # Per-system outputs (formatter, devShells, packages, etc.)
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        # Version pinning overlay
        # NOTE: Override nixpkgs packages when we need specific versions
        # that aren't yet available in nixpkgs (e.g., due to Go version requirements)
        # or when we want to track upstream more closely than nixpkgs updates
        versionOverlay = final: prev: {
          # ghalint 1.5.5 requires Go 1.25.6, nixpkgs has 1.25.5
          # Keep at 1.5.4 until nixpkgs Go is updated
          ghalint = prev.ghalint.overrideAttrs (old: rec {
            version = "1.5.4";
            src = prev.fetchFromGitHub {
              owner = "suzuki-shunsuke";
              repo = "ghalint";
              rev = "v${version}";
              hash = "sha256-pfLXnMbrxXAMpfmjctah85z5GHfI/+NZDrIu1LcBH8M=";
            };
          });
        };
        pkgsWithOverlay = import nixpkgs {
          inherit system;
          overlays = [versionOverlay];
        };
      in {
        # nix fmt
        formatter = pkgs.alejandra;

        # nix develop
        devShells = {
          # Local development (includes CI tools + pre-commit hooks)
          default = pkgsWithOverlay.mkShell {
            packages = [
              pkgsWithOverlay.python3
              pkgsWithOverlay.uv
            ];
            shellHook = ''
              uv sync --frozen
              ${config.pre-commit.installationScript}
            '';
          };
          # CI environment (no pre-commit hooks needed, but includes gitleaks for history scan)
          ci = pkgsWithOverlay.mkShell {
            packages = [
              pkgsWithOverlay.gitleaks
              pkgsWithOverlay.python3
              pkgsWithOverlay.uv
            ];
            shellHook = ''
              uv sync --frozen
            '';
          };
        };
      };

      # Flake-level outputs (darwinConfigurations, homeConfigurations, etc.)
      flake = let
        # Version pinning overlay (shared across all configurations)
        versionOverlay = final: prev: {
          ghalint = prev.ghalint.overrideAttrs (old: rec {
            version = "1.5.4";
            src = prev.fetchFromGitHub {
              owner = "suzuki-shunsuke";
              repo = "ghalint";
              rev = "v${version}";
              hash = "sha256-pfLXnMbrxXAMpfmjctah85z5GHfI/+NZDrIu1LcBH8M=";
            };
          });
        };

        # Common overlays for all darwin/home configurations
        commonOverlays = [
          versionOverlay
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
