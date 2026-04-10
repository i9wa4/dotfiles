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
user home directory.

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
- `CATEGORIES`
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
Ubuntu or WSL2 host.

## 2. Guarded GC-Root Review

Use this review before deleting stale auto GC roots.

### 2.1. Dry Run

```sh
nix run '.#gc-roots-review' -- --dry-run
```

This mode classifies roots as:

- `KEEP`
- `CANDIDATE`
- `BLOCKED`

Each line includes a reason, the auto-root path, the original linked path, and
the resolved target.

### 2.2. Delete Mode

```sh
sudo nix run '.#gc-roots-review' -- --delete
```

Delete mode is explicit and never scheduled. It re-runs the same classification
checks at execution time, deletes only current `CANDIDATE` roots, and then runs
`nix-collect-garbage`.

### 2.3. Protected Root Classes

These roots stay `BLOCKED` in issue `#123`:

- `.direnv`
- `result`
- `/tmp`

Home Manager and profile generation links stay `KEEP`.

### 2.4. Operator Workflow

1. Run `--dry-run`
2. Review every `CANDIDATE`
3. Confirm the path is absent from the active worktree inventories
4. Run `--delete` only when the review is complete
