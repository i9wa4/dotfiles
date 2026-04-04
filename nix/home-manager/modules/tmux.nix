{
  pkgs,
  username,
  ...
}:
let
  homeDir = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
  dotfilesDir = "${homeDir}/ghq/github.com/i9wa4/dotfiles";
in
{
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
      # Panes control
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Popup
      bind-key f display-popup -w 60% -h 50% -E 'tmux list-sessions -F "#{session_name}" | fzf --reverse | xargs -I{} tmux switch-client -t {}'
      bind-key g display-popup -d '#{pane_current_path}' -w 90% -h 90% -E 'lazygit'

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
      set-hook -g after-new-window 'select-pane -T "pane"'
      set-hook -g after-new-session 'select-pane -T "pane"'
      set-hook -g after-split-window 'select-pane -T "pane"'
      set-option -g pane-active-border-style 'fg=red'
      set-option -g pane-border-format '> #{pane_index} #{pane_id} ✨#{pane_title} > #{pane_current_command} > #{history_size} lines >'
      set-option -g pane-border-status top
      set-option -g pane-border-style 'fg=green'
      set-option -g status-interval 1
      set-option -g status-left " {session_id} #{=50:session_name} "
      set-option -g status-left-length 52
      set-option -g status-position top
      set-option -g status-right "#(cd \"#{pane_current_path}\" && ${dotfilesDir}/bin/repo-status)#(tmux-a2a-postman -- get-session-status-oneline) #(${dotfilesDir}/bin/system-load)"
      set-option -g status-right-length 200
      set-option -g status-style bg=default
      # Bell: passthrough to terminal, tmux stays silent
      set-option -g monitor-bell off
      set-option -g visual-bell off
      set-option -g window-status-bell-style 'none'
      set-option -g window-status-current-format '#[reverse]  #{window_index}#{?window_zoomed_flag,🔎,  }#[default]'
      set-option -g window-status-format '  #{window_index}#{?window_zoomed_flag,🔎,  }'

      # Passthrough (OSC 52 clipboard, bell, etc.)
      set-option -g set-clipboard on
      set-option -g allow-passthrough on
      bind-key Y run-shell 'tmux save-buffer - | tmux load-buffer -w -'

      # Terminal
      set-option -sa terminal-features ",*:RGB"

      # Reload config
      bind-key I source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"
    '';
  };
}
