{
  pkgs,
  lib,
  username,
  ...
}: {
  # User info (username is passed from flake.nix via extraSpecialArgs)
  home.username = username;
  home.homeDirectory = lib.mkForce (
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}"
  );

  # Home Manager state version
  home.stateVersion = "24.11";

  # User packages (managed by home-manager)
  home.packages = [
    pkgs.git
    pkgs.ripgrep
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
