#!/usr/bin/env zsh
# shellcheck disable=all

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --no-cmd)"
fi

__z_tmux_rename_for_dir() {
  local dir="$1"
  [[ -n $TMUX && -n $dir ]] || return 0

  local session
  if [[ $dir == *"/.worktrees/"* ]]; then
    local repository_root=${dir%%/.worktrees/*}
    local repository=${repository_root:t}
    local repository_session=${repository//./-}
    local worktree_path=${dir#*/.worktrees/}
    local worktree_dir=${worktree_path%%/*}
    local worktree_session=${worktree_dir//./-}
    session="${repository_session}-${worktree_session}"
  else
    local repository=${dir:t}
    session=${repository//./-}
  fi

  tmux rename-session "${session}"
}

__z_query_paths() {
  zoxide query --list --score 2>/dev/null || true
}

__z_cd() {
  cd "$@" || return $?
  __z_tmux_rename_for_dir "$PWD"
  return 0
}

zi() {
  local selected_path
  selected_path="$(
    __z_query_paths |
      fzf --layout=reverse --no-sort --query="$*"
  )" || return $?

  [[ -n "$selected_path" ]] || return 1
  selected_path="$(printf '%s' "$selected_path" | sed 's/^[[:space:]]*[0-9][0-9.]*[[:space:]]*//')"
  __z_cd "$selected_path"
}

__zoxide_zi_widget() {
  local selected_path
  selected_path="$(
    __z_query_paths |
      fzf --layout=reverse --no-sort --height='~15' --query="$BUFFER"
  )" || {
    zle reset-prompt
    return $?
  }

  if [[ -z "$selected_path" ]]; then
    zle reset-prompt
    return 1
  fi

  selected_path="$(printf '%s' "$selected_path" | sed 's/^[[:space:]]*[0-9][0-9.]*[[:space:]]*//')"
  BUFFER="cd ${(q)selected_path}"
  zle reset-prompt
  zle accept-line
  __z_tmux_rename_for_dir "$selected_path"
}

zle -N zoxide-zi-widget __zoxide_zi_widget
bindkey "^g" zoxide-zi-widget

z() {
  if [[ "$#" -eq 0 ]]; then
    zi
    return $?
  fi

  if [[ "$#" -eq 1 ]]; then
    if [[ "$1" == "-" ]]; then
      __z_cd - || return $?
      return $?
    fi

    if [[ -d "$1" ]]; then
      __z_cd "$1" || return $?
      return $?
    fi

    local target_path
    target_path="$(zoxide query --exclude "$PWD" -- "$1" 2>/dev/null)" || {
      zi "$1"
      return $?
    }

    [[ -n "$target_path" ]] || {
      zi "$1"
      return $?
    }

    __z_cd "$target_path" || return $?
    return $?
  fi

  zi "$@"
}

__z_seed_ghq_paths() {
  command -v zoxide &>/dev/null && command -v ghq &>/dev/null || return 0
  local ghq_path zoxide_db
  zoxide_db="$(zoxide query --list 2>/dev/null)"
  while IFS= read -r ghq_path; do
    grep -qxF "$ghq_path" <<< "$zoxide_db" || zoxide add --score 50 -- "$ghq_path"
  done < <(ghq list -p 2>/dev/null)
}
__z_seed_ghq_paths
