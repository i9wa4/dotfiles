# Darwin configurations (macOS)
# This module is imported by flake.nix via flake-parts
{
  inputs,
  commonOverlays,
  commonNixSettings,
  ...
}:
let
  inherit (inputs) nix-darwin home-manager nix-index-database;

  # Helper to get username from environment
  # SUDO_USER is automatically set by sudo to the original username
  getUsernameFromSudo = throw "Must run with sudo (SUDO_USER not set). Run: sudo darwin-rebuild switch --flake '.#<hostname>' --impure";
  getUsername =
    let
      sudoUser = builtins.getEnv "SUDO_USER";
    in
    if sudoUser != "" then sudoUser else getUsernameFromSudo;

  # Helper to create darwin configurations
  # All host-specific config is inlined via parameters (no hosts/ directory needed)
  mkDarwinConfiguration =
    {
      hostname,
      system ? "aarch64-darwin",
      casks ? [ ],
    }:
    let
      username = getUsername;
    in
    nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit
          username
          inputs
          commonOverlays
          commonNixSettings
          ;
      };
      modules = [
        ../../nix-darwin
        home-manager.darwinModules.home-manager
        nix-index-database.darwinModules.nix-index
        {
          # Host identification
          networking.hostName = hostname;

          # Homebrew casks
          homebrew.casks = casks;

          # Home Manager integration
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit username inputs;
            };
            users.${username} =
              {
                pkgs,
                lib,
                config,
                ...
              }:
              {
                imports = [
                  nix-index-database.homeModules.nix-index
                  ../../home-manager
                  ../../home-manager/modules/vscode.nix
                ];
                # Darwin-specific cleanup (.DS_Store, xattr)
                home.activation.cleanDarwinFiles =
                  let
                    fd = "${pkgs.fd}/bin/fd";
                    homeDir = config.home.homeDirectory;
                    ghqRoot = "${homeDir}/ghq";
                  in
                  lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                    ${fd} ".DS_Store" ${ghqRoot} --hidden --no-ignore | xargs rm -f || true
                    ${fd} . ${ghqRoot} -t f --exclude ".git" -x /usr/bin/xattr -c {} \; || true
                  '';
              };
          };
        }
      ];
    };
in
{
  # darwin-rebuild switch --flake '.#macos-p' --impure
  # darwin-rebuild switch --flake '.#macos-w' --impure
  # Requires --impure because we use builtins.getEnv to read SUDO_USER
  flake.darwinConfigurations =
    let
      commonCasks = [
        "docker-desktop"
        "drawio"
        "google-chrome"
        "obsidian"
        "stats"
        "visual-studio-code"
        "wezterm"
        "zoom"
      ];
    in
    {
      "macos-p" = mkDarwinConfiguration {
        hostname = "macos-p";
        casks = commonCasks;
      };
      "macos-w" = mkDarwinConfiguration {
        hostname = "macos-w";
        casks = commonCasks ++ [ "openvpn-connect" ];
      };
    };
}
