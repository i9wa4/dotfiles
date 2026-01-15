# Common Homebrew settings
# Host-specific casks are defined in hosts/<name>/casks.nix
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
    # NOTE: casks are defined in hosts/<name>/casks.nix
  };
}
