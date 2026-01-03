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
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    brew-nix,
  }: let
    # Supported systems
    systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux"];
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
          # Pre-commit
          pre-commit
          # Linters
          shellcheck
          actionlint
          gitleaks
          # Formatters
          shfmt
          stylua
          # Python (for pre-commit hooks)
          python3
          uv
        ];
      };
    });

    # darwin-rebuild switch --flake '.#macos-p' --impure
    darwinConfigurations."macos-p" = let
      # When running with sudo, HOME becomes /var/root, so we use SUDO_USER instead
      # SUDO_USER contains the original username when running under sudo
      dotfilesDir = let
        sudoUser = builtins.getEnv "SUDO_USER";
        userHome =
          if sudoUser != ""
          then "/Users/${sudoUser}"
          else builtins.getEnv "HOME";
      in
        userHome + "/ghq/github.com/i9wa4/dotfiles";
      userNixPath = dotfilesDir + "/user.nix";
      userConfig =
        if builtins.pathExists userNixPath
        then import userNixPath
        else throw "user.nix not found. Run: cp user.nix.example user.nix && edit user.nix";
      username = userConfig.username;
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
            # Add brew-nix overlay for Homebrew casks as Nix packages
            nixpkgs.overlays = [brew-nix.overlays.default];
            # Enable brew-nix to symlink apps to /Applications/Nix Apps
            brew-nix.enable = true;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit username;};
            home-manager.users.${username} = import ./home/home.nix;
          }
        ];
      };
  };
}
