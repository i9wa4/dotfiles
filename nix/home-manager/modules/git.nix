{
  ghqRoot,
  lib,
  dotfilesDir,
  ...
}:
{
  # Git configuration (replaces Makefile git-config target)
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
      ".tmux-a2a-postman/"
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
      branch.sort = "-committerdate";
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
      fetch = {
        prune = true;
        pruneTags = true;
      };
      ghq.root = ghqRoot;
      gpg.format = "ssh";
      grep.lineNumber = true;
      http.sslVerify = true;
      init.defaultBranch = "main";
      merge = {
        conflictstyle = "diff3";
        tool = "vimdiff";
      };
      mergetool = {
        prompt = false;
        vimdiff.path = "vim";
      };
      push = {
        autoSetupRemote = true;
        default = "upstream";
      };
      pull.ff = "only";
      rebase.autoStash = true;
      rerere.enabled = true;
      submodule.recurse = true;
      tag.sort = "version:refname";
      "url \"git@github.com:\"".insteadOf = "https://github.com/";
      user = {
        email = "127664533+i9wa4@users.noreply.github.com";
        name = "uma-chan";
        signingkey = "~/.ssh/github.pub";
      };
    };
  };

  # Write repo-local .git/info/exclude for dotfiles repo
  # (global gitignore cannot target a specific file in a specific repo)
  home.activation.dotfilesGitExclude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${dotfilesDir}/.git" ]; then
      exclude_file="${dotfilesDir}/.git/info/exclude"
      touch "$exclude_file"

      for pattern in \
        '.pre-commit-config.yaml' \
        '.worktrees/'
      do
        if ! grep -Fxq "$pattern" "$exclude_file"; then
          printf '%s\n' "$pattern" >> "$exclude_file"
        fi
      done
    fi
  '';
}
