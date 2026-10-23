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
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  homeDir = if isDarwin then "/Users/${username}" else "/home/${username}";
  ghqRoot = "${homeDir}/ghq"; # cf. git config --global ghq.root
  dotfilesDir = "${ghqRoot}/github.com/i9wa4/dotfiles";

  # Direct symlink (not via Nix store) - changes reflect immediately
  symlink = config.lib.file.mkOutOfStoreSymlink;
  # Use pinned nixpkgs pnpm and its own Node runtime to avoid a separate Node package.
  pnpmPackage = pkgs.pnpm;
  system = pkgs.stdenv.hostPlatform.system;

  # Local workaround for the pinned CA data, matching nix-darwin's distrust
  # policy without a global overlay. NSS >=3.131.1 removes ECC G3 upstream.
  # Retain AAA while its label exists; revisit/remove this override when an
  # upstream bundle excludes these trust paths and fingerprint checks pass.
  clientCa = pkgs.cacert.override (previous: {
    blacklist = lib.unique (
      (previous.blacklist or [ ])
      ++ [ "Comodo AAA Services root" ]
      ++ lib.optional (lib.versionOlder pkgs.cacert.version "3.131.1") "emSign ECC Root CA - G3"
    );
  });
  # The extended bundle/hashed output also carries rejected trust records;
  # use the TLS-only PEM so consumers cannot discard their rejection metadata.
  clientCaBundle = "${clientCa}/etc/ssl/certs/ca-no-trust-rules-bundle.crt";
  # Build-time guard: the build fails if the filtered bundle holds a published
  # eMudhra fingerprint or is empty, truncated or malformed. The guard's own
  # fixtures run first, so a broken guard fails the build instead of passing.
  guardPython = pkgs.python3.withPackages (ps: [ ps.cryptography ]);
  clientCaChecked = pkgs.runCommand "client-ca-checked" { nativeBuildInputs = [ guardPython ]; } ''
    python3 ${./scripts/check-client-ca-test.py} ${./scripts/check-client-ca.py}
    python3 ${./scripts/check-client-ca.py} ${clientCaBundle}
    install -D ${clientCaBundle} $out/etc/ssl/certs/ca-no-trust-rules-bundle.crt
  '';
  clientCaFile = "${clientCaChecked}/etc/ssl/certs/ca-no-trust-rules-bundle.crt";
  clientCaDir = pkgs.emptyDirectory;
  # Routing workaround: Node and uv still select bundled roots. Revisit these
  # entrypoints/session defaults only after actual Node, Python, Nix and uv
  # checks use mitigated stores without them; a data update alone is insufficient.
  clientNode = pkgs.writeShellScript "node" ''
    exec ${pnpmPackage.nodejs-slim}/bin/node --use-openssl-ca "$@"
  '';

  # Keep uv's generic CA file set to the filtered bundle even in a process that
  # lacks the session SSL_CERT_FILE. Descendants inherit it; a deliberate
  # empty/nonempty override and argv are kept.
  clientUv = pkgs.symlinkJoin {
    name = "uv-filtered-ca-${pkgs.uv.version}";
    paths = [ pkgs.uv ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/uv" \
        --run 'if [ "''${SSL_CERT_FILE+x}" != x ]; then export SSL_CERT_FILE="''${NIX_SSL_CERT_FILE-}"; fi'
    '';
  };

  # AI agent CLIs from llm-agents.nix flake input
  # (uses upstream nixpkgs pin to match cache.numtide.com binaries)
  llmAgents = inputs.llm-agents.packages.${system};
  markdownFormatter = inputs.markdown-formatter.packages.${system}.default;
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
      pnpmPackage
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
      "${dotfilesDir}/scripts/bin"
    ];

    # Darwin user-session defaults only; Linux retains its existing trust policy.
    # NIX_SSL_CERT_FILE feeds Nix OpenSSL/certifi. SSL_CERT_FILE gives the same
    # checked bundle to file-based consumers: Apple curl (observed to honor it),
    # Go clients such as gh, and uv. Apple curl would otherwise read the system
    # /etc/ssl/cert.pem, which still holds the compromised eMudhra roots.
    # SSL_CERT_DIR stays the empty directory so OpenSSL consumers cannot merge a
    # second default store. Never set SSL_CERT_DIR without SSL_CERT_FILE: gh failed
    # TLS verification with the empty directory alone (issue #472).
    # The first login-shell init exports these unconditionally and replaces an
    # inherited value; nested shells keep what they inherited; a per-command
    # `SSL_CERT_FILE=<path> cmd` or `env -u SSL_CERT_FILE cmd` always wins.
    # Replace the file variables together. Not covered: Apple git, python3, perl,
    # ruby, openssl and processes that never source this file (launchd, GUI, cron,
    # sudo, `env -i`). Keychain-only enterprise roots are not honored by
    # SSL_CERT_FILE consumers.
    sessionVariables = lib.optionalAttrs isDarwin {
      NIX_SSL_CERT_FILE = clientCaFile;
      SSL_CERT_FILE = clientCaFile;
      SSL_CERT_DIR = clientCaDir;
    };

    # User packages (managed by home-manager)
    # For project-specific tools, use devShell or mise instead
    packages = [
      # System
      pkgs.gnumake
      pkgs.wget
      # nixpkgs
      (pkgs.python3.withPackages (ps: [ ps.pynvim ]))
      pkgs.acli
      pkgs.awscli2
      pkgs.azure-cli
      pkgs.databricks-cli
      pkgs.fd
      pkgs.fzf
      pkgs.ghq
      pkgs.google-cloud-sdk
      pkgs.gws
      pkgs.harper
      pkgs.jq
      pkgs.neovim
      pkgs.nixd
      pkgs.ripgrep
      pkgs.rumdl
      pkgs.shellcheck
      pkgs.tirith
      pkgs.tmux
      (if isDarwin then clientUv else pkgs.uv)
      pkgs.vale
      pkgs.vim
      pkgs.zoxide
      # Other Tools
      markdownFormatter
      pnpmPackage
      tmuxA2aPostman
      wazaPackage
      # AI agent CLIs (versions tracked by flake.lock; was previously installed via nix profile)
      # ccusage includes Codex usage subcommands.
      # Antigravity exposes the `agy` command.
      llmAgents.antigravity-cli
      llmAgents.ccusage
      llmAgents.claude-code
      llmAgents.codex
      llmAgents.herdr
    ]
    ++ lib.optionals (!isDarwin) [
      pkgs.mise
      pkgs.podman
      pkgs.podman-compose
    ];

    # ==========================================================================
    # Dotfiles (direct symlink via mkOutOfStoreSymlink)
    # Changes reflect immediately without rebuild
    # cf. Makefile MF_LINK_HOME_ROWS and MF_LINK_XDG_ROWS
    # ==========================================================================
    file = {
      ".vale.ini".source = symlink "${dotfilesDir}/config/vale/.vale.ini";
      # pnpm global shims look for ~/.local/bin/node before falling back to PATH.
      # Expose pnpm's own Node runtime without adding a separate Node package.
      ".local/bin/node".source = if isDarwin then clientNode else "${pnpmPackage.nodejs-slim}/bin/node";
    };
  };

  home.activation.setupEnvrc = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [[ -f "${dotfilesDir}/.envrc" ]] || echo 'use flake' | tee "${dotfilesDir}/.envrc" >/dev/null
  '';

  xdg.configFile = {
    # symlink
    "kitty".source = symlink "${dotfilesDir}/config/kitty";
    "nvim".source = symlink "${dotfilesDir}/config/nvim/nvim";
    "tmux".source = symlink "${dotfilesDir}/config/tmux";
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

    # nh: unified Nix helper. On Linux/WSL, run a weekly user-profile cleanup
    # with a conservative retention window. Darwin keeps the existing
    # nix-darwin system GC; Home Manager's nh launchd wrapper passes
    # extraArgs as one argument, so avoid enabling scheduled clean there.
    nh = {
      enable = true;
      clean = {
        enable = !isDarwin;
        dates = "weekly";
        extraArgs = "--keep-since 30d --keep-one";
      };
    };

    # direnv (auto-activate devShell when cd into project)
    # Note: zsh hook is loaded manually in modules/zsh.nix.
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = false; # Handled manually in modules/zsh.nix
    };
  };
}
