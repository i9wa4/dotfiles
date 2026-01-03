{
  pkgs,
  lib,
  username,
  ...
}: let
  dotfilesDir = ../.; # Repository root
in {
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

  # ============================================================================
  # Dotfiles (symlink to existing files)
  # ============================================================================
  home.file = {
    ".zshenv".source = "${dotfilesDir}/dot.zshenv";
    ".zshrc".source = "${dotfilesDir}/dot.zshrc";
    ".editorconfig".source = "${dotfilesDir}/dot.editorconfig";
  };

  xdg.configFile = {
    "git".source = "${dotfilesDir}/dot.config/git";
    "nvim".source = "${dotfilesDir}/dot.config/nvim";
    "vim".source = "${dotfilesDir}/dot.config/vim";
    "tmux".source = "${dotfilesDir}/dot.config/tmux";
    "wezterm".source = "${dotfilesDir}/dot.config/wezterm";
    "efm-langserver".source = "${dotfilesDir}/dot.config/efm-langserver";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
