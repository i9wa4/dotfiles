{
  dotfilesDir,
  ...
}:
let
  isSshClient = ''[ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]'';
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
      bind-key -r H resize-pane -L 1
      bind-key -r J resize-pane -D 2
      bind-key -r K resize-pane -U 1
      bind-key -r L resize-pane -R 2
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Popup
      bind-key g display-popup -d '#{pane_current_path}' -w 90% -h 90% -E 'lazygit'

      # Inherit current path
      bind-key % split-window -h -c "#{pane_current_path}"
      bind-key '"' split-window -v -c "#{pane_current_path}"
      bind-key c new-window -c "#{pane_current_path}"

      # Options
      # Use C-a on remote (SSH), C-b on local
      set-option -ga update-environment " SSH_CLIENT SSH_TTY"
      if-shell '${isSshClient}' \
        "set-option -g prefix C-a; unbind C-b; bind-key C-a send-prefix" \
        "set-option -g prefix C-b; unbind C-a; bind-key C-b send-prefix"

      # Default pane title (override hostname)
      set-option -g pane-active-border-style 'fg=red'
      set-option -g pane-border-format '> #{pane_index} #{pane_id} ✨#{pane_title} > #{pane_current_command} >'
      set-option -g pane-border-status top
      set-option -g pane-border-style 'fg=green'
      set-option -g status-interval 1
      if-shell '${isSshClient}' \
        "set-option -g status 2" \
        "set-option -g status on"
      set-option -g status-left "[#(${dotfilesDir}/bin/tmux-session-index '#{session_id}')] #{=30:session_name} "
      set-option -g status-left-length 34
      set-option -g status-position top
      if-shell '${isSshClient}' \
        "set-option -g status-right \"#(cd \\\"#{pane_current_path}\\\" && ${dotfilesDir}/bin/repo-status) #(${dotfilesDir}/bin/system-load)\"; set-option -g status-format[1] '#[align=right]#(tmux-a2a-postman get-status-oneline 2>/dev/null)'" \
        "set-option -g status-right \"#(tmux-a2a-postman get-status-oneline 2>/dev/null) #(cd \\\"#{pane_current_path}\\\" && ${dotfilesDir}/bin/repo-status) #(${dotfilesDir}/bin/system-load)\""
      set-option -g status-right-length 200
      set-option -g status-style bg=default
      set-option -g window-status-bell-style 'none'
      set-option -g window-status-current-format '#[reverse]  #{window_index}#{?window_zoomed_flag,🔎,  }#[default]'
      set-option -g window-status-format '  #{window_index}#{?window_zoomed_flag,🔎,  }'

      # Bell: passthrough to terminal, tmux stays silent
      set-option -g monitor-bell off
      set-option -g visual-bell off

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
