# https://wiki.archlinux.jp/index.php/Zsh
autoload -Uz compinit promptinit
compinit
promptinit

prompt suse

# https://qiita.com/ToruIwashita/items/5cfa382e9ae2bd0502be
zstyle ':completion:*' menu select interactive
setopt menu_complete
zmodload zsh/complist
bindkey -M menuselect '^y' accept-and-infer-next-history
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history

# Keybind
bindkey -v

# Git
# https://hirooooo-lab.com/development/git-terminal-customize-zsh/
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}+"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}*"
zstyle ':vcs_info:*' formats "%F{green}%c%u(%b)%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
_SHELL_TYPE="$(ps -o comm -p $$ | tail -n 1 | sed -e 's/.*\///g')"
if [[ -n "${SSH_CONNECTION}" || -n "${SSH_TTY}" || -n "${SSH_CLIENT}" ]]; then
  # remote host
  PROMPT='%F{red}%n@%m%f'
else
  # local host
  PROMPT='%F{cyan}%n@%m%f'
fi

# Prompt
PROMPT="${PROMPT}"' %F{#696969}('\$_SHELL_TYPE'-lv%L)%f'
PROMPT="${PROMPT}"' %F{#696969}%~%f '\$vcs_info_msg_0_'
%# '
precmd(){ vcs_info }

# Git automatic fetch
if test "$(pgrep tmux | wc -l)" -eq 0; then
  bash "${HOME}"/dotfiles/bin/git-autofetch.sh &
fi

# tmux
# https://qiita.com/kiwi-bird/items/7f1a77faf6b0ab0df571
if [[ -n "${SSH_CONNECTION}" || -n "${SSH_TTY}" || -n "${SSH_CLIENT}" ]]; then
  # remote host
else
  # local host
  alias tmux="tmux -u2"
  count=$(ps aux | grep tmux | grep -v grep | wc -l)
  if test "${count}" -eq 0; then
      echo $(tmux)
  elif test "${count}" -eq 1; then
      echo $(tmux a)
  fi
fi

# zeno.zsh
if test -e "${HOME}"/.cache/zeno.zsh/zeno.zsh; then
  . "${HOME}"/.cache/zeno.zsh/zeno.zsh
else
  git clone https://github.com/yuki-yano/zeno.zsh "${HOME}"/.cache/zeno.zsh
  if test -e "${HOME}"/.cache/zeno.zsh/zeno.zsh; then
    . "${HOME}"/.cache/zeno.zsh/zeno.zsh
  fi
fi
# https://qiita.com/obake_fe/items/da8f861eed607436b91c
if [[ -n "${ZENO_LOADED}" ]]; then
  bindkey ' '  zeno-auto-snippet
  bindkey '^m' zeno-auto-snippet-and-accept-line
  bindkey '^i' zeno-completion
  bindkey '^g' zeno-ghq-cd
  bindkey '^r' zeno-history-selection
  bindkey '^x' zeno-insert-snippet
fi
