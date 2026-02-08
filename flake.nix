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
    # AI coding agent PTY proxy (terminal rendering optimization)
    claude-chill = {
      url = "github:davidbeesley/claude-chill";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Agent skills declarative management
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Nix index database (prebuilt for comma)
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # External skill sources (non-flake)
    dbt-agent-skills = {
      url = "github:dbt-labs/dbt-agent-skills";
      flake = false;
    };
  };

  outputs = inputs @ {
    flake-parts,
    git-hooks,
    treefmt-nix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # Supported systems (x86_64-darwin excluded - Apple Silicon only)
      systems = ["aarch64-darwin" "x86_64-linux" "aarch64-linux"];

      # Import flake-parts modules
      imports = [
        git-hooks.flakeModule
        treefmt-nix.flakeModule
        # Common modules (shared across repositories)
        ./nix/flake-modules/pre-commit-base.nix
        ./nix/flake-modules/treefmt-base.nix
        # Dotfiles-specific modules
        ./nix/flake-parts/pre-commit.nix
        ./nix/flake-parts/treefmt.nix
        ./nix/flake-parts/darwin.nix
        ./nix/flake-parts/home.nix
      ];

      # Top-level flake outputs
      flake = {
        # Export common modules for other repositories
        flakeModules = {
          pre-commit-base = ./nix/flake-modules/pre-commit-base.nix;
          treefmt-base = ./nix/flake-modules/treefmt-base.nix;
        };
      };

      # Per-system outputs (devShells, etc.)
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
    };
}
