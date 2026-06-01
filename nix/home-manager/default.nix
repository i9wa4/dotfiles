{
  pkgs,
  inputs,
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
  nodejsPackage = pkgs.nodejs_24;
  system = pkgs.stdenv.hostPlatform.system;

  # AI agent CLIs from llm-agents.nix flake input
  # (uses upstream nixpkgs pin to match cache.numtide.com binaries)
  llmAgents = inputs.llm-agents.packages.${system};
  markdownFormatter = inputs.markdown-formatter.packages.${system}.default;
  markdownRemoteViewer = inputs.markdown-remote-viewer.packages.${system}.default;
  tmuxA2aPostman = inputs.tmux-a2a-postman.packages.${system}.default;
  wazaPackage = pkgs.callPackage ../packages/waza.nix {
    inherit system;
  };

in
{
  _module.args = {
    inherit
      dotfilesDir
      ghqRoot
      homeDir
      nodejsPackage
      ;
  };

  imports = [
    # programs.*
    ./modules/bash.nix
    ./modules/git.nix
    ./modules/gh.nix
    ./modules/lazygit.nix
    ./modules/zsh.nix
    # xdg.configFile
    ./modules/editorconfig.nix
    # home.file
    ./modules/tmux.nix
    # home.activation
    ./modules/pnpm.nix
    # AI agent tools
    ./agents
  ];
  # Use ~/.config/ instead of ~/Library/Application Support/ on macOS
  xdg.enable = true;

  home = {
    # User info (username is passed from flake.nix via extraSpecialArgs)
    inherit username;
    homeDirectory = lib.mkForce homeDir;
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
      pkgs.gnumake
      pkgs.tailscale
      pkgs.wget
      # Tools
      (pkgs.python3.withPackages (ps: [ ps.pynvim ]))
      nodejsPackage
      pkgs.acli
      pkgs.databricks-cli
      pkgs.gws
      pkgs.rumdl
      pkgs.awscli2
      pkgs.azure-cli
      pkgs.fd
      pkgs.fzf
      pkgs.ghq
      pkgs.google-cloud-sdk
      pkgs.jq
      pkgs.harper
      markdownFormatter
      markdownRemoteViewer
      pkgs.mise
      pkgs.neovim
      pkgs.nixd
      pkgs.pnpm
      pkgs.ripgrep
      pkgs.shellcheck
      tmuxA2aPostman
      pkgs.uv
      pkgs.vale
      pkgs.vim
      wazaPackage
      pkgs.zoxide
      # AI agent CLIs (versions tracked by flake.lock; was previously installed via nix profile)
      # ccusage includes Codex usage subcommands.
      # Antigravity exposes the `agy` command.
      llmAgents.antigravity-cli
      llmAgents.ccusage
      llmAgents.claude-code
      llmAgents.codex
    ];

    # ==========================================================================
    # Dotfiles (direct symlink via mkOutOfStoreSymlink)
    # Changes reflect immediately without rebuild
    # cf. Makefile MF_LINK_HOME_ROWS and MF_LINK_XDG_ROWS
    # ==========================================================================
    file = {
      ".vale.ini".source = symlink "${dotfilesDir}/config/vale/.vale.ini";
    };
  };

  home.activation.setupEnvrc = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [[ -f "${dotfilesDir}/.envrc" ]] || echo 'use flake' | tee "${dotfilesDir}/.envrc" >/dev/null
  '';

  xdg.configFile = {
    # symlink
    "kitty".source = symlink "${dotfilesDir}/config/kitty";
    "nvim".source = symlink "${dotfilesDir}/config/nvim/nvim";
    "tmux-a2a-postman".source = symlink "${dotfilesDir}/config/tmux-a2a-postman";
    "vde".source = symlink "${dotfilesDir}/config/vde";
    "vim".source = symlink "${dotfilesDir}/config/vim";
    # Nix store
    # "kitty".source = ../../config/kitty;
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
    # Note: zsh hook is loaded manually in modules/zsh.nix.
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = false; # Handled manually in modules/zsh.nix
    };
  };
}
