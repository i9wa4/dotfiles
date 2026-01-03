{
  pkgs,
  lib,
  config,
  username,
  ...
}: let
  # Platform-agnostic paths
  homeDir =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  ghqRoot = "${homeDir}/ghq"; # cf. git config --global ghq.root
  dotfilesDir = "${ghqRoot}/github.com/i9wa4/dotfiles";

  # Direct symlink (not via Nix store) - changes reflect immediately
  symlink = config.lib.file.mkOutOfStoreSymlink;
in {
  # User info (username is passed from flake.nix via extraSpecialArgs)
  home.username = username;
  home.homeDirectory = lib.mkForce homeDir;

  # Home Manager state version
  # Set to the version of home-manager at initial installation. Do not change.
  # cf. https://nix-community.github.io/home-manager/options.xhtml#opt-home.stateVersion
  home.stateVersion = "24.11";

  # User packages (managed by home-manager)
  # For project-specific tools, use devShell or mise instead
  home.packages = [
    # Version control
    pkgs.git
    pkgs.gh
    pkgs.ghq
    # Search
    pkgs.ripgrep
    pkgs.fd
    pkgs.fzf
    # File viewers
    pkgs.bat
    pkgs.jq
    pkgs.yq-go
    # Terminal
    pkgs.tmux
    # System
    pkgs.htop
    pkgs.wget
    pkgs.fastfetch
  ];

  # ============================================================================
  # Dotfiles (direct symlink via mkOutOfStoreSymlink)
  # Changes reflect immediately without rebuild
  # cf. Makefile MF_LINK_HOME_ROWS and MF_LINK_XDG_ROWS
  # ============================================================================
  home.file = {
    ".claude/skills".source           = symlink "${dotfilesDir}/dot.config/claude/skills";
    ".codex".source                   = symlink "${dotfilesDir}/dot.config/codex";
    ".config/mise/config.toml".source = symlink "${dotfilesDir}/mise.toml";
    ".editorconfig".source            = symlink "${dotfilesDir}/dot.editorconfig";
    ".zshenv".source                  = symlink "${dotfilesDir}/dot.zshenv";
    ".zshrc".source                   = symlink "${dotfilesDir}/dot.zshrc";
  };

  xdg.configFile = {
    "claude".source         = symlink "${dotfilesDir}/dot.config/claude";
    "efm-langserver".source = symlink "${dotfilesDir}/dot.config/efm-langserver";
    "git".source            = symlink "${dotfilesDir}/dot.config/git";
    "nvim".source           = symlink "${dotfilesDir}/dot.config/nvim";
    "rumdl".source          = symlink "${dotfilesDir}/dot.config/rumdl";
    "skk".source            = symlink "${dotfilesDir}/dot.config/skk";
    "tmux".source           = symlink "${dotfilesDir}/dot.config/tmux";
    "vde".source            = symlink "${dotfilesDir}/dot.config/vde";
    "vim".source            = symlink "${dotfilesDir}/dot.config/vim";
    "wezterm".source        = symlink "${dotfilesDir}/dot.config/wezterm";
    "zeno".source           = symlink "${dotfilesDir}/dot.config/zeno";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # direnv (auto-activate devShell when cd into project)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
