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
        ./nix/flake-parts/pre-commit.nix
        ./nix/flake-parts/treefmt.nix
        ./nix/flake-parts/darwin.nix
        ./nix/flake-parts/home.nix
      ];

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
