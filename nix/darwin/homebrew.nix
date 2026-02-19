# Common Homebrew settings
# Host-specific casks are defined in flake-parts/darwin.nix (extraCasks parameter)
_: {
  homebrew = {
    enable = true;
    onActivation = {
      # Remove formulae/casks not listed in configuration
      cleanup = "uninstall";
      # Update Homebrew before installing
      autoUpdate = true;
      # Upgrade outdated formulae/casks
      upgrade = true;
    };
    # Common casks (host-specific casks are merged from flake-parts/darwin.nix)
    casks = [
      "docker-desktop"
      "drawio"
      "google-chrome"
      "stats"
      "visual-studio-code"
      "wezterm"
      "zoom"
    ];
  };
}
