# shellcheck disable=all
# .zshenv - Environment variables for zsh
# This file is sourced by both interactive and non-interactive shells.
# Symlinked from ~/.zshenv, sets ZDOTDIR for $XDG_CONFIG_HOME/zsh

# ==============================================================================
# XDG Base Directory
# ==============================================================================
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

# ==============================================================================
# System
# ==============================================================================
export EDITOR=vim
export VISUAL=vim
export TZ="Asia/Tokyo"
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

# locale
if locale -a 2>/dev/null | grep -q "en_US.UTF-8"; then
  export LC_ALL=en_US.UTF-8
else
  export LC_ALL=C.UTF-8
fi

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# ==============================================================================
# PATH
# ==============================================================================
# Nix PATH recovery (in case macOS update overwrites /etc/zshenv)
if [ -z "${__NIX_DARWIN_SET_ENVIRONMENT_DONE-}" ]; then
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
fi

# PATH deduplication for zsh
# https://zenn.dev/enchan1207/articles/7b9d7d397b7d0d
#
# Background:
# - On macOS, path_helper is normally called in /etc/zprofile, which reorders
#   PATH and pushes user-defined paths to the end.
# - In nix-darwin environment, /etc/zprofile is managed by Nix and path_helper
#   call is removed, so we don't need setopt no_global_rcs or manual path_helper.
# - However, PATH duplication still occurs when shells are nested (e.g., tmux).
# - typeset -U removes duplicates while preserving order.
if [ -n "${ZSH_VERSION:-}" ]; then
  typeset -U path PATH
fi

# Linux snap
if [[ -d /snap:bin ]]; then
  export PATH="${PATH}":/snap/bin
fi

# macOS Homebrew
if [[ -d /opt/homebrew ]]; then
  export PATH=/opt/homebrew/bin:"${PATH}"
fi

export PATH="${HOME}"/.local/bin:"${PATH}"
export PATH="${HOME}"/ghq/github.com/i9wa4/dotfiles/bin:"${PATH}"

# ==============================================================================
# Application Settings
# ==============================================================================
# Claude
export CLAUDE_CONFIG_DIR="${HOME}"/.claude

# Deno
export DENO_NO_PROMPT=1
export DENO_NO_UPDATE_CHECK=1

# fzf
export FZF_DEFAULT_OPTS="--reverse --bind 'ctrl-y:accept'"

# Neovim
export NVIM_APPNAME=nvim

# ==============================================================================
# External Sources
# ==============================================================================
# Home-manager session variables (for home.sessionPath, home.sessionVariables)
# cf. nix/common/home.nix home.sessionPath
if [ -f "/etc/profiles/per-user/${USER}/etc/profile.d/hm-session-vars.sh" ]; then
  source "/etc/profiles/per-user/${USER}/etc/profile.d/hm-session-vars.sh"
fi

# Local config (machine-specific, not version controlled)
if [[ -f ~/.zshenv.local ]]; then
  source ~/.zshenv.local
fi
