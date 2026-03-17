{
  config,
  lib,
  ...
}:
let
  dotfilesDir = "${config.home.homeDirectory}/ghq/github.com/i9wa4/dotfiles";
in
{
  # Git configuration (replaces Makefile git-config target)
  # Note: user.name, user.email are PC-specific, set via `git config --global`
  # They will be written to ~/.gitconfig which takes precedence
  programs.git = {
    enable = true;
    ignores = [
      ".DS_Store"
      ".direnv/"
      ".env"
      ".envrc"
      ".zshenv.local"
      ".zshrc.local"
      "node_modules/"
      # dotfiles
      ".i9wa4/"
      ".worktrees/"
      "local.vim"
      # Nix
      "result"
      # Python
      ".ipynb_checkpoints/"
      ".virtual_documents/"
    ];
    settings = {
      color.ui = "auto";
      commit = {
        gpgsign = true;
        verbose = true;
      };
      core = {
        autocrlf = "input";
        commentChar = ";";
        editor = "vim";
        ignorecase = false;
        pager = "LESSCHARSET=utf-8 less";
        quotepath = false;
        safecrlf = true;
      };
      credential.helper = "store";
      diff = {
        algorithm = "histogram";
        compactionHeuristic = true;
        tool = "vimdiff";
      };
      difftool = {
        prompt = false;
        vimdiff.path = "vim";
      };
      fetch.prune = true;
      ghq.root = "~/ghq";
      gpg.format = "ssh";
      grep.lineNumber = true;
      http.sslVerify = false;
      init.defaultBranch = "main";
      merge = {
        conflictstyle = "diff3";
        tool = "vimdiff";
      };
      mergetool = {
        prompt = false;
        vimdiff.path = "vim";
      };
      push.default = "current";
      submodule.recurse = true;
      "url \"git@github.com:\"".insteadOf = "https://github.com/";
      user.signingkey = "~/.ssh/github.pub";
    };
  };

  # Write repo-local .git/info/exclude for dotfiles repo
  # (global gitignore cannot target a specific file in a specific repo)
  home.activation.dotfilesGitExclude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${dotfilesDir}/.git" ]; then
      echo '.pre-commit-config.yaml' > "${dotfilesDir}/.git/info/exclude"
    fi
  '';
}
