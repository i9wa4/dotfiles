{
  pkgs,
  lib,
  config,
  username,
  ...
}: let
  dotfilesDir = ../.; # Repository root
  # Direct symlink (not via Nix store) for frequently edited files
  symlink = config.lib.file.mkOutOfStoreSymlink;
  dotfilesDirAbs = "/Users/${username}/ghq/github.com/i9wa4/dotfiles";
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
  # Dotfiles (via Nix store)
  # cf. Makefile MF_LINK_HOME_ROWS and MF_LINK_XDG_ROWS
  # force = true: overwrite existing files/symlinks managed by Makefile
  # Note: requires `darwin-rebuild switch` to reflect changes
  # ============================================================================
  home.file = {
    ".zshenv" = { source = "${dotfilesDir}/dot.zshenv"; force = true; };
    ".zshrc" = { source = "${dotfilesDir}/dot.zshrc"; force = true; };
    ".editorconfig" = { source = "${dotfilesDir}/dot.editorconfig"; force = true; };
    ".claude/skills" = { source = "${dotfilesDir}/dot.config/claude/skills"; force = true; };
    ".codex" = { source = "${dotfilesDir}/dot.config/codex"; force = true; };
    ".config/mise/config.toml" = { source = "${dotfilesDir}/mise.toml"; force = true; };
  };

  xdg.configFile = {
    "git" = { source = "${dotfilesDir}/dot.config/git"; force = true; };
    "tmux" = { source = "${dotfilesDir}/dot.config/tmux"; force = true; };
    "wezterm" = { source = "${dotfilesDir}/dot.config/wezterm"; force = true; };
    "efm-langserver" = { source = "${dotfilesDir}/dot.config/efm-langserver"; force = true; };
    "zeno" = { source = "${dotfilesDir}/dot.config/zeno"; force = true; };
    "skk" = { source = "${dotfilesDir}/dot.config/skk"; force = true; };
    "rumdl" = { source = "${dotfilesDir}/dot.config/rumdl"; force = true; };
    "vde" = { source = "${dotfilesDir}/dot.config/vde"; force = true; };
  };

  # ============================================================================
  # Dotfiles (direct symlink via mkOutOfStoreSymlink)
  # For frequently edited files - changes reflect immediately without rebuild
  # ============================================================================
  xdg.configFile = {
    "nvim".source = symlink "${dotfilesDirAbs}/dot.config/nvim";
    "vim".source = symlink "${dotfilesDirAbs}/dot.config/vim";
    "claude".source = symlink "${dotfilesDirAbs}/dot.config/claude";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
