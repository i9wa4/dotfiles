#!/usr/bin/env bash

dotfiles_worktree_find_branch() {
  local branch=$1
  local target_ref="refs/heads/${branch}"

  git worktree list --porcelain | awk -v target_ref="$target_ref" '
    /^worktree / {
      path = substr($0, 10)
    }
    /^branch / {
      if (substr($0, 8) == target_ref) {
        print path
        found = 1
      }
    }
    END {
      exit found ? 0 : 1
    }
  '
}

dotfiles_worktree_fetch_origin_and_update_main() {
  local current_branch

  echo "-> Fetching remote..."
  git fetch origin
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ $current_branch == "main" ]]; then
    git pull --ff-only origin main
  else
    echo "* Keeping local main unchanged while ${current_branch} is checked out"
  fi
  echo ""
}

dotfiles_worktree_add_zoxide() {
  local worktree_path=$1

  if command -v zoxide &>/dev/null; then
    zoxide add "$worktree_path"
    echo "* Added worktree to zoxide database"
  fi
}
