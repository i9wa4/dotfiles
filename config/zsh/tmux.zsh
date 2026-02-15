#!/usr/bin/env zsh
# shellcheck disable=all
# tmux-related functions and configurations

# Set A2A_NODE environment variable and update tmux environment
# Usage: set_a2a_node <node_name>
#   e.g., set_a2a_node orchestrator
#   e.g., set_a2a_node worker
#   e.g., set_a2a_node observer
set_a2a_node() {
  if [ -z "$1" ]; then
    echo "Usage: set_a2a_node <node_name>"
    echo "Example: set_a2a_node orchestrator"
    return 1
  fi

  export A2A_NODE="$1"

  # Update tmux pane-local option if running inside tmux
  if [ -n "$TMUX" ]; then
    tmux set-option -p @a2a_node "$A2A_NODE"
  fi

  echo "A2A_NODE set to: $A2A_NODE"
}

# Clear A2A_NODE
clear_a2a_node() {
  unset A2A_NODE

  if [ -n "$TMUX" ]; then
    tmux set-option -p -u @a2a_node
  fi

  echo "A2A_NODE cleared"
}

# Sync A2A_NODE to tmux pane-local option on every prompt
# This ensures pane border displays the current shell value
_sync_a2a_node_to_tmux() {
  if [ -n "$TMUX" ]; then
    if [ -n "$A2A_NODE" ]; then
      # Only update if value changed
      local tmux_value=$(tmux show-option -pv @a2a_node 2>/dev/null)
      if [ "$tmux_value" != "$A2A_NODE" ]; then
        tmux set-option -p @a2a_node "$A2A_NODE" 2>/dev/null
      fi
    else
      # Unset if A2A_NODE is not set in shell
      tmux show-option -p @a2a_node &>/dev/null && tmux set-option -p -u @a2a_node 2>/dev/null
    fi
  fi
}

# Add to precmd hooks
autoload -Uz add-zsh-hook
add-zsh-hook precmd _sync_a2a_node_to_tmux
