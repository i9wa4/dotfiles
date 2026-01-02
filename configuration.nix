{pkgs, ...}: {
  # Nix settings
  nix.settings.experimental-features = "nix-command flakes";

  # System packages
  environment.systemPackages = [
    pkgs.vim
  ];

  # Auto upgrade nix package and the daemon service
  services.nix-daemon.enable = true;

  # Set Git commit hash for darwin-hierarchical versioning
  system.configurationRevision = null;

  # Used for backwards compatibility
  system.stateVersion = 6;

  # Platform
  nixpkgs.hostPlatform = "aarch64-darwin";
}
