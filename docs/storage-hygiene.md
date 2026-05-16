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

For agents, the internal `storage-hygiene` skill is the operational entrypoint.
Its storage-report bridge executes this same report implementation so
`nix run '.#storage-report'` remains the stable user-facing command.

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

| Storage Bucket                         | Typical Examples                                                                                 | Mode           | Policy                                                                                                                                                                                                                                        |
| -------------------------------------- | ------------------------------------------------------------------------------------------------ | -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Low-risk rebuildable caches            | uv cache, `~/.cache/pre-commit`, `~/.cache/ruff`, `~/.cache/go-build`, `~/.cache/nix`, `~/.npm`  | `safe_cache`   | Cleanup candidate through the explicit low-risk cache surface                                                                                                                                                                                 |
| Claude runtime state                   | `~/.claude` projects, todos, and runtime files                                                   | `review_first` | Keep Claude's built-in age-based cleanup and review before manual deletion                                                                                                                                                                    |
| Codex lightweight history and config   | `~/.codex/history.jsonl`, `~/.codex/config.toml`, hooks, handoffs, and other small control files | `review_first` | Keep separate from session retention; lightweight history settings do not replace rollout JSONL retention                                                                                                                                     |
| Codex interactive session rollouts     | `~/.codex/sessions/**/*.jsonl`                                                                   | `review_first` | Keep about 50 days of closed rollout JSONL by file age, skip files still open in a live Codex process, and preserve the session data that `ccusage-codex` reads directly; the Linux Codex storage-pressure timer enforces this default window |
| Codex SQLite state and WAL files       | `~/.codex/logs_*.sqlite*`, `~/.codex/state_*.sqlite*`                                            | `review_first` | Never delete SQLite files; use SQLite checkpoint first. The managed pressure timer truncates a large WAL whenever it crosses the pressure threshold and logs whether SQLite proved a full checkpoint                                          |
| Codex live TUI logs                    | `~/.codex/log/codex-tui.log`                                                                     | `review_first` | Keep separate from rollout JSONL retention; any log cleanup stays a separate review-first decision                                                                                                                                            |
| `tmux-a2a-postman` control-plane state | mailbox state, durable handoffs, and approval artifacts                                          | `review_first` | Manual review only under this umbrella; no automatic age-based prune command                                                                                                                                                                  |
| `vde-monitor` state                    | durable monitor state plus disposable pane logs                                                  | `review_first` | Preserve durable state by default; only `~/.vde-monitor/panes` is disposable and pruned on startup                                                                                                                                            |
| Tool payloads outside the Nix store    | `~/.local/share/mise`, `~/.local/lib`, `~/.net`                                                  | `review_first` | Review before removal or reinstall because these payloads may back active tools                                                                                                                                                               |
| Repo-local rebuildable artifacts       | virtual environments, Terraform working directories, local build outputs                         | `review_first` | Decide per repo or project, not through host-wide cache cleanup                                                                                                                                                                               |
| Temporary cleanup quarantines          | `/tmp/*cleanup*`, dated move-aside directories                                                   | `review_first` | Same-filesystem quarantine reduces source-tree size but does not increase global free space until explicitly removed after verification                                                                                                       |
| User-owned local data and repo clones  | `~/.local` data outside the buckets above, `ghq` repos                                           | `preserve`     | Keep unless the operator intentionally removes them after review                                                                                                                                                                              |

### 1.7. Claude Retention

Claude runtime state is `review_first`, not `safe_cache`.

- The repo uses Claude's built-in age-based cleanup instead of a separate
  custom prune command.
- `nix/home-manager/agents/claude/default.nix` sets
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
  Nix-managed Linux storage-pressure timer keeps about 50 days of closed
  rollout JSONL files by file age, not directory names, and skips files that
  are still open by a live Codex process.
- `ccusage-codex` reads Codex session JSONL files directly from the sessions
  tree, so the 50-day window is an intentional compatibility boundary rather
  than an arbitrary cache rule.
- SQLite state and WAL files under `~/.codex`, including `logs_*.sqlite*` and
  `state_*.sqlite*`, are live database state. A large WAL is a maintenance
  signal, not a delete target. The managed hourly checkpoint is safe while
  Codex is active. The pressure-relief timer logs Codex holder PIDs when a
  large WAL remains under pressure, attempts a SQLite checkpoint, then
  truncates the WAL whenever it remains over the pressure threshold. If SQLite
  cannot prove all frames were checkpointed, the timer logs that it is
  truncating by policy without full-checkpoint proof. Process lifecycle stays
  outside the timer.
- For manual maintenance, prefer a quiet period after closing nonessential
  Codex panes. Manual live WAL truncation should stay an operator-directed
  emergency action with captured evidence.
- If SQLite files were deleted while Codex was running, assume the process may
  still hold deleted-open file handles. Check with `lsof +L1` before declaring
  disk reclaimed. The safe recovery path is to finish or preserve active
  conversations, record exact holder PIDs, and defer any process-lifecycle
  decision outside this managed storage path.
- The managed storage-pressure path reports holder PIDs and truncates a large
  WAL whenever the pressure threshold is crossed. It does not manage Codex
  processes.
- Clearly disposable Codex state is limited to small non-live cache/temp
  contents and closed session JSONL files outside the retention window. Preserve
  credentials, `config.toml`, active sessions, `history.jsonl`, hooks, skills,
  memories, handoffs, and session data needed by accounting tools.
- Live TUI logs such as `~/.codex/log/codex-tui.log` stay `review_first`, but
  they are not part of the 50-day session-rollout retention window.
- The internal `storage-hygiene` skill still provides a manual dry-run-first
  Codex session JSONL pruning helper for ad hoc checks. The scheduled Linux
  harness path is `codex-storage-pressure-relief.timer`.

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
- For `ghq` cleanup, use an explicit candidate list. Typical generated paths
  include `.venv`, `.terraform`, `.databricks`, `.mypy_cache`, and `target`.
  Confirm repo or worktree status before moving or deleting anything, and skip
  dirty subtrees unless the changed files are already understood.
- `.git` directories are not cleanup targets. In clean repos, plain `git gc` is
  the conservative maintenance surface. Avoid `git gc --aggressive`,
  `--prune=now`, history rewrites, and any operation in repos with dirty
  worktrees, linked-worktree lock files, or unclear ownership.
- If the local safety hook denies deletion, stop and report the denial rather
  than retrying with a different destructive command. Moving explicit generated
  paths to a dated quarantine can reduce a source tree, but it only frees the
  filesystem after the quarantine itself is approved for removal.

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

### 1.12. Storage-Pressure Incident Runbook

Use this runbook when `/` or the filesystem backing `/home` is close to full.
The default mode is read-only measurement. Run cleanup, process restart, swap
resize, Nix GC, or deletion only after the user approves that exact action.

#### 1.12.1. Triage Order

1. Confirm which filesystem is under pressure.

   ```sh
   df -h /
   df -B1 /
   findmnt -no SOURCE,TARGET,FSTYPE,OPTIONS /
   findmnt -R -n -o TARGET,SOURCE,FSTYPE,SIZE,USED,AVAIL,USE% /
   ```

2. Capture current-user home pressure.

   ```sh
   nix run '.#storage-report' -- --self --summary
   ```

3. If the host has multiple Linux users, capture the all-users summary. This is
   a read-only triage command, but it uses `sudo` so the operator can see every
   `/home` owner.

   ```sh
   sudo nix run '.#storage-report' -- --all-users --summary
   ```

4. Capture bounded root-accounting data. Keep the timeout; broad recursive
   `du /nix` or `du /nix/store` can stall a live incident.

   ```sh
   find / -xdev -maxdepth 1 -mindepth 1 -printf '%p\n' | sort
   timeout 90s nice -n 19 du -sxh \
     /home /tmp /usr /var /etc /boot /opt /srv /snap /mnt /media \
     /nix/var /nix/store/.links /swapfile 2>/dev/null
   ```

5. Capture deleted-open pressure before concluding that `du` and `df` disagree.

   ```sh
   timeout 25s lsof -nP +L1 2>/dev/null |
     awk '$7 ~ /^[0-9]+$/ {count++; sum += $7; bycmd[$1] += $7; bycmdc[$1]++}
       END {
         print "total_count", count, "total_bytes", sum;
         for (cmd in bycmd) print "cmd", cmd, "count", bycmdc[cmd], "bytes", bycmd[cmd]
       }' |
     sort
   ```

6. Rank actions by safety and expected reclaim. Prefer explicit repo-managed
   surfaces before ad hoc deletion.

7. Re-measure `df`, the affected bucket, and deleted-open handles after every
   approved action.

#### 1.12.2. Root `df` Accounting

`df` reports allocated blocks on the filesystem. Directory `du` reports visible
files that can be traversed. The two views differ for normal reasons:

- deleted-open files still count in `df` until the owning process closes the
  handle
- ext4 reserved blocks reduce `Available` even though they are not `df Used`
- hardlinks and Nix store structure can make simple `du` sums misleading
- permission-limited paths and live writes can move numbers during measurement

Use this accounting frame for incident notes:

```text
remaining_gap = df_used_bytes - measured_visible_paths_bytes - visible_deleted_open_bytes
```

The gap is not a delete target. It is a signal to keep measuring likely
contributors, usually Nix store paths, deleted-open handles, root-owned data,
or live writes.

#### 1.12.3. Deleted-Open Handles

Deleted-open files are already unlinked from the directory tree, so deleting
new replacement files does not reclaim the old space. The reclaim happens only
when the process holding the old handle exits or closes it.

For Codex and Claude, preserve active work first. The managed storage-relief
path reports deleted-open holders only.

Read-only checks:

```sh
lsof ~/.codex/logs_*.sqlite-wal 2>/dev/null
lsof ~/.codex/state_*.sqlite-wal 2>/dev/null
timeout 25s lsof -nP +L1 2>/dev/null
```

Recheck after any later operator-led remediation:

```sh
df -h /
timeout 25s lsof -nP +L1 2>/dev/null
```

#### 1.12.4. `/tmp` Quarantine Rules

Moving generated project artifacts into a dated `/tmp` quarantine can make a
repo tree smaller and easier to inspect. It does not free root filesystem space
when `/tmp` is on the same filesystem as the source path.

Read-only checks:

```sh
df -h / /tmp "$HOME"
findmnt -no SOURCE,TARGET,FSTYPE,OPTIONS --target /
findmnt -no SOURCE,TARGET,FSTYPE,OPTIONS --target /tmp
findmnt -no SOURCE,TARGET,FSTYPE,OPTIONS --target "$HOME"
find /tmp -maxdepth 1 -type d -name '*cleanup*' -print
```

Use quarantine only for explicit generated paths after checking the owning repo
status. Give each quarantine an owner, reason, and expiry path. Delete the
quarantine only as a separately approved cleanup action.

#### 1.12.5. Agent Runtime Retention

Treat agent runtime state as `review_first` unless a narrower policy says
otherwise.

- Codex session JSONL retention is about 50 days for closed rollouts. Skip
  files open by live Codex processes and preserve data used by accounting
  tools.
- Codex SQLite databases and WAL files are live state. Do not delete or
  manually truncate them while `lsof` shows active writers. SQLite checkpoint
  is the managed safe maintenance surface; compaction remains a quiet-period
  manual task.
- Claude uses its configured age-based cleanup window. Review before manual
  deletion.
- `tmux-a2a-postman` state is control-plane evidence. Review old contexts
  manually and preserve the active context.
- `vde-monitor` durable state is preserved. Only its pane-log subtree is
  disposable through the monitor's own startup pruning.

#### 1.12.6. Nix Generations And GC Roots

Do not delete `/nix/store`, `/nix/store/.links`, `/nix/var/nix/gcroots`, or
profile symlinks by hand. The Nix store is a graph, and direct deletion can
break active profiles or builds.

Read-only checks:

```sh
nix profile history \
  --profile "$HOME/.local/state/nix/profiles/profile" 2>/dev/null || true
find /nix/var/nix/profiles -maxdepth 3 -type l 2>/dev/null | wc -l
find "$HOME/.local/state/nix/profiles" -maxdepth 1 -type l 2>/dev/null | wc -l
find /nix/var/nix/gcroots -maxdepth 3 -type l 2>/dev/null | head -50
```

Approved action only, after the retention policy is known:

```sh
nix run '.#gc-roots-delete'
```

For normal daily maintenance, prefer the repo's switch/update flow and the
explicit GC-root delete surface. Do not use ad hoc `rm` under `/nix`.

#### 1.12.7. `/home` Ownership

Each `/home/<user>` tree belongs to that user. Measure all homes during host
triage, but do not delete another user's data, change ownership, or move their
repositories without owner approval.

Read-only checks:

```sh
sudo nix run '.#storage-report' -- --all-users --summary
sudo find /home -mindepth 1 -maxdepth 1 -printf '%p owner=%u group=%g mode=%m\n'
```

If a home is `SKIPPED` or `UNREADABLE`, record that state. Do not silently
exclude it from the incident summary.

#### 1.12.8. What Not To Delete

Do not delete these during first response:

- `/nix/store` paths, `/nix/store/.links`, or Nix gcroots by hand
- `.git` directories, Git object stores, worktree admin directories, or linked
  worktree lock files
- active Codex or Claude SQLite databases, WAL files, credentials, config,
  active sessions, or live logs
- `tmux-a2a-postman` active mailbox state or current durable handoff artifacts
- user data under another `/home/<user>` tree without owner approval
- same-filesystem `/tmp` quarantine directories unless their deletion is the
  explicit approved action
- swap files or `/etc/fstab` entries outside the managed swap runbook

#### 1.12.9. Approved Immediate Reclaim Surfaces

Use these only after the user approves the exact action.

Low-risk rebuildable cache cleanup:

```sh
nix run '.#cleanup'
```

Guarded stale GC-root cleanup:

```sh
nix run '.#gc-roots-delete'
```

Managed swap reduction from 16GiB to 8GiB:

```sh
sudo bash ./bin/ubuntu/setup-swap.sh
```

The swap command is approved only as part of the section 4 runbook.

### 1.13. Durable Prevention

Use one-off deletion only to exit the emergency. The durable controls are:

- Keep the scheduled `storage-report` output visible and review it before the
  filesystem reaches critical pressure.
- Add alerting or a manual checkpoint at warning thresholds such as 90%, 95%,
  and 98% used.
- Track Codex WAL size separately from Codex session JSONL retention. The
  managed `codex-wal-checkpoint` and `codex-storage-pressure-relief` systemd
  timers are the durable Linux controls for WAL growth and pressure response.
- Keep closed Codex rollout cleanup aligned with the 50-day compatibility
  window and always skip live-open files; the Linux pressure timer enforces
  that default window.
- Review `tmux-a2a-postman` state manually as control-plane evidence rather
  than applying automatic pruning.
- Avoid duplicated generated environments by fixing the process that recreates
  `.venv` directories, and prefer shared tool caches where the project allows
  it.
- Give cleanup quarantines an owner and expiration path so dated move-aside
  directories do not become permanent hidden storage.
- Check Ubuntu root LVM allocation after install. If `/` is still a small LV
  while the VG has free extents, extend it before treating normal usage as a
  storage-pressure incident.
- Use explicit Nix cleanup surfaces, such as the daily switch flow and
  `nix run '.#gc-roots-delete'`, instead of deleting Nix store paths directly.

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

## 3. Ubuntu Root LVM Expansion

Ubuntu's installer can create an LVM physical volume that spans the disk while
leaving the root logical volume at 100G. In that state, `/` can appear under
pressure even though the volume group still has hundreds of GiB unallocated.

### 3.1. Read-Only Check

Use the managed check from the dotfiles repo root:

```sh
sudo bash ./bin/ubuntu/extend-root-lvm.sh --check
```

The equivalent raw checks are:

```sh
lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS
df -hT /
sudo vgs --units g
sudo lvs --units g
sudo pvs --units g
```

The expected expandable shape is:

- `/` is mounted from an LVM logical volume such as
  `/dev/mapper/ubuntu--vg-ubuntu--lv`.
- `df -hT /` shows a root filesystem much smaller than the disk.
- `vgs` shows non-zero `VFree`.

If the physical volume or partition itself is too small, this helper is not
the right tool. Resize the partition/PV first, then re-run the check.

### 3.2. Approved Apply Path

After reviewing the target VG/LV, run the managed helper:

```sh
sudo bash ./bin/ubuntu/extend-root-lvm.sh --apply
```

The helper runs `lvextend -r -l +100%FREE` on the root LV. The `-r` flag grows
the filesystem along with the logical volume.

Raw fallback for an operator who has already reviewed that `/` is on LVM:

```sh
sudo lvextend -r -l +100%FREE "$(findmnt -n -o SOURCE /)"
```

### 3.3. Verification

After the apply path, verify that root now consumes the expected space and the
VG no longer has the previously unallocated extents:

```sh
df -hT /
lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS
sudo lvs --units g
sudo vgs --units g
```

### 3.4. Guardrails

- Run this only when `/` is on LVM and the root VG has free extents.
- This does not repartition a disk, grow a PV, or move data between disks.
- Use the managed helper for the live mutation so the filesystem resize is
  paired with the LV resize.
- If the host is not using LVM, resolve capacity with that host's partitioning
  scheme instead of forcing this runbook.

## 4. Managed Swapfile

The managed Ubuntu swap target is `/swapfile` at `8G`. This is the default
storage-priority setting for machines with enough RAM and no hibernation
requirement. A `16G` swapfile remains a conservative option for hosts where
maximum OOM margin matters more than reclaiming disk; make that policy choice
as a reviewed patch to `SWAP_SIZE_GB` before running the helper.

`setup-swap.sh` is the only managed live mutation path for this swapfile. It
refuses to run when more than one swap device is active. It does not disable
duplicate swap devices, rewrite unrelated swap entries, or delete `/swap.img`
automatically.

### 4.1. Approval Gate

Do not run the live resize path until the user has explicitly approved the
patch and the planned host operation. The helper may run `swapoff`, recreate
`/swapfile`, run `mkswap`, run `swapon`, and rewrite the `/swapfile` entry in
`/etc/fstab`.

Before approval, the safe validation surface is static only:

```sh
bash -n bin/ubuntu/setup-swap.sh
shellcheck bin/ubuntu/setup-swap.sh
git diff --check
```

### 4.2. Duplicate Swap Consolidation

If the host has two swap devices, such as `/swapfile` and `/swap.img`, only one
is needed. Consolidate duplicates manually before running `setup-swap.sh`.

Manual consolidation steps, all requiring root:

1. Confirm active swap devices.

   ```sh
   cat /proc/swaps
   ```

2. Choose the device to keep. Prefer managed `/swapfile` at `8G` unless the
   reviewed policy for the host is the conservative `16G` target.
3. Disable `/swap.img`.

   ```sh
   swapoff /swap.img
   ```

4. Remove the `/swap.img` entry from `/etc/fstab`.
5. Delete `/swap.img`.
6. Verify that `cat /proc/swaps` shows exactly one device.
7. After approval, run the helper from the dotfiles repo root.

   ```sh
   sudo bash ./bin/ubuntu/setup-swap.sh
   ```

### 4.3. Swap 16GiB To 8GiB Runbook

Use this procedure when the host currently has a 16GiB `/swapfile` and the
reviewed policy is to move to the managed 8GiB target. Run it only after patch
review and explicit approval for the host.

Expected reclaim is about `8589934592` bytes, or 8GiB, before filesystem
metadata and live-write drift. It increases root filesystem headroom because
`/swapfile` is a regular file on `/`.

1. Capture preflight state.

   ```sh
   df -h /
   findmnt -no SOURCE,TARGET,FSTYPE,OPTIONS /
   free -h
   cat /proc/swaps
   swapon --show --bytes
   sysctl -n vm.swappiness
   stat -c%s /swapfile
   stat -c '%n %s bytes mode=%a' /swapfile
   awk '$1 == "/swapfile" {print}' /etc/fstab
   ```

2. Confirm there is enough available memory to tolerate `swapoff`. If memory is
   tight or swap use is unexpectedly high, stop and reschedule for a quieter
   period.
3. Confirm the managed helper target before running it.

   ```sh
   rg -n '^(SWAPFILE|SWAP_SIZE_GB|SWAPPINESS_TARGET)=' bin/ubuntu/setup-swap.sh
   ```

   Expected policy for the default storage-priority host:

   - `SWAPFILE="/swapfile"`
   - `SWAP_SIZE_GB=8`
   - `SWAPPINESS_TARGET=30`

4. Approved action only: from the dotfiles repo root, run the managed helper.

   ```sh
   sudo bash ./bin/ubuntu/setup-swap.sh
   ```

5. Verify the live result.

   ```sh
   df -h /
   findmnt -no SOURCE,TARGET,FSTYPE,OPTIONS /
   free -h
   cat /proc/swaps
   swapon --show --bytes
   sysctl -n vm.swappiness
   stat -c%s /swapfile
   stat -c '%n %s bytes mode=%a' /swapfile
   ```

6. Verify there is exactly one canonical `/swapfile` entry in `/etc/fstab`.

   ```sh
   awk '$1 == "/swapfile" {count++} END {print count + 0}' /etc/fstab
   awk '
     $1 == "/swapfile" && $2 == "none" && $3 == "swap" &&
       $4 == "sw" && $5 == "0" && $6 == "0" {found = 1}
     END {exit found ? 0 : 1}
   ' /etc/fstab
   ```

Expected result for the default policy:

- `/swapfile` size is `8589934592` bytes.
- `/swapfile` mode is `600`.
- `/proc/swaps` and `swapon --show --bytes` show `/swapfile` as active.
- `/etc/fstab` contains exactly one canonical `/swapfile none swap sw 0 0`
  entry.
- `df -h /` shows roughly 8GiB more headroom than the preflight sample, allowing
  for concurrent writes and filesystem accounting drift.

Risks:

- If memory pressure is already high, `swapoff` can stall or fail. Stop before
  the helper when swap use is high or `MemAvailable` is low.
- A host that needs hibernation or maximum OOM margin may need the conservative
  16GiB policy instead of the storage-priority 8GiB target.
- Duplicate active swap devices must be resolved first; the helper intentionally
  refuses to mutate when multiple swap devices are active.
- The helper rewrites the canonical `/swapfile` fstab entry. Do not run it if a
  host intentionally uses a different swap path or mount policy.

### 4.4. Rollback Considerations

If the approved 8G target causes memory pressure or OOM risk, restore the
conservative policy through a reviewed patch that sets `SWAP_SIZE_GB=16`, then
repeat the same approved live procedure. The rollback path must use the same
recreate and `mkswap` behavior as the shrink path, followed by the same
`df`, `findmnt`, `free -h`, `/proc/swaps`, `swapon --show --bytes`,
`sysctl -n vm.swappiness`, `stat -c%s /swapfile`, mode, and fstab checks.
Do not hand-edit the live swapfile size outside the helper; the helper owns
recreate, `mkswap`, activation, fstab normalization, and verification.
