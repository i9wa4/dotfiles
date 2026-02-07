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
    ./codex.nix
    ./editorconfig.nix
    ./git.nix
    ./vscode.nix
  ];
  home = {
    # User info (username is passed from flake.nix via extraSpecialArgs)
    inherit username;
    homeDirectory = lib.mkForce homeDir;

    # Home Manager state version
    # Set to the version of home-manager at initial installation. Do not change.
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
    packages =
      lib.optionals pkgs.stdenv.isLinux [
        pkgs.zsh
        pkgs.wslu # WSL utilities (harmless on non-WSL)
      ]
      ++ [
        # Cloud & Infrastructure
        pkgs.acli # Atlassian CLI
        pkgs.awscli2
        pkgs.databricks-cli
        pkgs.google-cloud-sdk
        pkgs.terraform
        pkgs.tflint
        # Version control (git is managed by programs.git)
        pkgs.gh
        pkgs.ghq
        pkgs.lazygit
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
        pkgs.hyperfine
        # Language runtimes
        pkgs.deno
        pkgs.go
        pkgs.nodejs
        pkgs.python3
        pkgs.rustup
        pkgs.uv
        # Linters & Formatters
        pkgs.alejandra
        pkgs.hadolint
        pkgs.shellcheck
        pkgs.shfmt
        pkgs.statix
        pkgs.stylua
        pkgs.zizmor
        # Nix development
        pkgs.nurl
        # CI/CD
        pkgs.act
        pkgs.actionlint
        pkgs.gitleaks
        pkgs.mise
        pkgs.ghalint
        pkgs.ghatm
        pkgs.pinact
        pkgs.rumdl
        # NOTE: pre-commit is managed via `uv run pre-commit` to avoid Swift build dependency
        # LSP
        pkgs.efm-langserver
        pkgs.nixd
        pkgs.pyright
        # Editors (latest from neovim-nightly-overlay and vim-overlay)
        pkgs.neovim
        pkgs.vim
        pkgs.vim-startuptime
        # Neovim build dependencies
        pkgs.ninja
        pkgs.cmake
        pkgs.gettext
        pkgs.gnumake
        # NOTE: GUI applications are managed via Homebrew casks
        # cf. nix/hosts/<name>/casks.nix
        # NOTE: AI coding agents are managed via nix profile
        # cf. Makefile nix-profile-add
      ];

    # ==========================================================================
    # Dotfiles (direct symlink via mkOutOfStoreSymlink)
    # Changes reflect immediately without rebuild
    # cf. Makefile MF_LINK_HOME_ROWS and MF_LINK_XDG_ROWS
    # ==========================================================================
    file = {
      # .claude/skills is managed by agent-skills.nix
      # .codex/skills is managed by agent-skills.nix
      # .codex is symlinked to config/codex via xdg.configFile or manual setup
      # zsh: ~/.zshenv sets ZDOTDIR, so zsh reads ~/.config/zsh/.zshrc
      ".zshenv".source = symlink "${dotfilesDir}/config/zsh/.zshenv";
    };
  };

  xdg.configFile = {
    "claude".source = symlink "${dotfilesDir}/config/claude";
    "efm-langserver".source = symlink "${dotfilesDir}/config/efm-langserver";
    "lazygit".source = symlink "${dotfilesDir}/config/lazygit";
    "nvim".source = symlink "${dotfilesDir}/config/nvim";
    "postman".source = symlink "${dotfilesDir}/config/postman";
    "rumdl/rumdl.toml".source = symlink "${dotfilesDir}/.rumdl.toml";
    "skk".source = symlink "${dotfilesDir}/config/skk";
    "tmux".source = symlink "${dotfilesDir}/config/tmux";
    "vde".source = symlink "${dotfilesDir}/config/vde";
    "vim".source = symlink "${dotfilesDir}/config/vim";
    "wezterm".source = symlink "${dotfilesDir}/config/wezterm";
    "zeno".source = symlink "${dotfilesDir}/config/zeno";
    # zsh: ZDOTDIR points here
    "zsh".source = symlink "${dotfilesDir}/config/zsh";
  };

  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;

    # direnv (auto-activate devShell when cd into project)
    # Note: zsh hook is handled by zinit turbo mode for faster startup
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = false; # Handled by zinit turbo
    };

    # zsh: disabled - config is in config/zsh/ via ZDOTDIR (home.file.".zshenv")
    # zsh package is installed via home.packages on Linux, system-wide on macOS
    zsh.enable = false;
  };

  # ============================================================================
  # Activation scripts (run on darwin-rebuild switch / home-manager switch)
  # ============================================================================
  home.activation = let
    npm = "${pkgs.nodejs}/bin/npm";
    npmPrefix = "${homeDir}/.local";
    git = "${pkgs.git}/bin/git";
    fd = "${pkgs.fd}/bin/fd";
    tpmDir = "${dotfilesDir}/config/tmux/plugins/tpm";
  in {
    # 0. Clean temporary files (node caches for security)
    cleanTemporaryFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Cleaning temporary files..."
      # Node.js caches
      rm -rf "${homeDir}/.npm"
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        rm -rf "${homeDir}/Library/Caches/deno"
        ${fd} ".DS_Store" ${ghqRoot} --hidden --no-ignore | xargs rm -f || true
        ${fd} . ${ghqRoot} -t f --exclude ".git" -x /usr/bin/xattr -c {} \; || true
      ''}
    '';

    # 0. Clone tmux plugin manager (tpm)
    cloneTpm = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export PATH="${pkgs.git}/bin:$PATH"
      if [ ! -d "${tpmDir}" ]; then
        echo "Cloning tmux plugin manager..."
        ${git} clone https://github.com/tmux-plugins/tpm "${tpmDir}"
      fi
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

    # 2. Start ssh-agent if not running (Linux only)
    # cf. https://inno-tech-life.com/dev/infra/wsl2-ssh-agent/
    startSshAgent = lib.hm.dag.entryAfter ["writeBoundary"] (
      lib.optionalString pkgs.stdenv.isLinux ''
        if [ -z "$SSH_AUTH_SOCK" ]; then
          eval $(${pkgs.openssh}/bin/ssh-agent)
        fi
      ''
    );

    # 3. Install/update npm packages (after safe-chain, so they get scanned)
    installNpmPackages = lib.hm.dag.entryAfter ["setupSafeChain"] ''
      export PATH="${npmPrefix}/bin:${pkgs.nodejs}/bin:$PATH"
      # AI tools moved to Nix: claude-code, ccusage, codex, copilot, gemini-cli
      NPM_PACKAGES=(
        "@devcontainers/cli"
        "gtop"
        "vde-layout"
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
    '';
  };
}
