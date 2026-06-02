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

_zcompdump_zwc="${_zcompdump}.zwc"
if [[ -r "${_zcompdump}" && ( ! -r "${_zcompdump_zwc}" || "${_zcompdump}" -nt "${_zcompdump_zwc}" ) ]]; then
  zcompile "${_zcompdump}" >/dev/null 2>&1 || true
fi
unset _zcompdump_zwc

zstyle ":completion:*" menu select
setopt menu_complete
zmodload zsh/complist
bindkey -M menuselect "h" vi-backward-char
bindkey -M menuselect "j" vi-down-line-or-history
bindkey -M menuselect "k" vi-up-line-or-history
bindkey -M menuselect "l" vi-forward-char
