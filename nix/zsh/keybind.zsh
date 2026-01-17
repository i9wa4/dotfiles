#!/usr/bin/env zsh
# shellcheck disable=all
# Keybind
bindkey -e
bindkey '\e[3~' delete-char

# Stash current buffer, auto-restore after next command
bindkey '^q' push-line-or-edit

# Edit Command Line
autoload -Uz edit-command-line
zle -N edit-command-line
edit_current_line() {
  EDITOR="vim -c 'normal\! G$' -c 'setfiletype zsh'" \
    zle edit-command-line
}
zle -N edit_current_line
bindkey '^x^e' edit_current_line
