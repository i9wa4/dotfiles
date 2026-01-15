# Host-specific darwin settings for macos-p (personal)
_: {
  imports = [
    ../../common/homebrew.nix
    ./casks.nix
  ];

  # Host identification
  networking.hostName = "macos-p";

  # Host-specific darwin settings can be added here
  # Example: services, launchd agents, etc.
}
