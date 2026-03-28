{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  username,
  inputs,
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
    ./modules/git.nix
    ./modules/gh.nix
    ./modules/lazygit.nix
    ./modules/zsh.nix
    # xdg.configFile
    ./modules/editorconfig.nix
    ./modules/efm-langserver.nix
    # home.file
    ./modules/tmux.nix
    # home.activation
    ./modules/npm.nix
    # AI agent tools
    ./agents/agent-skills.nix
    ./agents/claude-code.nix
    ./agents/codex-cli.nix
  ];
  # Use ~/.config/ instead of ~/Library/Application Support/ on macOS
  xdg.enable = true;

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
      # Tools
      (pkgs.python3.withPackages (ps: [ ps.pynvim ]))
      pkgs-unstable.acli
      pkgs-unstable.azure-cli
      pkgs-unstable.gws
      pkgs-unstable.rumdl
      pkgs.awscli2
      pkgs-unstable.aws-sam-cli
      pkgs.databricks-cli
      pkgs.deno
      pkgs.efm-langserver
      pkgs.fd
      pkgs.fzf
      pkgs.ghq
      pkgs.google-cloud-sdk
      pkgs.jq
      pkgs.mise
      pkgs.neovim
      pkgs.nixd
      pkgs.nodejs
      pkgs.ripgrep
      pkgs.shellcheck
      pkgs.uv
      pkgs.vim
      # llm-agents
      inputs.llm-agents.packages.${pkgs.system}.claude-code
      inputs.llm-agents.packages.${pkgs.system}.codex
      inputs.llm-agents.packages.${pkgs.system}.ccusage
      inputs.llm-agents.packages.${pkgs.system}.ccusage-codex
      # GitHub
      inputs.claude-chill.packages.${pkgs.system}.default
      inputs.tmux-a2a-postman.packages.${pkgs.system}.default
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
    "nvim".source = symlink "${dotfilesDir}/config/nvim/nvim";
    "nvim-as-fileviewer".source = symlink "${dotfilesDir}/config/nvim/nvim-as-fileviewer";
    "tmux-a2a-postman".source = symlink "${dotfilesDir}/config/tmux-a2a-postman";
    "vde".source = symlink "${dotfilesDir}/config/vde";
    "vim".source = symlink "${dotfilesDir}/config/vim";
    "ghostty".source = symlink "${dotfilesDir}/config/ghostty";
    "kitty".source = symlink "${dotfilesDir}/config/kitty";
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
