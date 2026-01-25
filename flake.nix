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
    # AI coding agents
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    brew-nix,
    neovim-nightly-overlay,
    vim-overlay,
    claude-code-overlay,
    llm-agents,
  }: let
    # Supported systems (x86_64-darwin excluded - Apple Silicon only)
    systems = ["aarch64-darwin" "x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;

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
  in {
    # nix fmt
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # nix develop
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [versionOverlay];
      };
      ciPackages = [
        # nixpkgs (ghalint via versionOverlay)
        pkgs.actionlint
        pkgs.alejandra
        pkgs.ghalint
        pkgs.ghatm
        pkgs.gitleaks
        pkgs.pinact
        # NOTE: pre-commit is managed via `uv run pre-commit` to avoid Swift build dependency
        pkgs.python3
        pkgs.rumdl
        pkgs.shellcheck
        pkgs.shfmt
        pkgs.statix
        pkgs.stylua
        pkgs.uv
        pkgs.zizmor
      ];
    in {
      # Local development (includes CI tools)
      default = pkgs.mkShell {
        packages = ciPackages;
        shellHook = ''
          uv sync --frozen
        '';
      };
      # CI environment (minimal)
      ci = pkgs.mkShell {
        packages = ciPackages;
        shellHook = ''
          uv sync --frozen
        '';
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
          ./nix/common/darwin.nix
          ./nix/hosts/macos-p/darwin.nix
          home-manager.darwinModules.home-manager
          brew-nix.darwinModules.default
          {
            # Allow unfree packages (e.g., terraform with BSL license)
            nixpkgs.config.allowUnfree = true;
            # Overlays
            nixpkgs.overlays = [
              versionOverlay
              brew-nix.overlays.default
              neovim-nightly-overlay.overlays.default
              (vim-overlay.overlays.features {
                lua = true;
                python3 = true;
              })
              claude-code-overlay.overlays.default
            ];
            # Enable brew-nix to symlink apps to /Applications/Nix Apps
            brew-nix.enable = true;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit username;
                llmAgentsPkgs = llm-agents.packages."aarch64-darwin";
              };
              users.${username} = import ./nix/hosts/macos-p/home.nix;
            };
          }
        ];
      };

    # darwin-rebuild switch --flake '.#macos-w' --impure
    darwinConfigurations."macos-w" = let
      username = let
        sudoUser = builtins.getEnv "SUDO_USER";
      in
        if sudoUser != ""
        then sudoUser
        else throw "Must run with sudo (SUDO_USER not set). Run: sudo darwin-rebuild switch --flake '.#macos-w' --impure";
    in
      nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit username;};
        modules = [
          ./nix/common/darwin.nix
          ./nix/hosts/macos-w/darwin.nix
          home-manager.darwinModules.home-manager
          brew-nix.darwinModules.default
          {
            # Allow unfree packages (e.g., terraform with BSL license)
            nixpkgs.config.allowUnfree = true;
            # Overlays
            nixpkgs.overlays = [
              versionOverlay
              brew-nix.overlays.default
              neovim-nightly-overlay.overlays.default
              (vim-overlay.overlays.features {
                lua = true;
                python3 = true;
              })
              claude-code-overlay.overlays.default
            ];
            # Enable brew-nix to symlink apps to /Applications/Nix Apps
            brew-nix.enable = true;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit username;
                llmAgentsPkgs = llm-agents.packages."aarch64-darwin";
              };
              users.${username} = import ./nix/hosts/macos-w/home.nix;
            };
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
          versionOverlay
          neovim-nightly-overlay.overlays.default
          (vim-overlay.overlays.features {
            lua = true;
            python3 = true;
          })
          claude-code-overlay.overlays.default
        ];
      };
      # On Linux, USER is available directly (no sudo needed for home-manager)
      username = builtins.getEnv "USER";
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit username;
          llmAgentsPkgs = llm-agents.packages.${system};
        };
        modules = [
          ./nix/common/home.nix
        ];
      };
  };
}
