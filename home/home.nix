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
    # Shell (zsh is default on macOS, needs install on Linux)
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    pkgs.zsh
    pkgs.wslu  # WSL utilities (harmless on non-WSL)
  ] ++ [
    # Cloud & Infrastructure
    pkgs.awscli2
    pkgs.databricks-cli
    pkgs.google-cloud-sdk
    pkgs.terraform
    pkgs.tflint
    # Version control (git is managed by programs.git)
    pkgs.gh
    pkgs.ghq
    pkgs.gitleaks
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
    pkgs.rustup
    pkgs.uv
    # Linters & Formatters
    pkgs.actionlint
    pkgs.hadolint
    pkgs.shellcheck
    pkgs.shfmt
    pkgs.stylua
    # CI/CD
    pkgs.act
    pkgs.mise
    pkgs.pre-commit
    # LSP
    pkgs.efm-langserver
    # Editors (latest from neovim-nightly-overlay and vim-overlay)
    pkgs.neovim
    pkgs.vim
    # Build tools
    pkgs.ninja
    pkgs.cmake
    pkgs.gettext
    # NOTE: GUI applications are in darwin/configuration.nix (environment.systemPackages)
    # to appear in /Applications/Nix Apps/
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
    # git is managed by programs.git (config) + core.excludesfile (ignore)
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

  # Git configuration (replaces Makefile git-config target)
  # Note: user.name, user.email are PC-specific, set via `git config --global`
  # They will be written to ~/.gitconfig which takes precedence
  programs.git = {
    enable = true;
    settings = {
      color.ui = "auto";
      commit = {
        gpgsign = true;
        verbose = true;
      };
      core = {
        autocrlf = "input";
        commentChar = ";";
        editor = "vim";
        excludesfile = "${dotfilesDir}/dot.config/git/ignore";
        ignorecase = false;
        pager = "LESSCHARSET=utf-8 less";
        quotepath = false;
        safecrlf = true;
      };
      credential.helper = "store";
      diff = {
        algorithm = "histogram";
        compactionHeuristic = true;
        tool = "vimdiff";
      };
      difftool = {
        prompt = false;
        vimdiff.path = "vim";
      };
      fetch.prune = true;
      ghq.root = "~/ghq";
      gpg.format = "ssh";
      grep.lineNumber = true;
      http.sslVerify = false;
      init.defaultBranch = "main";
      merge = {
        conflictstyle = "diff3";
        tool = "vimdiff";
      };
      mergetool = {
        prompt = false;
        vimdiff.path = "vim";
      };
      push.default = "current";
      user.signingkey = "~/.ssh/github.pub";
    };
  };

  # ============================================================================
  # Activation scripts (run on darwin-rebuild switch / home-manager switch)
  # ============================================================================
  home.activation = let
    npm = "${pkgs.nodejs}/bin/npm";
    npmPrefix = "${homeDir}/.local";
    ghq = "${pkgs.ghq}/bin/ghq";
    git = "${pkgs.git}/bin/git";
    ghqListEssential = "${dotfilesDir}/etc/ghq-list-essential.txt";
    tpmDir = "${dotfilesDir}/dot.config/tmux/plugins/tpm";
  in {
    # 0. Clone essential repositories (ghq-get-essential)
    # Note: ghq requires git in PATH
    ghqGetEssential = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export PATH="${pkgs.git}/bin:$PATH"
      if [ -f "${ghqListEssential}" ]; then
        echo "Cloning essential repositories..."
        ${ghq} get -p < "${ghqListEssential}" || true
      fi
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
      NPM_PACKAGES=(
        "@anthropic-ai/claude-code"
        "@devcontainers/cli"
        "@github/copilot"
        "@google/gemini-cli"
        "@openai/codex"
        "ccusage"
        "vde-layout"
        "zenn-cli"
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
