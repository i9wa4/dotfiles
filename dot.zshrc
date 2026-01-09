zmodload zsh/zprof


# Disable Ctrl-D to exit
setopt IGNORE_EOF


# History (HISTFILE, HISTSIZE, SAVEHIST are set in .zshenv)
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
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME"/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
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

# direnv (lazy loading via zinit turbo mode)
zinit ice wait'0b' lucid \
  atload'eval "$(direnv hook zsh)"'
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
function _get_devshell_indicator() {
  if [[ -n "${IN_NIX_SHELL}" || -n "${DIRENV_DIR}" ]]; then
    local repo_name=""
    if [[ -n "${DIRENV_DIR}" ]]; then
      local dir="${DIRENV_DIR#-}"
      if [[ "${dir}" =~ ghq/github\.com/(.+)$ ]]; then
        repo_name="${match[1]}"
      fi
    fi
    if [[ -n "${repo_name}" ]]; then
      print "❄️${repo_name} "
    else
      print "❄️devShell "
    fi
  fi
}
function _get_aws_profile_indicator() {
  [[ -n "${MY_AWS_PROFILE}" ]] && print -n "🔶${MY_AWS_PROFILE}"
}
function _get_context_line() {
  local devshell="$(_get_devshell_indicator)"
  local aws="$(_get_aws_profile_indicator)"
  print -n "${devshell}${aws}"
}

(( _IS_LOCAL )) && _HOST_PREFIX="" || _HOST_PREFIX="[%M] "
precmd() {
  local context="$(_get_context_line)"
  if [[ -n "${context}" ]]; then
    PROMPT=$'\n'"${context}"$'\n'"${_HOST_PREFIX}[%D{%Y-%m-%d %H:%M:%S}] %S[\$(_get_simplified_path)]%s \$(${HOME}/ghq/github.com/i9wa4/dotfiles/bin/repo-status)"$'\n$ '
  else
    PROMPT=$'\n'"${_HOST_PREFIX}[%D{%Y-%m-%d %H:%M:%S}] %S[\$(_get_simplified_path)]%s \$(${HOME}/ghq/github.com/i9wa4/dotfiles/bin/repo-status)"$'\n$ '
  fi
}


# AWS command wrapper (tracks SSO profile)
aws() {
  local profile=""
  local i
  for ((i=1; i<=${#@}; i++)); do
    if [[ "${@[$i]}" == "--profile" ]]; then
      profile="${@[$((i+1))]}"
      break
    fi
  done

  command aws "$@"
  local ret=$?

  if [[ "$1" == "sso" && "$2" == "login" && $ret -eq 0 && -n "$profile" ]]; then
    export MY_AWS_PROFILE="$profile"
  fi

  return $ret
}


# tmux
if (( _IS_LOCAL )); then
  if [[ "${SHLVL}" -eq 1 && "${TERM_PROGRAM}" != "vscode" ]]; then
    tmux
  fi
fi


# Safe-chain
if test -f ~/.safe-chain/scripts/init-posix.sh; then
  source ~/.safe-chain/scripts/init-posix.sh
fi


# Local config (machine-specific, not version controlled)
if test -f ~/.zshrc.local; then
  source ~/.zshrc.local
fi
