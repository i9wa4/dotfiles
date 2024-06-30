# https://wiki.archlinux.jp/index.php/Zsh
autoload -Uz compinit promptinit
compinit
promptinit

# Keybind
bindkey -v

# Git
# https://hirooooo-lab.com/development/git-terminal-customize-zsh/
# https://qiita.com/ono_matope/items/55d9dac8d30b299f590d
# https://qiita.com/mollifier/items/8d5a627d773758dd8078
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:*' formats "%F{green}%c%u(%b)%f %F{#696969}(%s) (%m)%f"
zstyle ':vcs_info:*' actionformats '[%b|%a] %F{#696969}(%s) (%m)%f'
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}+"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}*"
zstyle ':vcs_info:git+set-message:*' hooks git-config-user
function +vi-git-config-user(){
  hook_com[misc]+=`git config user.name`
}
_vcs_precmd(){ vcs_info }
add-zsh-hook precmd _vcs_precmd

# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html#Prompt-Expansion
# prompt bigfade
# PROMPT='%B%F{blue}█▓▒░%B%F{white}%K{blue}%n@%m%b%k%f%F{blue}%K{black}░▒▓█%b%f%k%F{blue}%K{black}█▓▒░%B%F{white}%K{black} %D{%a %b %d} %D{%I:%M:%S%P}
# %}%B%F{yellow}%K{black}%d>%b%f%k'
if [[ -n "${SSH_CONNECTION}" || -n "${SSH_TTY}" || -n "${SSH_CLIENT}" ]]; then
  # remote host
  PROMPT="%K{black}%F{red}█▓▒░%f%F{black}%K{red}%B%n@%m%b%k%f%F{red}░▒▓█%f%F{white}█▓▒░ %f%k"
else
  # local host
  PROMPT="%K{black}%F{green}█▓▒░%f%F{black}%K{green}%B%n@%m%b%k%f%F{green}░▒▓█%f%F{white}█▓▒░ %f%k"
fi
_SHELL_TYPE="$(ps -o comm -p $$ | tail -n 1 | sed -e 's/.*\///g')"
PROMPT="${PROMPT}{black}%F{#696969}%D{%Y-%m-%d(%a) %H:%M:%S} (${_SHELL_TYPE}-lv%L)%f
%F{yellow}[%~]%f "'${vcs_info_msg_0_}'"
$ "

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

# https://qiita.com/ToruIwashita/items/5cfa382e9ae2bd0502be
zstyle ':completion:*' menu select interactive
setopt menu_complete
zmodload zsh/complist
bindkey -M menuselect '^y' accept-and-infer-next-history
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history

# zeno.zsh
zinit ice lucid depth"1" blockf
zinit light yuki-yano/zeno.zsh

# https://qiita.com/obake_fe/items/da8f861eed607436b91c
if [[ -n "${ZENO_LOADED}" ]]; then
  bindkey ' '  zeno-auto-snippet
  bindkey '^m' zeno-auto-snippet-and-accept-line
  bindkey '^i' zeno-completion
  bindkey '^g' zeno-ghq-cd
  bindkey '^r' zeno-history-selection
  bindkey '^x' zeno-insert-snippet
else
  # https://wayohoo.com/article/6922
  bindkey '\e[3~' delete-char
  bindkey '^r' history-incremental-search-backward
  bindkey '^s' history-incremental-search-forward
fi

zinit light zsh-users/zsh-completions
# zinit light zsh-users/zsh-autosuggestions
# zinit light zsh-users/zsh-syntax-highlighting

# tmux
if [[ -n "${SSH_CONNECTION}" || -n "${SSH_TTY}" || -n "${SSH_CLIENT}" ]]; then
  # remote host
else
  # local host
  if [[ "${SHLVL}" -eq 1 ]]; then
    tmux
  fi
fi
