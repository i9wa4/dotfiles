# https://zenn.dev/enchan1207/articles/7b9d7d397b7d0d
[ -r /etc/zshrc ] && . /etc/zshrc


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


# Alacritty
setopt IGNORE_EOF


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
compinit -d "${_zcompdump}"
zstyle ':completion:*' menu select
setopt menu_complete
zmodload zsh/complist
bindkey -M menuselect '^i' accept-and-infer-next-history
bindkey -M menuselect '^y' accept-line
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history


# Git
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:*' formats "%8.8i %b %m"
zstyle ':vcs_info:*' actionformats '%8.8i %b|%a %m'
zstyle ':vcs_info:git:*' get-revision true
zstyle ':vcs_info:git+set-message:*' hooks simple-git-status

function +vi-simple-git-status() {
  local untracked=$(git status --porcelain 2>/dev/null | grep -c "^??")
  local unstaged=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')

  local shortstat=$(git diff --shortstat 2>/dev/null)
  local insertions=0
  local deletions=0
  if [[ "${shortstat}" =~ '([0-9]+) insertion' ]]; then
    insertions="${match[1]}"
  fi
  if [[ "${shortstat}" =~ '([0-9]+) deletion' ]]; then
    deletions="${match[1]}"
  fi

  if [[ "${untracked}" -gt 0 ]]; then
    hook_com[misc]+="?${untracked} "
  fi
  if [[ "${unstaged}" -gt 0 ]]; then
    hook_com[misc]+="~${unstaged} "
  fi
  if [[ "${insertions}" -gt 0 ]]; then
    hook_com[misc]+="+${insertions} "
  fi
  if [[ "${deletions}" -gt 0 ]]; then
    hook_com[misc]+="-${deletions} "
  fi
}

_vcs_precmd(){ vcs_info }
add-zsh-hook precmd _vcs_precmd


# SSH connection detection
if [[ -n "${SSH_CONNECTION}" || -n "${SSH_TTY}" || -n "${SSH_CLIENT}" ]]; then
  _IS_REMOTE=1
else
  _IS_REMOTE=0
fi


# Prompt
function _get_simplified_path() {
  local path="${PWD}"
  path="${path/#$HOME\/ghq\/github.com\//}"
  path="${path/#$HOME/~}"
  echo "${path}"
}

PROMPT=""
if (( _IS_REMOTE )); then
  PROMPT="[%M] "
fi
PROMPT="
${PROMPT}%D{[%Y-%m-%d %H:%M:%S]} %K{#FFB6C1}%F{#606060}[\$(_get_simplified_path)]%f%k "'${vcs_info_msg_0_}'"
$ "


# mise
# _mise_preexec() {
#   eval "$("${HOME}"/.local/bin/mise activate zsh --quiet)"
#   preexec_functions=(${preexec_functions:#_mise_preexec})
# }
# preexec_functions+=(_mise_preexec)
eval "$("${HOME}"/.local/bin/mise activate zsh --quiet)"


# zeno.zsh
_zeno_path="${HOME}"/ghq/github.com/yuki-yano/zeno.zsh/zeno.zsh
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


# tmux
if (( _IS_REMOTE )); then
  # Remote host
else
  # Local host
  if [[ "${SHLVL}" -eq 1 && "${TERM_PROGRAM}" != "vscode" ]]; then
    alacritty-theme-switch
    tmux
  fi
fi
