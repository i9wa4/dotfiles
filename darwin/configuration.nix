{pkgs, ...}: {
  # Nix settings
  nix.settings.experimental-features = "nix-command flakes";

  # Enable zsh (creates /etc/zshenv for nix-darwin environment)
  programs.zsh.enable = true;

  # System packages
  environment.systemPackages = [
    pkgs.vim
  ];

  # Set Git commit hash for darwin-hierarchical versioning
  system.configurationRevision = null;

  # Used for backwards compatibility
  system.stateVersion = 6;

  # Platform
  nixpkgs.hostPlatform = "aarch64-darwin";
}
