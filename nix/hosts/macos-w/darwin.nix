# Host-specific darwin settings for macos-w (work)
_: {
  imports = [
    ../../common/homebrew.nix
    ./casks.nix
  ];

  # Host identification
  networking.hostName = "macos-w";

  # Host-specific darwin settings can be added here
  # Example: services, launchd agents, etc.
}
