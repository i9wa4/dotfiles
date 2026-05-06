# Darwin configurations (macOS)
# This module is imported by flake.nix via flake-parts
{
  inputs,
  commonNixSettings,
  mkPkgsUnstable,
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
      pkgs-unstable = mkPkgsUnstable system;
    in
    nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit
          username
          inputs
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
              inherit username inputs pkgs-unstable;
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
                # NOTE: macSKK loads file dictionaries from its sandboxed Documents/Dictionaries path.
                # NOTE: Dictionaries are installed once; existing files are left untouched.
                home.activation.setupMacSkkDict =
                  let
                    git = "${pkgs.git}/bin/git";
                  in
                  lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                    macSkkDir="$HOME/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries"
                    mkdir -p "$macSkkDir"

                    missing=()
                    for dict in SKK-JISYO.L SKK-JISYO.jinmei SKK-JISYO.assoc SKK-JISYO.emoji.utf8; do
                      [[ -f "$macSkkDir/$dict" ]] || missing+=("$dict")
                    done

                    if [[ ''${#missing[@]} -gt 0 ]]; then
                      tmpDir="$(mktemp -d "''${TMPDIR:-/tmp}/macskk-dict.XXXXXX")"

                      ${git} clone --depth 1 https://github.com/skk-dev/dict "$tmpDir/skk-dev-dict"
                      ${git} clone --depth 1 https://github.com/uasi/skk-emoji-jisyo "$tmpDir/skk-emoji-jisyo"

                      [[ -f "$macSkkDir/SKK-JISYO.L" ]] || cp "$tmpDir/skk-dev-dict/SKK-JISYO.L" "$macSkkDir/SKK-JISYO.L"
                      [[ -f "$macSkkDir/SKK-JISYO.jinmei" ]] || cp "$tmpDir/skk-dev-dict/SKK-JISYO.jinmei" "$macSkkDir/SKK-JISYO.jinmei"
                      [[ -f "$macSkkDir/SKK-JISYO.assoc" ]] || cp "$tmpDir/skk-dev-dict/SKK-JISYO.assoc" "$macSkkDir/SKK-JISYO.assoc"
                      [[ -f "$macSkkDir/SKK-JISYO.emoji.utf8" ]] || cp "$tmpDir/skk-emoji-jisyo/SKK-JISYO.emoji.utf8" "$macSkkDir/SKK-JISYO.emoji.utf8"
                      rm -rf "$tmpDir"
                    fi
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
        "kitty"
        "macskk"
        "monitorcontrol"
        "obsidian"
        "visual-studio-code"
        "zoom"
        # "maccy"
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
