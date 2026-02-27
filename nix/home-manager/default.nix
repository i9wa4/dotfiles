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
  imports = [
    ./agent-skills.nix
    ./claude-code.nix
    ./codex-cli.nix
    ./editorconfig.nix
    ./efm-langserver.nix
    ./git.nix
    ./lazygit.nix
    ./tmux.nix
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
    stateVersion = "24.11";

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
      # claude-code: managed by claude-code.nix (programs.claude-code)
      # codex: managed by codex-cli.nix (programs.codex)
      pkgs.llm-agents.ccusage
      pkgs.llm-agents.ccusage-codex
      # Development tools
      # pkgs.go
      pkgs.act
      pkgs.alejandra
      pkgs.deno
      pkgs.devcontainer
      pkgs.efm-langserver
      pkgs.fd
      pkgs.fzf
      pkgs.gh
      pkgs.ghq
      pkgs.hadolint
      pkgs.mise
      pkgs.nixd
      pkgs.nodejs
      pkgs.nurl
      pkgs.pyright
      pkgs.python3
      pkgs.ripgrep
      pkgs.rumdl
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.stylua
      pkgs.uv
      # NOTE: GUI applications are managed via Homebrew casks
      # cf. nix/flake-parts/darwin.nix
    ];

    # ==========================================================================
    # Dotfiles (direct symlink via mkOutOfStoreSymlink)
    # Changes reflect immediately without rebuild
    # cf. Makefile MF_LINK_HOME_ROWS and MF_LINK_XDG_ROWS
    # ==========================================================================
    file = {
      # zsh: ~/.zshenv sets ZDOTDIR, so zsh reads ~/.config/zsh/.zshrc
      ".zshenv".source = symlink "${dotfilesDir}/config/zsh/.zshenv";
    };
  };

  xdg.configFile = {
    "nvim".source = symlink "${dotfilesDir}/config/nvim";
    "tmux-a2a-postman".source = symlink "${dotfilesDir}/config/tmux-a2a-postman";
    "skk".source = symlink "${dotfilesDir}/config/skk";
    "vde".source = symlink "${dotfilesDir}/config/vde";
    "vim".source = symlink "${dotfilesDir}/config/vim";
    "wezterm".source = symlink "${dotfilesDir}/config/wezterm";
    "zeno".source = symlink "${dotfilesDir}/config/zeno";
    # zsh: ZDOTDIR points here
    "zsh".source = symlink "${dotfilesDir}/config/zsh";
  };

  # Nix settings (user-level, written to ~/.config/nix/nix.conf)
  # nix.package is required by HM when writing nix.conf
  # mkDefault allows nix-darwin integration to forward its own nix.package without conflict
  nix.package = lib.mkDefault pkgs.nix;
  nix.settings.experimental-features = ["nix-command" "flakes"];

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

    # bash: auto-switch to zsh for environments where zsh is not the login shell
    # (e.g., SSM sessions start with /bin/sh, user types "bash" to bootstrap)
    bash = {
      enable = true;
      initExtra = ''
        # Auto-switch to zsh (SSM sets USER=root, fix it before switching)
        if [ -z "$TMUX" ] && [ -z "$ZSH_VERSION" ] && command -v zsh >/dev/null 2>&1; then
          export USER=$(id -un)
          exec zsh -l
        fi
      '';
    };

    # zsh: disabled - config is in config/zsh/ via ZDOTDIR (home.file.".zshenv")
    # zsh package is installed via ubuntu.nix on Linux, nix-darwin programs.zsh on macOS
    zsh.enable = false;
  };

  # ============================================================================
  # Activation scripts (run on darwin-rebuild switch / home-manager switch)
  # ============================================================================
  home.activation = let
    npm = "${pkgs.nodejs}/bin/npm";
    npmPrefix = "${homeDir}/.local";
  in {
    # 0. Clean temporary files (node caches for security)
    cleanTemporaryFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Cleaning temporary files..."
      # Node.js caches
      rm -rf "${homeDir}/.npm"
    '';

    # 1. Install/update safe-chain first (security scanner for npm)
    setupSafeChain = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${npmPrefix}
      export PATH="${npmPrefix}/bin:${pkgs.nodejs}/bin:$PATH"
      if ! ${npm} --prefix ${npmPrefix} list -g --depth=0 @aikidosec/safe-chain >/dev/null 2>&1; then
        echo "Installing @aikidosec/safe-chain..."
        ${npm} --prefix ${npmPrefix} install -g @aikidosec/safe-chain
        safe-chain setup
      else
        echo "Updating @aikidosec/safe-chain..."
        ${npm} --prefix ${npmPrefix} update -g @aikidosec/safe-chain
      fi
    '';

    # 2. Install/update npm packages (after safe-chain, so they get scanned)
    installNpmPackages = lib.hm.dag.entryAfter ["setupSafeChain"] ''
      export PATH="${npmPrefix}/bin:${pkgs.nodejs}/bin:$PATH"
      NPM_PACKAGES=(
        "vde-layout"
        "vde-monitor"
        "vde-worktree"
      )

      # Install missing packages
      for pkg in "''${NPM_PACKAGES[@]}"; do
        if ! ${npm} --prefix ${npmPrefix} list -g --depth=0 "$pkg" >/dev/null 2>&1; then
          echo "Installing $pkg..."
          ${npm} --prefix ${npmPrefix} install -g "$pkg"
        fi
      done

      # Update outdated packages in one batch
      outdated=$(${npm} --prefix ${npmPrefix} outdated -g --parseable --depth=0 2>/dev/null | cut -d: -f4 || true)
      if [ -n "$outdated" ]; then
        echo "Updating outdated packages: $outdated"
        echo "$outdated" | xargs ${npm} --prefix ${npmPrefix} install -g
      fi

      # Remove unlisted packages (keep npm, corepack, safe-chain)
      # --parseable gives paths like .../node_modules/pkg or .../node_modules/@scope/pkg
      # Extract package name by stripping the node_modules prefix
      node_modules="${npmPrefix}/lib/node_modules"
      installed=$(${npm} --prefix ${npmPrefix} list -g --depth=0 --parseable 2>/dev/null | tail -n +2 || true)
      for pkg_path in $installed; do
        pkg="''${pkg_path#"$node_modules"/}"
        case "$pkg" in
          npm|corepack|@aikidosec/*) continue ;;
        esac
        found=0
        for want in "''${NPM_PACKAGES[@]}"; do
          if [ "$pkg" = "$want" ]; then found=1; break; fi
        done
        if [ "$found" = "0" ]; then
          echo "Removing unlisted package: $pkg"
          ${npm} --prefix ${npmPrefix} uninstall -g "$pkg"
        fi
      done
    '';
  };
}
