# Storage Hygiene

This document describes the shared storage visibility, retention vocabulary, and
cleanup guardrails for issues `#123` and `#140`.

## 1. Linux Home Storage Report

Use the report to explain home-directory growth before you remove anything.

### 1.1. Self Summary

```sh
nix run '.#storage-report' -- --self --summary
```

This mode is safe for regular daily visibility. It inspects only the current
user home directory. On the Ubuntu target, the daily `storage-report` timer
rewrites the latest scheduled self report at
`${XDG_STATE_HOME:-~/.local/state}/storage-report/latest.log`.

### 1.2. All Linux Home Users

```sh
sudo nix run '.#storage-report' -- --all-users --summary
```

This mode enumerates Linux home directories under `/home`. It is intended for
host triage.

### 1.3. Output Sections

The report prints these sections:

- `SUMMARY`
- `USERS`
- `TOP ACTIONS`
- `NOTES`

### 1.4. User States

Each user home is reported with one of these states:

- `SCANNED`
- `SKIPPED`
- `UNREADABLE`

`SKIPPED` and `UNREADABLE` homes include a reason. They are never omitted
silently.

### 1.5. Cleanup Modes

- `safe_cache`
  Meaning: normally rebuildable caches
- `review_first`
  Meaning: inspect before removal
- `preserve`
  Meaning: do not remove by default

The report is Linux-only by design. It targets `/home` usage and the current
Ubuntu or WSL2 host. The `SUMMARY` line reports filesystem pressure for the
filesystem backing the scanned homes.

### 1.6. Retention Matrix

Use one vocabulary across docs and the Linux storage report.

| Storage Bucket | Typical Examples | Mode | Policy |
| -------------- | ---------------- | ---- | ------ |
| Low-risk rebuildable caches | uv cache, `~/.cache/pre-commit`, `~/.cache/ruff`, `~/.cache/go-build`, `~/.cache/nix`, `~/.npm` | `safe_cache` | Cleanup candidate through the explicit low-risk cache surface |
| Claude runtime state | `~/.claude` projects, todos, and runtime files | `review_first` | Keep Claude's built-in age-based cleanup and review before manual deletion |
| Codex lightweight history and config | `~/.codex/history.jsonl`, `~/.codex/config.toml`, hooks, handoffs, and other small control files | `review_first` | Keep separate from session retention; lightweight history settings do not replace rollout JSONL retention |
| Codex interactive session rollouts | `~/.codex/sessions/**/*.jsonl` | `review_first` | Keep about 50 days of closed rollout JSONL by file age, skip files still open in a live Codex process, and preserve the session data that `ccusage-codex` reads directly |
| Codex live TUI logs | `~/.codex/log/codex-tui.log` | `review_first` | Keep separate from rollout JSONL retention; any log cleanup stays a separate review-first decision |
| `tmux-a2a-postman` control-plane state | mailbox state, durable handoffs, and approval artifacts | `review_first` | Manual review only under this umbrella; no automatic age-based prune command |
| `vde-monitor` state | durable monitor state plus disposable pane logs | `review_first` | Preserve durable state by default; only `~/.vde-monitor/panes` is disposable and pruned on startup |
| Tool payloads outside the Nix store | `~/.local/share/mise`, `~/.local/lib`, `~/.net` | `review_first` | Review before removal or reinstall because these payloads may back active tools |
| Repo-local rebuildable artifacts | virtual environments, Terraform working directories, local build outputs | `review_first` | Decide per repo or project, not through host-wide cache cleanup |
| User-owned local data and repo clones | `~/.local` data outside the buckets above, `ghq` repos | `preserve` | Keep unless the operator intentionally removes them after review |

### 1.7. Claude Retention

Claude runtime state is `review_first`, not `safe_cache`.

- The repo uses Claude's built-in age-based cleanup instead of a separate
  custom prune command.
- `nix/home-manager/agents/claude-code.nix` sets
  `cleanupPeriodDays = 50;` as the bounded workstation default.
- The storage report should describe `~/.claude` with the same treatment:
  review first, with built-in 50-day cleanup already handling stale Claude
  sessions.

### 1.8. Codex Retention

Codex runtime state is also `review_first`, but it has three different storage
shapes that must not be collapsed into one cleanup rule.

- Lightweight Codex history and config controls such as
  `~/.codex/history.jsonl`, `config.toml`, hooks, and handoffs stay separate
  from session-rollout retention. Small history controls are not a substitute
  for session policy.
- Interactive session rollouts live under `~/.codex/sessions/**/*.jsonl`. The
  target policy is to keep about 50 days of closed rollout JSONL files. Any
  future cleanup must use file age, not just directory names, and must skip
  files that are still open by a live Codex process.
- `ccusage-codex` reads Codex session JSONL files directly from the sessions
  tree, so the 50-day window is an intentional compatibility boundary rather
  than an arbitrary cache rule.
- Live TUI logs such as `~/.codex/log/codex-tui.log` stay `review_first`, but
  they are not part of the 50-day session-rollout retention window.
- This follow-up still does not add a new Codex prune command. Any later
  cleanup automation must stay explicit, review-first, and narrower than the
  session/log split above.

### 1.9. `tmux-a2a-postman` And `vde-monitor`

`tmux-a2a-postman` and `vde-monitor` are both `review_first` under the shared
policy, but for different reasons.

- `tmux-a2a-postman` state is part of the control plane. It preserves mailbox
  continuity, durable handoffs, and approval evidence, so this umbrella policy
  does not define any age-based pruning for it.
- `vde-monitor` keeps durable monitor state, config, and notification files
  under `review_first`. Only the pane-log subtree under
  `~/.vde-monitor/panes` is disposable, and the VDE startup path prunes that
  subtree before `exec`-ing the monitor.

### 1.10. Tool Payloads And Repo-Local Rebuildables

Downloaded tool payloads outside the Nix store and repo-local rebuildable
artifacts are not `safe_cache` by default.

- Tool payloads such as `mise` installs, `~/.local/lib`, and `.net` should be
  reviewed before removal because they may back active runtimes or developer
  tools.
- Repo-local rebuildable artifacts such as virtual environments, Terraform
  working directories, and similar outputs should be handled inside the owning
  repo after confirming they are disposable.

### 1.11. Low-Risk Cache Cleanup

Use the cleanup app for rebuildable user caches that do not need manual review.

```sh
nix run '.#cleanup'
```

The cleanup app currently prunes:

- the uv cache
- `~/.cache/pre-commit`
- `~/.cache/ruff`
- `~/.cache/go-build`
- `~/.cache/nix`
- `~/.npm`

This is the safest immediate reclaim path for user-owned cache pressure.

## 2. Guarded GC-Root Delete

Use the single delete-focused command surface to remove stale auto GC roots.

### 2.1. Command

```sh
nix run '.#gc-roots-delete'
```

The interface has no flags. It attempts current-user unlink directly and never
asks for escalation. Every invocation re-classifies roots as:

- `KEEP`
- `CANDIDATE`
- `BLOCKED`

Each line includes a reason, the auto-root path, the original linked path, and
the resolved target. The command unlinks only current `CANDIDATE` auto-root
symlinks that the current user can delete, prints a `WARNING` for roots that
cannot be removed, and then runs `nix-collect-garbage`.

### 2.2. Protected Root Classes

These roots stay `BLOCKED` in issue `#123`:

- Home Manager `current-home` gcroots under
  `~/.local/state/home-manager/gcroots/current-home`
- `.direnv`
- `result`
- `/tmp`

Home Manager generation links such as `home-manager-*` and profile generation
links such as `profile-*` stay `KEEP`.

### 2.3. Operator Notes

- This delete surface is explicit and never scheduled.
- It re-runs the classification and active-worktree checks at execution time.
- It has no preview mode and no flag-based delete switch.
- It attempts deletion as the current user and keeps going when a specific root
  cannot be removed.

## 3. Swap Consolidation

The host has two swap devices: `/swapfile` (16G) and `/swap.img` (8G). Only
one is needed. `setup-swap.sh` refuses to run when more than one swap device is
active. It does not disable duplicate swap devices, rewrite `/etc/fstab`, or
delete `/swap.img` automatically.

Manual consolidation steps (all require root):

1. Confirm active swap devices: `cat /proc/swaps`
2. Choose the device to keep (prefer `/swapfile` at `16G`)
3. Disable `/swap.img` with `swapoff /swap.img`
4. Remove the `/swap.img` entry from `/etc/fstab`
5. Delete `/swap.img`
6. Verify: `cat /proc/swaps` should show exactly one device
7. Re-run `setup-swap.sh`

After consolidation, `setup-swap.sh` can run normally.
