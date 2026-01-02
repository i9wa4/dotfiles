zmodload zsh/zprof


# https://zenn.dev/enchan1207/articles/7b9d7d397b7d0d
[ -r /etc/zshrc ] && . /etc/zshrc


# Alacritty
setopt IGNORE_EOF


# History
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt append_history
setopt extended_history
setopt hist_fcntl_lock
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt share_history


# Keybind
bindkey -e
bindkey '\e[3~' delete-char


# Edit Command Line
autoload -Uz edit-command-line
zle -N edit-command-line
edit_current_line() {
  EDITOR="vim -c 'normal! G$' -c 'setfiletype zsh'" \
    zle edit-command-line
}
zle -N edit_current_line
bindkey '^x^e' edit_current_line


# Zinit (manual install)
# https://github.com/zdharma-continuum/zinit?tab=readme-ov-file#manual
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# compinit (lazy loading via zinit turbo mode)
setopt extendedglob
_zcompdump="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/.zcompdump-${HOST}-${ZSH_VERSION}"
mkdir -p "${_zcompdump:h}"
zinit ice wait'0a' lucid \
  atload'
    autoload -Uz compinit
    if [[ -n "${_zcompdump}"(#qN.mh+24) ]]; then
      compinit -d "${_zcompdump}"
    else
      compinit -C -d "${_zcompdump}"
    fi
    zstyle ":completion:*" menu select
    setopt menu_complete
    zmodload zsh/complist
    bindkey -M menuselect "h" vi-backward-char
    bindkey -M menuselect "j" vi-down-line-or-history
    bindkey -M menuselect "k" vi-up-line-or-history
    bindkey -M menuselect "l" vi-forward-char
  '
zinit light zdharma-continuum/null

# mise (lazy loading via zinit turbo mode)
zinit ice wait'0b' lucid \
  atload'eval "$(${HOME}/.local/bin/mise activate zsh --quiet)"'
zinit light zdharma-continuum/null

# zeno.zsh (lazy loading via zinit turbo mode)
zinit ice wait'0c' lucid depth"1" blockf \
  atload'
    if [[ -n "${ZENO_LOADED}" ]]; then
      bindkey " "  zeno-auto-snippet
      bindkey "^m" zeno-auto-snippet-and-accept-line
      bindkey "^i" zeno-completion
      bindkey "^g" zeno-ghq-cd
      bindkey "^r" zeno-history-selection
      bindkey "^x^i" zeno-insert-snippet
    else
      bindkey "^r" history-incremental-search-backward
    fi
  '
zinit light yuki-yano/zeno.zsh

# SSH connection detection
if [[ -n "${SSH_CONNECTION}" || -n "${SSH_TTY}" || -n "${SSH_CLIENT}" ]]; then
  _IS_LOCAL=0
else
  _IS_LOCAL=1
fi


# Prompt
setopt prompt_subst
function _get_simplified_path() {
  local path="${PWD}"
  path="${path/#$HOME\/ghq\/github.com\//}"
  path="${path/#$HOME/~}"
  echo "${path}"
}
(( _IS_LOCAL )) && PROMPT="" || PROMPT="[%M] "
PROMPT="
${PROMPT}[%D{%Y-%m-%d %H:%M:%S}] %S[\$(_get_simplified_path)]%s \$(${HOME}/ghq/github.com/i9wa4/dotfiles/bin/repo-status)
$ "


# AWS SSO profile tracking
preexec() {
  if [[ "$1" =~ 'aws sso login --profile ([^ ]+)' ]]; then
    export MY_AWS_SSO_PROFILE="${match[1]}"
  fi
}


# tmux
if (( _IS_LOCAL )); then
  if [[ "${SHLVL}" -eq 1 && "${TERM_PROGRAM}" != "vscode" ]]; then
    tmux
  fi
fi
