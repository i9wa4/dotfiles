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
  local ghq_path
  {
    zoxide query --list --score 2>/dev/null || true
    ghq list -p 2>/dev/null | while IFS= read -r ghq_path; do
      [[ -d $ghq_path ]] && printf '0 %s\n' "$ghq_path"
    done
  } | awk '
    {
      path = $0
      sub(/^[[:space:]]*[0-9][0-9.]*[[:space:]]+/, "", path)
      if (!seen[path]++) print
    }
  '
}

__z_unique_ghq_path() {
  local query="$1" ghq_path repo_name exact_path candidate_path
  local exact_count=0 candidate_count=0

  while IFS= read -r ghq_path; do
    [[ -d $ghq_path ]] || continue
    repo_name=${ghq_path:t}
    if [[ $repo_name == "$query" ]]; then
      (( ++exact_count ))
      exact_path=$ghq_path
    fi
    if [[ $repo_name == *"$query"* ]]; then
      (( ++candidate_count ))
      candidate_path=$ghq_path
    fi
  done < <(ghq list -p 2>/dev/null)

  if (( exact_count == 1 )); then
    print -r -- "$exact_path"
  elif (( exact_count == 0 && candidate_count == 1 )); then
    print -r -- "$candidate_path"
  else
    return 1
  fi
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
      fzf --layout=reverse --scheme=path --nth=2.. --query="$*"
  )" || return $?

  [[ -n "$selected_path" ]] || return 1
  selected_path="$(printf '%s' "$selected_path" | sed 's/^[[:space:]]*[0-9][0-9.]*[[:space:]]*//')"
  __z_cd "$selected_path"
}

__zoxide_zi_widget() {
  local selected_path
  selected_path="$(
    __z_query_paths |
      fzf --layout=reverse --scheme=path --nth=2.. --height='~15' --query="$BUFFER"
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
    if target_path="$(zoxide query --exclude "$PWD" -- "$1" 2>/dev/null)" && [[ -n $target_path ]]; then
      __z_cd "$target_path"
      return $?
    fi

    if target_path="$(__z_unique_ghq_path "$1")"; then
      __z_cd "$target_path"
      return $?
    fi

    zi "$1"
    return $?
  fi

  zi "$@"
}
