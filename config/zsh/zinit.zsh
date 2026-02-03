#!/usr/bin/env zsh
# shellcheck disable=all

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
# zinit ice wait'0a' lucid
zinit ice lucid \
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

# zeno.zsh (lazy loading via zinit turbo mode)
# zinit ice wait'0b' lucid depth"1" blockf
zinit ice lucid depth"1" blockf \
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

    function zeno-ghq-cd-post-hook-impl() {
      local dir="$ZENO_GHQ_CD_DIR"
      if [[ -n $TMUX ]]; then
        local repository=${dir:t}
        local session=${repository//./-}
        tmux rename-session "${session}"
      fi
    }

    zle -N zeno-ghq-cd-post-hook zeno-ghq-cd-post-hook-impl
  '
zinit light yuki-yano/zeno.zsh
