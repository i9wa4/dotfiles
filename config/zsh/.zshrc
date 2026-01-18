#!/usr/bin/env zsh
# shellcheck disable=all
# .zshrc - Interactive shell configuration
# This file is sourced by interactive shells only.
# Location: $ZDOTDIR/.zshrc

# tmux auto-start (local only, not in VSCode)
# exec replaces current shell, so put this before loading anything
if [[ -z "${SSH_CONNECTION}" && -z "${SSH_TTY}" && -z "${SSH_CLIENT}" ]]; then
  if [[ "${SHLVL}" -eq 1 && "${TERM_PROGRAM}" != "vscode" ]]; then
    exec tmux
  fi
fi

# Disable XON/XOFF flow control (enable Ctrl-Q for push-line-or-edit)
stty -ixon -ixoff 2>/dev/null

# Disable Ctrl-D to exit
setopt IGNORE_EOF

# History options (HISTFILE, HISTSIZE, SAVEHIST are set in .zshenv)
setopt append_history
setopt extended_history
setopt hist_fcntl_lock
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt share_history

# direnv (immediate loading - needs to run before first prompt for .envrc)
eval "$(direnv hook zsh)"

# Source modular configs from ZDOTDIR
source "${ZDOTDIR}/aws.zsh"
source "${ZDOTDIR}/keybind.zsh"
source "${ZDOTDIR}/prompt.zsh"
source "${ZDOTDIR}/zinit.zsh"

# Safe-chain
if [[ -f ~/.safe-chain/scripts/init-posix.sh ]]; then
  source ~/.safe-chain/scripts/init-posix.sh
fi

# Local config (machine-specific, not version controlled)
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi
