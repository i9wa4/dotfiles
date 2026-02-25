{
  pkgs,
  username,
  ...
}: let
  homeDir =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  dotfilesDir = "${homeDir}/ghq/github.com/i9wa4/dotfiles";
in {
  # Tmux configuration
  # cf. https://man.openbsd.org/OpenBSD-current/man1/tmux.1
  programs.tmux = {
    enable = true;
    historyLimit = 100000;
    keyMode = "vi";
    terminal = "tmux-256color";
    escapeTime = 10;
    focusEvents = true;
    extraConfig = ''
      # List of plugins
      set -g @plugin 'tmux-plugins/tpm'

      # Panes control
      bind-key -r H resize-pane -L 1
      bind-key -r J resize-pane -D 1
      bind-key -r K resize-pane -U 1
      bind-key -r L resize-pane -R 1

      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      bind-key -n S-Left select-pane -L
      bind-key -n S-Right select-pane -R
      bind-key -n S-Up select-pane -U
      bind-key -n S-Down select-pane -D

      # tmux-a2a-postman
      bind-key M-e select-pane -T "agent"
      bind-key M-b select-pane -T "boss"
      bind-key M-c select-pane -T "critic"
      bind-key M-g select-pane -T "guardian"
      bind-key M-m select-pane -T "messenger"
      bind-key M-o select-pane -T "orchestrator"
      bind-key M-w select-pane -T "worker"

      # Windows / Sessions control
      bind-key -n M-Left previous-window
      bind-key -n M-Right next-window
      bind-key -n M-Up switch-client -p
      bind-key -n M-Down switch-client -n

      # Popup
      bind-key f display-popup -w 60% -h 50% -E 'tmux list-sessions -F "#{session_name}" | fzf --reverse | xargs -I{} tmux switch-client -t {}'
      bind-key g display-popup -d '#{pane_current_path}' -w 90% -h 90% -E 'lazygit'
      bind-key u display-popup -d '#{pane_current_path}' -w 90% -h 90% -E

      # Inherit current path
      bind-key % split-window -h -c "#{pane_current_path}"
      bind-key '"' split-window -v -c "#{pane_current_path}"
      bind-key c new-window -c "#{pane_current_path}"
      bind-key s choose-tree -sZ -F '#{?session_attached,*, }(#{session_windows})'

      # Options
      # Use C-a on remote (SSH), C-b on local
      if-shell '[ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]' \
        "set-option -g prefix C-a; unbind C-b; bind-key C-a send-prefix" \
        "set-option -g prefix C-b; unbind C-a; bind-key C-b send-prefix"

      # Default pane title (override hostname)
      set-hook -g after-new-window 'select-pane -T "anonymous"'
      set-hook -g after-new-session 'select-pane -T "anonymous"'
      set-hook -g after-split-window 'select-pane -T "anonymous"'
      set-option -g pane-active-border-style 'fg=red'
      set-option -g pane-border-format '> #{pane_index} #{pane_id} ✨#{pane_title} > #{pane_current_command} > #{history_size} lines >'
      set-option -g pane-border-status top
      set-option -g pane-border-style 'fg=green'
      set-option -g status-interval 1
      set-option -g status-left " #{=50:session_name} "
      set-option -g status-left-length 52
      set-option -g status-position top
      set-option -g status-right "#(cd \"#{pane_current_path}\" && ${dotfilesDir}/bin/repo-status)#(nix run github:i9wa4/tmux-a2a-postman -- get-session-status-oneline) #(${dotfilesDir}/bin/system-load)"
      set-option -g status-right-length 200
      set-option -g status-style bg=default
      set-option -g visual-bell off
      set-option -g window-status-bell-style 'none'
      set-option -g window-status-current-format '#[reverse]  #{window_index}#{?window_zoomed_flag,🔎,  }#[default]'
      set-option -g window-status-format '  #{window_index}#{?window_zoomed_flag,🔎,  }'

      # Terminal
      set-option -sa terminal-features ",*:RGB"

      # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
      run '~/.config/tmux/plugins/tpm/tpm'
    '';
  };
}
