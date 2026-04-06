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
      # Disable Ctrl-S/Ctrl-Q flow control (frees Ctrl-S for other keybinds)
      setopt NO_FLOW_CONTROL
      # Allow comments in interactive shell (useful for pasting commands with #)
      setopt INTERACTIVE_COMMENTS

      # direnv (immediate loading - needs to run before first prompt for .envrc)
      eval "$(direnv hook zsh)"

      # zoxide-backed jump commands
      if command -v zoxide &>/dev/null; then
        eval "$(zoxide init zsh --no-cmd)"
      fi

      __jump_to_path() {
        local target_path="$1"

        if [[ -n "$TMUX" ]]; then
          vtm project switch "$target_path"
        else
          cd "$target_path" || return $?
        fi
      }

      __vde_worktree_query_paths() {
        command -v ghq &>/dev/null || return 0
        command -v jq &>/dev/null || return 0
        command -v vde-worktree &>/dev/null || return 0

        ghq list -p | while IFS= read -r repo_path; do
          [[ -n "$repo_path" ]] || continue
          [[ -f "$repo_path/config/vde/worktree/config.yml" ]] || continue

          local repo_json
          repo_json="$(
            cd "$repo_path" &&
              vde-worktree list --json 2>/dev/null
          )" || continue

          printf '%s\n' "$repo_json" | jq -r --arg repo_path "$repo_path" '
            .worktrees[]
            | select(.path != $repo_path)
            | .path // empty
          '
        done
      }

      __z_query_paths() {
        {
          zoxide query --list 2>/dev/null || true
          ghq list -p 2>/dev/null || true
          __vde_worktree_query_paths
        } | awk '!seen[$0]++ { print; fflush() }'
      }

      __z_query_rows() {
        {
          zoxide query --list --score 2>/dev/null | awk '
            NF == 0 { next }
            {
              path = $0
              sub(/^[[:space:]]*[0-9.]+[[:space:]]+/, "", path)
              print path "\t" $1 "\tzoxide"
            }
          '
          ghq list -p 2>/dev/null | awk 'NF { print $0 "\t-\tghq" }'
          __vde_worktree_query_paths | awk 'NF { print $0 "\t-\tworktree" }'
        } | awk -F '\t' '
          {
            path = $1
            score = $2
            source = $3

            if (!(path in seen)) {
              seen[path] = 1
              order[++count] = path
              scores[path] = score
              sources[path] = source
              next
            }

            if (scores[path] == "-" && score != "-") {
              scores[path] = score
            }

            split(sources[path], existing, /\+/)
            already_present = 0
            for (i in existing) {
              if (existing[i] == source) {
                already_present = 1
                break
              }
            }

            if (!already_present) {
              sources[path] = sources[path] "+" source
            }
          }
          END {
            for (i = 1; i <= count; i++) {
              path = order[i]
              print scores[path] "\t" sources[path] "\t" path
            }
          }
        '
      }

      zi() {
        local selected_row
        local selected_path
        selected_row="$(
          __z_query_rows |
            fzf --layout=reverse --no-sort --height='~15' \
              --delimiter=$'\t' \
              --nth='2,3' \
              --header=$'score\tsource\tpath' \
              --query="$*"
        )" || return $?

        [[ -n "$selected_row" ]] || return 1
        selected_path="''${selected_row#*$'\t'}"
        selected_path="''${selected_path#*$'\t'}"
        [[ -n "$selected_path" ]] || return 1
        __jump_to_path "$selected_path"
      }

      z() {
        if [[ "$#" -eq 0 ]]; then
          zi
          return $?
        fi

        if [[ "$#" -eq 1 ]]; then
          if [[ "$1" == "-" ]]; then
            cd - || return $?
            return $?
          fi

          if [[ -d "$1" ]]; then
            __jump_to_path "$1"
            return $?
          fi

          local target_path
          target_path="$(zoxide query --exclude "$PWD" -- "$1" 2>/dev/null)" || {
            zi "$1"
            return $?
          }

          [[ -n "$target_path" ]] || {
            zi "$1"
            return $?
          }

          __jump_to_path "$target_path"
          return $?
        fi

        zi "$@"
      }

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
