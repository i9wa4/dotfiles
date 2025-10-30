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


# Completion
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/.zcompdump-${HOST}-${ZSH_VERSION}"
mkdir -p "${_zcompdump:h}"
# Check for updates once a day
if [[ -n "${_zcompdump}"(#qN.mh+24) ]]; then
  compinit -d "${_zcompdump}"
else
  compinit -C -d "${_zcompdump}"
fi
zstyle ':completion:*' menu select
setopt menu_complete
zmodload zsh/complist
bindkey -M menuselect '^y' accept-line
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history


# zeno.zsh (lazy loading)
_zeno_lazy_init() {
  _zeno_path="${HOME}/ghq/github.com/yuki-yano/zeno.zsh/zeno.zsh"
  if [[ -r "${_zeno_path}" ]]; then
    source "${_zeno_path}"
    if [[ -n "${ZENO_LOADED}" ]]; then
      bindkey ' '  zeno-auto-snippet
      bindkey '^m' zeno-auto-snippet-and-accept-line
      bindkey '^i' zeno-completion
      bindkey '^g' zeno-ghq-cd
      bindkey '^r' zeno-history-selection
      bindkey '^x^i' zeno-insert-snippet
    else
      bindkey '^r' history-incremental-search-backward
    fi
  fi
  # Remove itself from precmd_functions after execution
  precmd_functions=("${(@)precmd_functions:#_zeno_lazy_init}")
}


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
${PROMPT}[%D{%Y-%m-%d %H:%M:%S}] %K{#FFB6C1}%F{#606060}[\$(_get_simplified_path)]%f%k \$(${HOME}/ghq/github.com/i9wa4/dotfiles/bin/repo-status)
$ "


# tmux
if (( _IS_LOCAL )); then
  if [[ "${SHLVL}" -eq 1 && "${TERM_PROGRAM}" != "vscode" ]]; then
    tmux
  else
    # mise
    eval "$(${HOME}/.local/bin/mise activate zsh --quiet)"

    # Lazy load zeno.zsh in tmux sessions
    precmd_functions=(_zeno_lazy_init $precmd_functions)
  fi
fi
