# Darwin configurations (macOS)
# This module is imported by flake.nix via flake-parts
{
  inputs,
  lib,
  commonNixSettings,
  ...
}:
let
  inherit (inputs) nix-darwin home-manager nix-index-database;
  homebrewTaps = [
    "asmvik/formulae"
  ];
  commonHomebrewBrews = [
    "asmvik/formulae/skhd"
    "macmon"
    "mise"
    "podman"
    "podman-compose"
  ];
  commonHomebrewCasks = [
    "drawio"
    "google-chrome"
    "kitty"
    "macskk"
    "zoom"
  ];
  darwinHosts = {
    "macos-p" = {
      casks = commonHomebrewCasks;
    };
    "macos-w" = {
      casks = commonHomebrewCasks ++ [ "openvpn-connect" ];
    };
  };
  skhdConfig = ''
    # App switching: Alt + 1/2/3
    alt - 1 : open -a "kitty"
    alt - 2 : open -a "Google Chrome"
  '';

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
      taps ? homebrewTaps,
      brews ? commonHomebrewBrews,
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

          # Homebrew-managed macOS tools and GUI apps.
          # Allow activation-time metadata updates so Homebrew's cask API and
          # portable Ruby stay in sync before `brew bundle` resolves casks.
          # Keep upgrades disabled so `nix run '.#switch'` does not force app
          # version bumps.
          homebrew = {
            enable = true;
            inherit
              taps
              brews
              casks
              ;
            onActivation = {
              autoUpdate = true;
              upgrade = false;
              # Remove Homebrew packages and casks not declared in this module
              # during `nix run '.#switch'`.
              cleanup = "uninstall";
            };
          };

          # Homebrew requires explicit trust for non-official taps when tap
          # trust is enforced. Run this before nix-darwin's Homebrew Bundle
          # activation.
          system.activationScripts.extraActivation.text = lib.mkAfter ''
            if [ -x /opt/homebrew/bin/brew ]; then
              echo >&2 "trusting Homebrew taps..."
              ${lib.concatMapStringsSep "\n" (tap: ''
                sudo \
                  --user=${lib.escapeShellArg username} \
                  --set-home \
                  env HOMEBREW_NO_AUTO_UPDATE=1 PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
                  /opt/homebrew/bin/brew tap ${lib.escapeShellArg tap} >/dev/null
                sudo \
                  --user=${lib.escapeShellArg username} \
                  --set-home \
                  env HOMEBREW_NO_AUTO_UPDATE=1 PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
                  /opt/homebrew/bin/brew trust --tap ${lib.escapeShellArg tap} >/dev/null
              '') taps}
            fi
          '';

          # skhd: hotkey daemon for app switching.
          #
          # Run the Homebrew binary from a stable path. When skhd is launched
          # directly from the Nix store, nixpkgs updates can change the
          # executable path and make macOS TCC ask for Accessibility permission
          # again.
          #
          # If Accessibility must be granted manually, add the resolved Cellar
          # binary (for example `/opt/homebrew/Cellar/skhd/<version>/bin/skhd`)
          # instead of the `/opt/homebrew/bin/skhd` symlink. A Homebrew skhd
          # version upgrade may still require granting the new Cellar binary
          # once, but regular Nix updates will no longer rotate the executable
          # path.
          environment.etc."skhdrc".text = skhdConfig;
          launchd.user.agents.skhd = {
            serviceConfig = {
              ProgramArguments = [
                "/opt/homebrew/bin/skhd"
                "-c"
                "/etc/skhdrc"
              ];
              KeepAlive = true;
              RunAtLoad = true;
              ProcessType = "Interactive";
              EnvironmentVariables = {
                PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
              };
            };
          };

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
  flake.darwinConfigurations = lib.mapAttrs (
    hostname: hostConfig: mkDarwinConfiguration ({ inherit hostname; } // hostConfig)
  ) darwinHosts;
}
