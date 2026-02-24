{
  description = "i9wa4 dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
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
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Latest neovim/vim from source
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    vim-overlay.url = "github:kawarimidoll/vim-overlay";
    # AI tools sub-flake (independent flake.lock for cache hits + frequent updates)
    ai-tools.url = "path:./nix/ai-tools";
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
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
    streamlit-skills = {
      url = "github:streamlit/agent-skills";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # Supported systems (x86_64-darwin excluded - Apple Silicon only)
      systems = ["aarch64-darwin" "x86_64-linux" "aarch64-linux"];

      imports = [./nix/flake-parts];

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
