{
  description = "i9wa4 dotfiles";

  inputs = {
    # No follows
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Follows nixpkgs
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Follows nixpkgs-unstable
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Follows nixpkgs + home-manager
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Non-flake sources
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
    dbt-agent-skills = {
      url = "github:dbt-labs/dbt-agent-skills";
      flake = false;
    };
    streamlit-skills = {
      url = "github:streamlit/agent-skills";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Supported systems (x86_64-darwin excluded - Apple Silicon only)
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [ ./nix/flake-parts ];

      # Per-system outputs (devShells, etc.)
      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          # nix develop
          devShells = {
            # Local development (includes CI tools + pre-commit hooks)
            default = pkgs.mkShell {
              shellHook = ''
                ${config.pre-commit.installationScript}
              '';
            };
            # CI environment (no pre-commit hooks needed, but includes gitleaks for history scan)
            ci = pkgs.mkShell {
              packages = [
                pkgs.gitleaks
              ];
            };
          };
        };
    };
}
