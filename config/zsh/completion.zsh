#!/usr/bin/env zsh
# shellcheck disable=all

# compinit ownership lives here so shell startup only initializes completion once.
setopt extendedglob
_zcompdump="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/.zcompdump-${HOST}-${ZSH_VERSION}"
mkdir -p "${_zcompdump:h}"

autoload -Uz compinit
if [[ -n "${_zcompdump}"(#qN.mh+24) ]]; then
  compinit -u -d "${_zcompdump}"
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
