# Boot Failure Modes

Failure modes, root causes, and mitigations for agent-driven workspace boot.
Source context: `plans/vb-boot-demo-BeQB9I.md` (empirical 2026-05-08
observation).

## 1. Timing Race: zinit Not Ready When `z` Injected

**Root cause:** `__z_tmux_rename_for_dir` is defined in `config/zsh/zoxide.zsh`,
sourced via `nix/home-manager/modules/zsh.nix:138`, after the full zinit turbo
atload cycle completes. A fresh tmux pane needs more time than a 2s wait for zsh
init + zinit plugin loading + zoxide.zsh sourcing.

**Symptom:** Session retains its numeric default name (e.g., `4`). `z` command
executes but `__z_tmux_rename_for_dir` is not yet defined, so the session rename
does not fire. Subsequent zeno snippets also fail for the same reason
(`$ZENO_LOADED` not yet set).

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

## 2. Zeno Snippet Injection Failure

**Root cause:** `zeno-auto-snippet` is a ZLE widget registered via
`bindkey " " zeno-auto-snippet` (`config/zsh/zinit.zsh:44`). ZLE widgets only
fire in interactive zsh with `$ZENO_LOADED` set. `tmux send-keys` injects
keystrokes into a pane's input buffer, but the pane is not running an
interactive ZLE session in the context of the injecting shell — the widget does
not reliably fire.

**Symptom:** Sending `vb` then Space via `tmux send-keys` does not expand to
`vde-layout messenger-codex && vde-layout preset-b`; the literal characters
`vb` are sent.

**Mitigation:** Use direct vde-layout invocation for all agent-driven
automation:

```bash
tmux send-keys -t "$PANE_ID" 'vde-layout messenger-codex && vde-layout preset-b' Enter
```

This produces identical end state to the zeno snippet path.

## 3. Delayed Session Rename

**Root cause:** `__z_tmux_rename_for_dir` fires asynchronously as part of the
chpwd hook chain. In a freshly-initialized pane, even after a `z <dir>` that
succeeds in cd-ing to the directory, the rename may arrive a few seconds later
as the hook completes.

**Symptom:** `tmux display-message -p '#{session_name}'` immediately after
`z <dir>` still shows the old name; checking again 4-5s later shows the correct
renamed session.

**Mitigation:** Wait 3-4s after sending `z <dir>` before checking session name.

## 4. Auto-Ping Daemon Unreliability

**Root cause:** The tmux-a2a-postman daemon's routing table is built from
detected pane titles. A freshly-booted session may not be scanned by the daemon
before its next health cycle.

**Symptom:** `tmux-a2a-postman get-status` does not list the newly-created
session's panes even though `tmux list-panes -a` shows them correctly.

**Mitigation:** Check daemon health explicitly; wait and retry.
`tmux list-sessions` is authoritative for session existence — use it rather than
postman status for session confirmation.

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
