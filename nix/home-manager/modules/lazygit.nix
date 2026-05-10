_: {
  # Lazygit configuration (terminal UI for git)
  # cf. https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
  programs.lazygit.enable = true;

  # Keep long custom commands readable in the generated YAML.
  xdg.configFile."lazygit/config.yml".text = ''
    gui:
      scrollHeight: 15

    customCommands:
      - key: <c-g>
        context: files
        output: terminal
        command: |
          editor=$(mktemp /tmp/lazygit-ai-commit-editor.XXXXXX)
          staged_diff=$(mktemp /tmp/lazygit-ai-commit-staged-diff.XXXXXX)
          ai_message=$(mktemp /tmp/lazygit-ai-commit-ai-message.XXXXXX)
          ai_status=$(mktemp /tmp/lazygit-ai-commit-ai-status.XXXXXX)
          ai_stderr=$(mktemp /tmp/lazygit-ai-commit-ai-stderr.XXXXXX)
          ai_pid=

          cleanup() {
            if [ -n "$ai_pid" ] && kill -0 "$ai_pid" >/dev/null 2>&1; then
              kill "$ai_pid" >/dev/null 2>&1 || true
              wait "$ai_pid" >/dev/null 2>&1 || true
            fi
            rm -f "$editor" "$staged_diff" "$ai_message" "$ai_status" "$ai_stderr"
          }
          trap cleanup EXIT INT TERM

          git diff --cached --no-ext-diff >"$staged_diff"

          cat >"$editor" <<'AI_COMMIT_EDITOR'
          #!/usr/bin/env bash
          set -u

          msg_file=$1
          ai_message=$LAZYGIT_AI_COMMIT_MESSAGE
          ai_status=$LAZYGIT_AI_COMMIT_STATUS

          while [ ! -s "$ai_status" ]; do
            sleep 0.1
          done

          if [ -s "$ai_message" ]; then
            buffer=$(mktemp /tmp/lazygit-ai-commit-editor-buffer.XXXXXX)
            {
              head -n 1 "$ai_message"
              printf '\n'
              cat "$msg_file"
            } >"$buffer"
            cat "$buffer" >"$msg_file"
            rm -f "$buffer"
          elif ! grep -qx 'ok' "$ai_status"; then
            cat "$ai_status" >&2
          fi

          exec vim "$msg_file"
          AI_COMMIT_EDITOR

          chmod +x "$editor"

          if command -v codex >/dev/null 2>&1; then
            {
              prompt='Generate ONLY a one-line Git commit message following Conventional Commits format (type(scope): description). Types: feat, fix, docs, style, refactor, test, chore. Based strictly on the diff from stdin. Output ONLY the message, nothing else.'
              if codex exec -m gpt-5.4-mini --ephemeral --ignore-rules --sandbox read-only -c approval_policy='"never"' -c model_reasoning_effort='"low"' --color never --output-last-message "$ai_message" "$prompt" <"$staged_diff" >/dev/null 2>"$ai_stderr"; then
                msg=$(head -n 1 "$ai_message")
                if [ -n "$msg" ]; then
                  printf '%s\n' "$msg" >"$ai_message"
                  printf '%s\n' 'ok' >"$ai_status"
                else
                  printf '%s\n' 'AI commit message generation returned an empty message; opening editor without AI message.' >"$ai_status"
                fi
              else
                printf '%s\n' 'AI commit message generation failed; opening editor without AI message.' >"$ai_status"
              fi
            } &
            ai_pid=$!
          else
            printf '%s\n' 'codex not found; opening editor without AI message.' >"$ai_status"
          fi

          LAZYGIT_AI_COMMIT_MESSAGE="$ai_message" \
          LAZYGIT_AI_COMMIT_STATUS="$ai_status" \
          GIT_EDITOR="$editor" \
            git commit
  '';
}
