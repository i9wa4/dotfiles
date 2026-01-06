_: {
  # Git configuration (replaces Makefile git-config target)
  # Note: user.name, user.email are PC-specific, set via `git config --global`
  # They will be written to ~/.gitconfig which takes precedence
  programs.git = {
    enable = true;
    ignores = [
      ".DS_Store"
      ".direnv/"
      ".env"
      "node_modules/"
      ".zshenv.local"
      ".zshrc.local"
      # dotfiles
      ".i9wa4/"
      "local.vim"
      # Claude
      ".mcp.json"
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
      user.signingkey = "~/.ssh/github.pub";
    };
  };
}
