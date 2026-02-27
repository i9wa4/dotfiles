# Bash configuration (fallback shell for SSM sessions)
# Auto-switches to zsh when possible
_: {
  programs.bash = {
    enable = true;
    initExtra = ''
      # Auto-switch to zsh (SSM sets USER=root, fix it before switching)
      if [ -z "$TMUX" ] && [ -z "$ZSH_VERSION" ] && command -v zsh >/dev/null 2>&1; then
        export USER=$(id -un)
        exec zsh -l
      fi
    '';
  };
}
