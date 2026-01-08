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

  # Custom packages (not in nixpkgs) - all packages from nix/packages/
  customPkgs = {
    ghalint = pkgs.callPackage ./packages/ghalint.nix {};
    ghatm = pkgs.callPackage ./packages/ghatm.nix {};
    pike = pkgs.callPackage ./packages/pike.nix {};
    pinact = pkgs.callPackage ./packages/pinact.nix {};
    rumdl = pkgs.callPackage ./packages/rumdl.nix {};
    vim-startuptime = pkgs.callPackage ./packages/vim-startuptime.nix {};
  };
in {
  imports = [
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
        pkgs.awscli2
        pkgs.databricks-cli
        pkgs.google-cloud-sdk
        pkgs.terraform
        pkgs.tflint
        # Version control (git is managed by programs.git)
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
        pkgs.pre-commit
        # LSP
        pkgs.efm-langserver
        pkgs.nixd
        # Editors (latest from neovim-nightly-overlay and vim-overlay)
        pkgs.neovim
        pkgs.vim
        # Build tools
        pkgs.ninja
        pkgs.cmake
        pkgs.gettext
        pkgs.gnumake
        # NOTE: GUI applications are in nix/darwin.nix (environment.systemPackages)
        # to appear in /Applications/Nix Apps/
      ]
      # Custom packages
      ++ [
        (lib.lowPrio customPkgs.ghalint) # pinact優先 (両方にgen-jsonschemaがある)
        customPkgs.ghatm
        customPkgs.pike
        customPkgs.pinact
        customPkgs.rumdl
        customPkgs.vim-startuptime
      ];

    # ==========================================================================
    # Dotfiles (direct symlink via mkOutOfStoreSymlink)
    # Changes reflect immediately without rebuild
    # cf. Makefile MF_LINK_HOME_ROWS and MF_LINK_XDG_ROWS
    # ==========================================================================
    file = {
      ".claude/skills".source = symlink "${dotfilesDir}/dot.config/claude/skills";
      ".codex".source = symlink "${dotfilesDir}/dot.config/codex";
      ".zshenv".source = symlink "${dotfilesDir}/dot.zshenv";
      ".zshrc".source = symlink "${dotfilesDir}/dot.zshrc";
    };
  };

  xdg.configFile = {
    "claude".source = symlink "${dotfilesDir}/dot.config/claude";
    "efm-langserver".source = symlink "${dotfilesDir}/dot.config/efm-langserver";
    "nvim".source = symlink "${dotfilesDir}/dot.config/nvim";
    "rumdl/rumdl.toml".source = symlink "${dotfilesDir}/.rumdl.toml";
    "skk".source = symlink "${dotfilesDir}/dot.config/skk";
    "tmux".source = symlink "${dotfilesDir}/dot.config/tmux";
    "vde".source = symlink "${dotfilesDir}/dot.config/vde";
    "vim".source = symlink "${dotfilesDir}/dot.config/vim";
    "wezterm".source = symlink "${dotfilesDir}/dot.config/wezterm";
    "zeno".source = symlink "${dotfilesDir}/dot.config/zeno";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # direnv (auto-activate devShell when cd into project)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ============================================================================
  # Activation scripts (run on darwin-rebuild switch / home-manager switch)
  # ============================================================================
  home.activation = let
    npm = "${pkgs.nodejs}/bin/npm";
    npmPrefix = "${homeDir}/.local";
    ghq = "${pkgs.ghq}/bin/ghq";
    git = "${pkgs.git}/bin/git";
    ghqListEssential = "${dotfilesDir}/nix/ghq-list-essential.txt";
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

    # TODO: is this needed?
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
