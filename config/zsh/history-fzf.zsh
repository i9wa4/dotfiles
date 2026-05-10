#!/usr/bin/env zsh
# shellcheck disable=all

__history_fzf_widget() {
  local selected exit_code

  fc -RI 2>/dev/null

  selected="$(
    fc -rl 1 2>/dev/null |
      awk '{ sub(/^[[:space:]]*[0-9]+[[:space:]]*/, ""); if (length($0) && !seen[$0]++) print }' |
      fzf --layout=reverse --height='~40%' --query="$LBUFFER"
  )"
  exit_code=$?

  if (( exit_code == 0 )) && [[ -n "$selected" ]]; then
    BUFFER="$selected"
    CURSOR="${#BUFFER}"
  fi

  zle reset-prompt
  return "$exit_code"
}

if command -v fzf &>/dev/null; then
  zle -N history-fzf-widget __history_fzf_widget
  bindkey "^r" history-fzf-widget
else
  bindkey "^r" history-incremental-search-backward
fi
