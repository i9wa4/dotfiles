# Storage Hygiene

This document describes the Linux storage visibility and cleanup entrypoints for
issue `#123`.

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

### 1.6. Low-Risk Cache Cleanup

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
