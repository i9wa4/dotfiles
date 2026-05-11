# Boot Failure Modes

Failure modes, root causes, and mitigations for agent-driven workspace boot.
Source context: empirical 2026-05-08 observation.

## 1. Timing Race: zsh Not Ready When `z` Injected

**Root cause:** `__z_tmux_rename_for_dir` is defined in `config/zsh/zoxide.zsh`,
sourced via `nix/home-manager/modules/zsh.nix`, near the end of interactive zsh
initialization. A fresh tmux pane needs more time than a 2s wait for zsh init
and zoxide.zsh sourcing.

**Symptom:** Session retains its numeric default name (e.g., `4`). `z` command
executes but `__z_tmux_rename_for_dir` is not yet defined, so the session rename
does not fire. Interactive snippet widgets can fail for the same reason if they
have not been sourced yet.

**Empirical evidence:** A 2s wait before injecting `z i9wa4.github.io` failed to
trigger `__z_tmux_rename_for_dir`; session remained numbered. After full zsh
init completed, `type __z_tmux_rename_for_dir` confirmed the function was
available from `dotfiles/config/zsh/zoxide.zsh`.

**Mitigation:** Use a minimum 5s sleep after `tmux new-session` before sending
`z <dir>`. Verify session rename with
`tmux display-message -t <pane> -p '#{session_name}'` before proceeding. If
rename has not fired, wait an additional 3-5s and recheck.

**Example diagnostic command:**

```bash
tmux send-keys -t "$PANE_ID" "type __z_tmux_rename_for_dir" Enter
sleep 2 && tmux capture-pane -t "$PANE_ID" -p | tail -5
```

## 2. Interactive Snippet Injection Failure

**Root cause:** `snippet-magic-space` is a ZLE widget registered via
`bindkey " " snippet-magic-space` (`config/zsh/snippet.zsh`). ZLE widgets only
fire after the target pane has finished zsh initialization and is sitting at an
interactive prompt. `tmux send-keys` injects keystrokes into a pane's input
buffer, so snippet expansion is not a reliable automation boundary.

**Symptom:** Sending `va` then Space via `tmux send-keys` does not expand to
`vde-layout messenger-codex && vde-layout preset-a`; the literal characters
`va` are sent.

**Mitigation:** Use direct vde-layout invocation for all agent-driven
automation:

```bash
tmux send-keys -t "$PANE_ID" 'vde-layout messenger-codex && vde-layout preset-a' Enter
```

This produces identical end state to the interactive snippet path.

## 3. Delayed Session Rename

**Root cause:** `__z_tmux_rename_for_dir` fires asynchronously as part of the
chpwd hook chain. In a freshly-initialized pane, even after a `z <dir>` that
succeeds in cd-ing to the directory, the rename may arrive a few seconds later
as the hook completes.

**Symptom:** `tmux display-message -p '#{session_name}'` immediately after
`z <dir>` still shows the old name; checking again 4-5s later shows the correct
renamed session.

**Mitigation:** Wait 3-4s after sending `z <dir>` before checking session name.

## 4. Postman Status Visibility Lag

**Root cause:** tmux-a2a-postman status can lag briefly behind freshly-created
tmux panes because pane discovery is asynchronous.

**Symptom:** `tmux-a2a-postman get-status` does not list the newly-created
session's panes even though `tmux list-panes -a` shows them correctly.

**Mitigation:** Wait briefly and retry `tmux-a2a-postman get-status`.
`tmux list-sessions` is authoritative for session existence — use it rather than
postman status for session confirmation. Do not run infrastructure repair or
low-level checks from this workspace skill.

## 5. WAL Bloat from Codex Multi-Pane Sessions

**Root cause:** Each codex pane appends to `~/.codex/logs_2.sqlite-wal`. With
6-7 codex panes active, WAL files grow rapidly.
`PRAGMA wal_checkpoint(TRUNCATE)` cannot truncate while live `.codex-wr`
processes hold the WAL open.

**Symptom:** Disk space consumed by `~/.codex/logs_2.sqlite-wal`; checkpoint
truncation fails.

**Mitigation:** Cross-reference
`skills/agent-harness-engineering/references/codex-cli.md` WAL runbook. Do not
reproduce the runbook here.
