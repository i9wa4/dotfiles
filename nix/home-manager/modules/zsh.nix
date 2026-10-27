# Zsh configuration (managed by home-manager programs.zsh)
# Replaces config/zsh/.zshenv, .zshrc
# Modular source files remain in config/zsh/
{
  pkgs,
  lib,
  config,
  dotfilesDir,
  ...
}:
let
  zshDir = "${dotfilesDir}/config/zsh";
in
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    # compinit is owned by config/zsh/completion.zsh to avoid double initialization.
    completionInit = "";

    # ========================================================================
    # .zshenv (envExtra)
    # ========================================================================
    envExtra = lib.concatStringsSep "\n" [
      # System
      ''
        export EDITOR=nvim
        export VISUAL=nvim
        export TZ="Asia/Tokyo"
      ''

      # locale
      ''
        if locale -a 2>/dev/null | grep -q "en_US.UTF-8"; then
          export LC_ALL=en_US.UTF-8
        else
          export LC_ALL=C.UTF-8
        fi
      ''

      # Platform-specific PATH recovery
      (
        if pkgs.stdenv.hostPlatform.isDarwin then
          ''
            # Nix PATH recovery (in case macOS update overwrites /etc/zshenv)
            if [ -z "''${__NIX_DARWIN_SET_ENVIRONMENT_DONE-}" ]; then
              if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
              fi
            fi

            # Home Manager's sourced marker can outlive one of its CA variables
            # in an inherited shell (for example, a tmux pane). Keep the
            # filtered bundle paired with the intentionally empty CA directory.
            if [[ "''${SSL_CERT_DIR-}" == ${lib.escapeShellArg config.home.sessionVariables.SSL_CERT_DIR} \
              && -z "''${SSL_CERT_FILE-}" ]]; then
              export SSL_CERT_FILE=${lib.escapeShellArg config.home.sessionVariables.SSL_CERT_FILE}
            fi
          ''
        else
          ''
            # Home-manager session variables (standalone HM without nix-darwin)
            if [ -f "/etc/profiles/per-user/''${USER}/etc/profile.d/hm-session-vars.sh" ]; then
              source "/etc/profiles/per-user/''${USER}/etc/profile.d/hm-session-vars.sh"
            fi
          ''
      )

      # PATH deduplication (prevents duplicates in nested shells, e.g. tmux)
      ''
        typeset -U path PATH
      ''

      # Platform-specific PATH additions
      ''
        # Linux snap
        if [[ -d /snap/bin ]]; then
          export PATH="''${PATH}":/snap/bin
        fi

        # macOS Homebrew
        if [[ -d /opt/homebrew ]]; then
          export PATH=/opt/homebrew/bin:"''${PATH}"
        fi
      ''

      # Application Settings
      ''
        # Claude
        export CLAUDE_CONFIG_DIR="''${HOME}"/.claude

        # Codex
        export CODEX_HOME="''${HOME}"/.codex

        # fzf
        export FZF_DEFAULT_OPTS="--reverse --bind 'ctrl-y:accept'"

        # Neovim
        export NVIM_APPNAME=nvim

        # Nix
        export NIXPKGS_ALLOW_UNFREE=1

        # Python
        export PIP_REQUIRE_VIRTUALENV=1
      ''

      # Local config (machine-specific, not version controlled)
      ''
        if [[ -f ~/.zshenv.local ]]; then
          source ~/.zshenv.local
        fi
      ''
    ];

    # ========================================================================
    # .zshrc (initContent)
    # ========================================================================
    initContent = ''
      export SHELL="$(command -v zsh)"

      # Disable Ctrl-D to exit
      setopt IGNORE_EOF
      # Disable Ctrl-S/Ctrl-Q flow control (frees Ctrl-S for other keybinds)
      setopt NO_FLOW_CONTROL
      # Allow comments in interactive shell (useful for pasting commands with #)
      setopt INTERACTIVE_COMMENTS

      # tirith (interactive-shell command guard; human terminal sessions only -
      # AI-agent Bash-tool invocations spawn non-interactive zsh and never
      # source this file, see bash-commands-denied.nix for that path instead)
      # eval "$(tirith init --shell zsh)"

      # direnv (immediate loading - needs to run before first prompt for .envrc)
      eval "$(direnv hook zsh)"

      # mise
      eval "$(mise activate zsh)"

      # Source modular configs
      source "${zshDir}/aws.zsh"
      source "${zshDir}/completion.zsh"
      source "${zshDir}/history-fzf.zsh"
      source "${zshDir}/keybind.zsh"
      source "${zshDir}/prompt.zsh"
      source "${zshDir}/snippet.zsh"
      source "${zshDir}/zoxide.zsh"

      # Safe-chain
      if [[ -f ~/.safe-chain/scripts/init-posix.sh ]]; then
        source ~/.safe-chain/scripts/init-posix.sh
        # Keep npm/npx absent while retaining Safe-chain wrappers for pnpm, uv, etc.
        unfunction npm npx 2>/dev/null || true
      fi

      # Local config (machine-specific, not version controlled)
      if [[ -f ~/.zshrc.local ]]; then
        source ~/.zshrc.local
      fi
    '';

    # ========================================================================
    # History
    # ========================================================================
    history = {
      append = true;
      extended = true;
      expireDuplicatesFirst = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignoreSpace = true;
      path = "$HOME/.zsh_history";
      save = 1000000;
      share = true;
      size = 1000000;
    };
  };
}
