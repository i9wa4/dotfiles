# https://zenn.dev/enchan1207/articles/7b9d7d397b7d0d
[ -r /etc/zshrc ] && . /etc/zshrc


# Keybind
bindkey -v
# https://wayohoo.com/article/6922
bindkey '\e[3~' delete-char


# Edit Command Line
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -a 'v' edit-command-line


# Completion
# https://wiki.archlinux.jp/index.php/Zsh
autoload -Uz compinit promptinit
compinit
promptinit
# https://qiita.com/ToruIwashita/items/5cfa382e9ae2bd0502be
zstyle ':completion:*' menu select interactive
setopt menu_complete
zmodload zsh/complist
bindkey -M menuselect '^y' accept-and-infer-next-history
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history


# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt extended_history
setopt hist_allow_clobber
setopt hist_fcntl_lock
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_verify
setopt share_history


# Prompt
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html#Prompt-Expansion
# prompt bigfade
if { [ -n "${SSH_CONNECTION}" ] } \
  || { [ -n "${SSH_TTY}" ] } \
  || { [ -n "${SSH_CLIENT}" ] }; then
  # remote host
  PROMPT="%K{#FFB6C1}%F{#000000}[%M]%f%k "
else
  # local host
  PROMPT=""
fi
_shell_type="$(ps -o comm -p $$ | tail -n 1 | sed -e 's/.*\///g')"
# PROMPT="%F{#696969}%D{[%Y-%m-%d %H:%M:%S]} (${_shell_type}-lv%L) %f"
PROMPT="%F{#696969}%D{[%Y-%m-%d %H:%M:%S]} ${_shell_type} %f%K{#198CAA}%F{black}[%~]%f%k "'${vcs_info_msg_0_}'"
%F{#696969}$%f "


# Git
# https://zsh.sourceforge.io/Doc/Release/User-Contributions.html
# https://hirooooo-lab.com/development/git-terminal-customize-zsh/
# https://qiita.com/ono_matope/items/55d9dac8d30b299f590d
# https://qiita.com/mollifier/items/8d5a627d773758dd8078
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:*' formats "%F{green}%c%u(%b)%f %F{#696969}%8.8i %m%f"
zstyle ':vcs_info:*' actionformats '%F{red}[%b|%a]%f %F{#696969}%8.8i %m%f'
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' get-revision true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}+"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}*"
zstyle ':vcs_info:git+set-message:*' hooks \
  git-config-user
function +vi-git-config-user(){
  # hook_com[misc]+=`git config user.name`
  # hook_com[misc]+=' '
  # hook_com[misc]+=`git config user.email`
}
_vcs_precmd(){ vcs_info }
add-zsh-hook precmd _vcs_precmd


# zeno.zsh
zinit ice lucid depth"1" blockf
zinit light yuki-yano/zeno.zsh
# zinit light i9wa4/zeno.zsh
# https://qiita.com/obake_fe/items/da8f861eed607436b91c
if [ -n "${ZENO_LOADED}" ]; then
  bindkey ' '  zeno-auto-snippet
  bindkey '^m' zeno-auto-snippet-and-accept-line
  bindkey '^i' zeno-completion
  bindkey '^g' zeno-ghq-cd
  bindkey '^r' zeno-history-selection
  bindkey '^x' zeno-insert-snippet
else
  bindkey '^r' history-incremental-search-backward
fi


# Other Plugins
zinit light zsh-users/zsh-completions
# zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting


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
  # https://blog.k-bushi.com/post/tech/tips/use-nautilus/
  ln -fs /mnt/wslg/runtime-dir/wayland-* $XDG_RUNTIME_DIR/
elif [ "$(echo "${_uname}" | grep arm)" ]; then
  echo 'Hello, Raspberry Pi!'
elif [ "$(echo "${_uname}" | grep el7)" ]; then
  echo 'Hello, CentOS!'
else
  echo 'Which OS are you using?'
fi


# End of Settings
cd


# tmux
if { [ -n "${SSH_CONNECTION}" ] } \
  || { [ -n "${SSH_TTY}" ] } \
  || { [ -n "${SSH_CLIENT}" ] }; then
  # remote host
  echo "This is a remote host. Run tmux manually on your local host."
else
  # local host
  if [ "${SHLVL}" -eq 1 ]; then
    tmux
  fi
fi
