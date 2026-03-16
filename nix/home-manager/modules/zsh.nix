# Zsh configuration (managed by home-manager programs.zsh)
# Replaces config/zsh/.zshenv, .zshrc
# Modular source files remain in config/zsh/ (aws.zsh, prompt.zsh, zinit.zsh)
{
  pkgs,
  lib,
  config,
  username,
  ...
}:
let
  homeDir = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
  dotfilesDir = "${homeDir}/ghq/github.com/i9wa4/dotfiles";
  zshDir = "${dotfilesDir}/config/zsh";
in
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    completionInit = "autoload -U compinit && compinit -u";

    # ========================================================================
    # .zshenv (envExtra)
    # ========================================================================
    envExtra = lib.concatStringsSep "\n" [
      # System
      ''
        export EDITOR=vim
        export VISUAL=vim
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
        if pkgs.stdenv.isDarwin then
          ''
            # Nix PATH recovery (in case macOS update overwrites /etc/zshenv)
            if [ -z "''${__NIX_DARWIN_SET_ENVIRONMENT_DONE-}" ]; then
              if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
              fi
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

        # Deno
        export DENO_NO_PROMPT=1
        export DENO_NO_UPDATE_CHECK=1

        # fzf
        export FZF_DEFAULT_OPTS="--reverse --bind 'ctrl-y:accept'"

        # Neovim
        export NVIM_APPNAME=nvim

        # Nix
        export NIXPKGS_ALLOW_UNFREE=1

        # Node.js
        export NODE_OPTIONS="--max-old-space-size=16384"

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
      # tmux auto-start (not in VSCode, not already in tmux)
      export SHELL="$(command -v zsh)"
      # if [[ -z "$TMUX" && "''${TERM_PROGRAM}" != "vscode" ]]; then
      #   command -v tmux &>/dev/null && exec tmux new-session -A -s main
      # fi

      # Disable Ctrl-D to exit
      setopt IGNORE_EOF

      # direnv (immediate loading - needs to run before first prompt for .envrc)
      eval "$(direnv hook zsh)"

      # Source modular configs
      source "${zshDir}/aws.zsh"
      source "${zshDir}/keybind.zsh"
      source "${zshDir}/prompt.zsh"
      source "${zshDir}/zinit.zsh"

      # Safe-chain
      if [[ -f ~/.safe-chain/scripts/init-posix.sh ]]; then
        source ~/.safe-chain/scripts/init-posix.sh
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
      path = "$HOME/.zsh_history";
      size = 1000000;
      save = 1000000;
      append = true;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
  };
}
