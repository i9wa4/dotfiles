# https://zenn.dev/enchan1207/articles/7b9d7d397b7d0d
[ -r /etc/zshrc ] && . /etc/zshrc


# Keybind
bindkey -e
# https://wayohoo.com/article/6922
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
# bindkey '^xe' edit_current_line
bindkey '^x^e' edit_current_line


# Completion
# https://wiki.archlinux.jp/index.php/Zsh
autoload -Uz compinit
# compinit のキャッシュを使って再生成を抑制
_zcompdump_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"
_zcompdump_path="${_zcompdump_dir}/.zcompdump-${HOST}-${ZSH_VERSION}"
[[ -d "${_zcompdump_dir}" ]] || mkdir -p "${_zcompdump_dir}"
if [[ -f "${_zcompdump_path}" ]]; then
  compinit -C -d "${_zcompdump_path}"
else
  compinit -d "${_zcompdump_path}"
fi
if [[ -s "${_zcompdump_path}" ]]; then
  if [[ ! -f "${_zcompdump_path}.zwc" ]] || [[ "${_zcompdump_path}" -nt "${_zcompdump_path}.zwc" ]]; then
    zcompile "${_zcompdump_path}"
  fi
fi
# https://qiita.com/ToruIwashita/items/5cfa382e9ae2bd0502be
zstyle ':completion:*' menu select
setopt menu_complete
zmodload zsh/complist
bindkey -M menuselect '^i' accept-and-infer-next-history
bindkey -M menuselect '^y' accept-line
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history
# Troubleshooting: If you get "no such keymap `menuselect'" error, remove ~/.zcompdump* and restart zsh


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


# Git
# https://zsh.sourceforge.io/Doc/Release/User-Contributions.html
# https://hirooooo-lab.com/development/git-terminal-customize-zsh/
# https://qiita.com/ono_matope/items/55d9dac8d30b299f590d
# https://qiita.com/mollifier/items/8d5a627d773758dd8078
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
setopt prompt_subst
# zstyle ':vcs_info:*' formats "%F{#696969}%8.8i%f %F{green}%b%f %m"
# zstyle ':vcs_info:*' actionformats '%F{#696969}%8.8i%f %F{red}%b|%a%f %m'
zstyle ':vcs_info:*' formats "%8.8i %b %m"
zstyle ':vcs_info:*' actionformats '%8.8i %b|%a %m'
zstyle ':vcs_info:git:*' get-revision true
zstyle ':vcs_info:git+set-message:*' hooks \
  simple-git-status

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

  if { [[ -n "${untracked}" ]] } \
    && { [[ "${untracked}" -gt 0 ]] }; then
    # hook_com[misc]+="%F{cyan}?${untracked}%f "
    hook_com[misc]+="?${untracked} "
  fi
  if { [[ -n "${unstaged}" ]] } \
    && { [[ "${unstaged}" -gt 0 ]] }; then
    # hook_com[misc]+="%F{yellow}~${unstaged}%f "
    hook_com[misc]+="~${unstaged} "
  fi
  if [[ "${insertions}" -gt 0 ]]; then
    # hook_com[misc]+="%F{green}+${insertions}%f "
    hook_com[misc]+="+${insertions} "
  fi
  if [[ "${deletions}" -gt 0 ]]; then
    # hook_com[misc]+="%F{red}-${deletions}%f "
    hook_com[misc]+="-${deletions} "
  fi
}

_vcs_precmd(){ vcs_info }
add-zsh-hook precmd _vcs_precmd


# Prompt
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html#Prompt-Expansion
if { [ -n "${SSH_CONNECTION}" ] } \
  || { [ -n "${SSH_TTY}" ] } \
  || { [ -n "${SSH_CLIENT}" ] }; then
  # remote host
  PROMPT="[%M] "
else
  # local host
  PROMPT=""
fi
# _shell_type="$(ps -o comm -p $$ | tail -n 1 | sed -e 's/.*\///g')"
# Simplify Path
setopt prompt_subst
function _get_simplified_path() {
  local path="${PWD}"
  path="${path/#$HOME\/ghq\/github.com\//}"
  path="${path/#$HOME/~}"
  echo "${path}"
}
PROMPT="%F{#696969}%D{[%Y-%m-%d %H:%M:%S]} [\$(_get_simplified_path)] "'${vcs_info_msg_0_}'"
${PROMPT}$%f "


# mise
eval "$("${HOME}"/.local/bin/mise activate zsh --quiet)"
# precmd から _mise_hook を外し chpwd のみで実行
if [[ ${precmd_functions[(r)_mise_hook]} == _mise_hook ]]; then
  precmd_functions=(${precmd_functions:#_mise_hook})
fi


# zeno.zsh
_zeno_path="${HOME}"/ghq/github.com/yuki-yano/zeno.zsh/zeno.zsh
if [[ -r "${_zeno_path}" ]]; then
  source "${_zeno_path}"
  # https://qiita.com/obake_fe/items/da8f861eed607436b91c
  if [ -n "${ZENO_LOADED}" ]; then
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


# OS-specific settings
# https://obel.hatenablog.jp/entry/20200214/1581620400
# https://qiita.com/reoring/items/47689c23d2e31035720b
_uname="$(uname -a)"
if [ "$(echo "${_uname}" | grep Darwin)" ]; then
  echo 'Hello, macOS!'
elif [ "$(echo "${_uname}" | grep Ubuntu)" ]; then
  echo 'Hello, Ubuntu'
  alias pbcopy='xclip -selection clipboard'
elif [ "$(echo "${_uname}" | grep WSL2)" ]; then
  echo 'Hello, WSL2!'
  alias pbcopy='xclip -selection clipboard'
elif [ "$(echo "${_uname}" | grep arm)" ]; then
  echo 'Hello, Raspberry Pi!'
elif [ "$(echo "${_uname}" | grep el7)" ]; then
  echo 'Hello, CentOS!'
else
  echo 'Which OS are you using?'
fi


# tmux
if { [ -n "${SSH_CONNECTION}" ] } \
  || { [ -n "${SSH_TTY}" ] } \
  || { [ -n "${SSH_CLIENT}" ] }; then
  # remote host
  echo "This is a remote host. Run tmux manually on your local host."
else
  # local host
  if { [ "${SHLVL}" -eq 1 ] } \
    && { [ "${TERM_PROGRAM}" != "vscode" ] }; then
    tmux
  fi
fi
