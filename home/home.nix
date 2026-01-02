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
  # Set to the version of home-manager at initial installation. Do not change.
  # cf. https://nix-community.github.io/home-manager/options.xhtml#opt-home.stateVersion
  home.stateVersion = "24.11";

  # User packages (managed by home-manager)
  home.packages = [
    pkgs.git
    pkgs.ripgrep
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
