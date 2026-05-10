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
          command = ''
            editor=$(mktemp /tmp/lazygit-ai-commit-editor-XXXXXX)
            trap 'rm -f "$editor"' EXIT

            cat >"$editor" <<'AI_COMMIT_EDITOR'
            #!/usr/bin/env bash
            set -u

            msg_file=$1
            prompt='Generate ONLY a one-line Git commit message following Conventional Commits format (type(scope): description). Types: feat, fix, docs, style, refactor, test, chore. Based strictly on the diff from stdin. Output ONLY the message, nothing else.'

            if command -v claude >/dev/null 2>&1; then
              if msg=$(git diff --cached --no-ext-diff | claude --no-session-persistence --print --model haiku "$prompt"); then
                msg=$(printf '%s\n' "$msg" | head -n 1)
                if [ -n "$msg" ]; then
                  tmp=$(mktemp /tmp/lazygit-ai-commit-msg-XXXXXX)
                  {
                    printf '%s\n\n' "$msg"
                    cat "$msg_file"
                  } >"$tmp"
                  cat "$tmp" >"$msg_file"
                  rm -f "$tmp"
                fi
              else
                printf '%s\n' 'AI commit message generation failed; opening editor without AI message.' >&2
              fi
            else
              printf '%s\n' 'claude not found; opening editor without AI message.' >&2
            fi

            exec vim "$msg_file"
            AI_COMMIT_EDITOR

            chmod +x "$editor"
            GIT_EDITOR="$editor" git commit
          '';
        }
      ];
    };
  };
}
