# loaded /etc/zsh/zshenv

# Nix PATH recovery (in case macOS update overwrites /etc/zshenv)
if [ -z "${__NIX_DARWIN_SET_ENVIRONMENT_DONE-}" ]; then
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
fi

# PATH deduplication for zsh
# https://zenn.dev/enchan1207/articles/7b9d7d397b7d0d
#
# Background:
# - On macOS, path_helper is normally called in /etc/zprofile, which reorders
#   PATH and pushes user-defined paths to the end.
# - In nix-darwin environment, /etc/zprofile is managed by Nix and path_helper
#   call is removed, so we don't need setopt no_global_rcs or manual path_helper.
# - However, PATH duplication still occurs when shells are nested (e.g., tmux).
# - typeset -U removes duplicates while preserving order.
if [ -n "${ZSH_VERSION:-}" ]; then
  typeset -U path PATH
fi

# Common
export EDITOR=vim
export PATH="${PATH}":/snap/bin
export TZ="Asia/Tokyo"
export VISUAL=vim
export XDG_CACHE_HOME="${HOME}"/.cache
export XDG_CONFIG_HOME="${HOME}"/.config

if locale -a | grep -q "en_US.UTF-8"; then
  export LC_ALL=en_US.UTF-8
else
  export LC_ALL=C.UTF-8
fi

# AWS
export AWS_DEFAULT_PROFILE=
export AWS_PROFILE=

# Claude
export CLAUDE_CONFIG_DIR="${HOME}"/ghq/github.com/i9wa4/dotfiles/dot.config/claude

# fzf
export FZF_DEFAULT_OPTS="
  --reverse
  --bind 'ctrl-y:accept'
"

# Homebrew
# NOTE: Managed by nix-darwin. Uncomment if you use Homebrew outside of Nix.
# export DYLD_LIBRARY_PATH=/opt/homebrew/lib
# export PATH=/opt/homebrew/bin:"${PATH}"

# Neovim
export NVIM_APPNAME=nvim

# zeno.zsh
export ZENO_DISABLE_EXECUTE_CACHE_COMMAND=1

# Home-manager session variables (for home.sessionPath, home.sessionVariables)
# cf. nix/home.nix home.sessionPath
if [ -f "/etc/profiles/per-user/${USER}/etc/profile.d/hm-session-vars.sh" ]; then
  source "/etc/profiles/per-user/${USER}/etc/profile.d/hm-session-vars.sh"
fi

# Local config (machine-specific, not version controlled)
if test -f ~/.zshenv.local; then
  source ~/.zshenv.local
fi
