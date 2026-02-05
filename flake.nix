{
  description = "i9wa4 dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
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

      # Per-system outputs (formatter, devShells, packages, etc.)
      perSystem = {
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
        ciPackages = [
          # nixpkgs (ghalint via versionOverlay)
          pkgsWithOverlay.actionlint
          pkgsWithOverlay.alejandra
          pkgsWithOverlay.ghalint
          pkgsWithOverlay.ghatm
          pkgsWithOverlay.gitleaks
          pkgsWithOverlay.pinact
          # NOTE: pre-commit is managed via `uv run pre-commit` to avoid Swift build dependency
          pkgsWithOverlay.python3
          pkgsWithOverlay.rumdl
          pkgsWithOverlay.shellcheck
          pkgsWithOverlay.shfmt
          pkgsWithOverlay.statix
          pkgsWithOverlay.stylua
          pkgsWithOverlay.uv
          pkgsWithOverlay.zizmor
        ];
      in {
        # nix fmt
        formatter = pkgs.alejandra;

        # nix develop
        devShells = {
          # Local development (includes CI tools)
          default = pkgsWithOverlay.mkShell {
            packages = ciPackages;
            shellHook = ''
              uv sync --frozen
            '';
          };
          # CI environment (minimal)
          ci = pkgsWithOverlay.mkShell {
            packages = ciPackages;
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
