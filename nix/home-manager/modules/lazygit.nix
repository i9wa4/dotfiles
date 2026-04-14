_: {
  # Lazygit configuration (terminal UI for git)
  # cf. https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
  programs.lazygit = {
    enable = true;
    settings = {
      gui.scrollHeight = 15;
      customCommands = [
        {
          key = "<c-g>";
          context = "files";
          output = "terminal";
          command = "TMP_INDEX=$(mktemp /tmp/lazygit-index-XXXXXX) && trap 'rm -f \"$TMP_INDEX\"' EXIT && cp \"$(git rev-parse --git-path index)\" \"$TMP_INDEX\" && MSG=$(GIT_INDEX_FILE=\"$TMP_INDEX\" git diff --cached | claude --no-session-persistence --print --model haiku 'Generate ONLY a one-line Git commit message following Conventional Commits format (type(scope): description). Types: feat, fix, docs, style, refactor, test, chore. Based strictly on the diff from stdin. Output ONLY the message, nothing else.') && GIT_INDEX_FILE=\"$TMP_INDEX\" git commit -e -m \"$MSG\"";
        }
      ];
    };
  };
}
