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

    # Custom packages (not in nixpkgs)
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      ghalint = pkgs.callPackage ./nix/packages/ghalint.nix {};
      ghatm = pkgs.callPackage ./nix/packages/ghatm.nix {};
      pike = pkgs.callPackage ./nix/packages/pike.nix {};
      pinact = pkgs.callPackage ./nix/packages/pinact.nix {};
      rumdl = pkgs.callPackage ./nix/packages/rumdl.nix {};
      vim-startuptime = pkgs.callPackage ./nix/packages/vim-startuptime.nix {};
    });

    # nix develop
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      customPkgs = self.packages.${system};
      ciPackages = [
        # nixpkgs
        pkgs.actionlint
        pkgs.alejandra
        pkgs.gitleaks
        pkgs.pre-commit
        pkgs.python3
        pkgs.shellcheck
        pkgs.shfmt
        pkgs.statix
        pkgs.stylua
        pkgs.uv
        pkgs.zizmor
        # custom packages
        customPkgs.ghalint
        customPkgs.ghatm
        customPkgs.pinact
        customPkgs.rumdl
      ];
    in {
      # Local development (includes CI tools)
      default = pkgs.mkShell {
        packages = ciPackages;
      };
      # CI environment (minimal)
      ci = pkgs.mkShell {
        packages = ciPackages;
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
          ./nix/darwin.nix
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
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {inherit username;};
              users.${username} = import ./nix/home.nix;
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
          ./nix/home.nix
        ];
      };
  };
}
