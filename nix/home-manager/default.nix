{
  pkgs,
  lib,
  config,
  username,
  ...
}:
let
  # Platform-agnostic paths
  homeDir = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
  ghqRoot = "${homeDir}/ghq"; # cf. git config --global ghq.root
  dotfilesDir = "${ghqRoot}/github.com/i9wa4/dotfiles";

  # Direct symlink (not via Nix store) - changes reflect immediately
  symlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [
    # programs.*
    ./modules/bash.nix
    ./modules/claude-code.nix
    ./modules/codex-cli.nix
    ./modules/git.nix
    ./modules/lazygit.nix
    ./modules/zsh.nix
    # xdg.configFile
    ./modules/editorconfig.nix
    ./modules/efm-langserver.nix
    # home.file
    ./modules/agent-skills.nix
    ./modules/tmux.nix
    # home.activation
    ./modules/npm.nix
  ];
  home = {
    # User info (username is passed from flake.nix via extraSpecialArgs)
    inherit username;
    homeDirectory = lib.mkForce homeDir;

    # Suppress version mismatch warning (HM unstable + stable nixpkgs)
    enableNixpkgsReleaseCheck = false;

    # Home Manager state version
    # Set to the version of home-manager at initial installation. Do not change.
    # NOTE: This is NOT the home-manager release version. It controls internal
    # migration behavior. Bumping it can trigger unexpected state changes.
    # cf. https://nix-community.github.io/home-manager/options.xhtml#opt-home.stateVersion
    stateVersion = "25.11";

    # PATH additions (prepended to $PATH)
    # cf. https://nix-community.github.io/home-manager/options.xhtml#opt-home.sessionPath
    sessionPath = [
      "${homeDir}/.local/bin"
      "${dotfilesDir}/bin"
    ];

    # User packages (managed by home-manager)
    # For project-specific tools, use devShell or mise instead
    packages = [
      # System
      pkgs.tailscale
      pkgs.wget
      # Cloud & Infrastructure
      pkgs.awscli2
      pkgs.databricks-cli
      pkgs.google-cloud-sdk
      pkgs.terraform
      # Editors
      pkgs.neovim
      pkgs.vim
      # AI coding agent tools
      # claude-code: externally managed (see claude-code.nix for config)
      # codex: externally managed (see codex-cli.nix for config)
      pkgs.llm-agents.ccusage
      pkgs.llm-agents.ccusage-codex
      # Development tools
      (pkgs.python3.withPackages (ps: [ ps.pynvim ]))
      pkgs.deno
      pkgs.efm-langserver
      pkgs.fd
      pkgs.fzf
      pkgs.gh
      pkgs.ghq
      pkgs.go
      pkgs.hadolint
      pkgs.mise
      pkgs.nixd
      pkgs.nixfmt-rfc-style
      pkgs.nodejs
      pkgs.nurl
      pkgs.pyright
      pkgs.ripgrep
      pkgs.rumdl
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.stylua
      pkgs.uv
    ];

    # ==========================================================================
    # Dotfiles (direct symlink via mkOutOfStoreSymlink)
    # Changes reflect immediately without rebuild
    # cf. Makefile MF_LINK_HOME_ROWS and MF_LINK_XDG_ROWS
    # ==========================================================================
    file = {
    };
  };

  home.activation.setupEnvrc = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [[ -f "${dotfilesDir}/.envrc" ]] || echo 'use flake' | tee "${dotfilesDir}/.envrc" >/dev/null
  '';

  xdg.configFile = {
    # symlink
    "nvim".source = symlink "${dotfilesDir}/config/nvim";
    "tmux-a2a-postman".source = symlink "${dotfilesDir}/config/tmux-a2a-postman";
    "vde".source = symlink "${dotfilesDir}/config/vde";
    "vim".source = symlink "${dotfilesDir}/config/vim";
    "zeno".source = symlink "${dotfilesDir}/config/zeno";
    # Nix store
    "wezterm".source = ../../config/wezterm;
  };

  # Nix settings (user-level, written to ~/.config/nix/nix.conf)
  # nix.package is required by HM when writing nix.conf
  # mkDefault allows nix-darwin integration to forward its own nix.package without conflict
  nix.package = lib.mkDefault pkgs.nix;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;

    # nix-index-database: comma (run uninstalled commands via nix-index)
    nix-index-database.comma.enable = true;

    # direnv (auto-activate devShell when cd into project)
    # Note: zsh hook is handled by zinit turbo mode for faster startup
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = false; # Handled by zinit turbo
    };
  };
}

