#!/usr/bin/env python3
import os
import shutil
import sqlite3
import sys
import time
from pathlib import Path


PREFIX = "codex-storage-pressure-relief"
HOME = Path.home()
CODEX_HOME = HOME / ".codex"
DB = CODEX_HOME / "logs_2.sqlite"
WAL = Path(f"{DB}-wal")
SHM = Path(f"{DB}-shm")
SESSIONS = CODEX_HOME / "sessions"
TMP_ROOTS = [CODEX_HOME / ".tmp", CODEX_HOME / "tmp"]
SESSION_RETENTION_DAYS = int(os.environ["CODEX_SESSION_RETENTION_DAYS"])
TEMP_RETENTION_HOURS = int(os.environ["CODEX_TEMP_RETENTION_HOURS"])
WAL_PRESSURE_THRESHOLD = int(os.environ["CODEX_WAL_PRESSURE_THRESHOLD_BYTES"])
CRITICAL_FREE_BYTES = int(os.environ["CODEX_CRITICAL_FREE_BYTES"])


def log(message):
    print(f"{PREFIX}: {message}")


def warn(message):
    print(f"{PREFIX}: {message}", file=sys.stderr)


def real(path):
    return os.path.realpath(path)


def file_size(path):
    try:
        return path.stat().st_size
    except FileNotFoundError:
        return 0
    except OSError as exc:
        warn(f"stat failed for {path}: {exc}")
        return 0


def collect_open_paths(prefixes):
    proc = Path("/proc")
    prefixes = [real(path) for path in prefixes if path.exists()]
    if not proc.is_dir() or not prefixes:
        return set(), False

    open_paths = set()
    for fd_dir in proc.glob("[0-9]*/fd"):
        try:
            entries = list(fd_dir.iterdir())
        except OSError:
            continue
        for fd in entries:
            try:
                target = os.readlink(fd)
            except OSError:
                continue
            if target.endswith(" (deleted)"):
                target = target[:-10]
            target_real = real(target)
            if any(
                target_real == prefix or target_real.startswith(f"{prefix}/")
                for prefix in prefixes
            ):
                open_paths.add(target_real)
    return open_paths, True


def child_has_open_file(child, open_paths):
    child_real = real(child)
    return any(
        path == child_real or path.startswith(f"{child_real}/") for path in open_paths
    )


def directory_size(path):
    total = 0
    for child in path.rglob("*"):
        try:
            if child.is_file():
                total += child.stat().st_size
        except OSError:
            continue
    return total


def prune_temp(open_paths):
    cutoff = time.time() - TEMP_RETENTION_HOURS * 3600
    entries_deleted = 0
    bytes_deleted = 0
    errors = 0

    for root in TMP_ROOTS:
        if not root.exists():
            continue
        try:
            children = list(root.iterdir())
        except OSError as exc:
            warn(f"cannot list temp root {root}: {exc}")
            errors += 1
            continue
        for child in children:
            try:
                stat = child.stat()
            except FileNotFoundError:
                continue
            except OSError as exc:
                warn(f"cannot stat temp entry {child}: {exc}")
                errors += 1
                continue
            if stat.st_mtime >= cutoff or child_has_open_file(child, open_paths):
                continue
            try:
                if child.is_dir():
                    size = directory_size(child)
                    shutil.rmtree(child)
                else:
                    size = stat.st_size
                    child.unlink()
                entries_deleted += 1
                bytes_deleted += size
            except OSError as exc:
                warn(f"cannot delete temp entry {child}: {exc}")
                errors += 1

    log(
        "temp prune "
        f"entries_deleted={entries_deleted} "
        f"bytes_deleted={bytes_deleted} errors={errors}"
    )
    return errors


def prune_sessions(open_paths):
    if not SESSIONS.exists():
        log("sessions directory not found, skipping session prune")
        return 0

    cutoff = time.time() - SESSION_RETENTION_DAYS * 86400
    seen = 0
    deleted = 0
    skipped_open = 0
    bytes_deleted = 0
    errors = 0

    for path in SESSIONS.rglob("*.jsonl"):
        try:
            stat = path.stat()
        except FileNotFoundError:
            continue
        except OSError as exc:
            warn(f"cannot stat session {path}: {exc}")
            errors += 1
            continue
        if stat.st_mtime >= cutoff:
            continue
        seen += 1
        if real(path) in open_paths:
            skipped_open += 1
            continue
        try:
            path.unlink()
            deleted += 1
            bytes_deleted += stat.st_size
        except OSError as exc:
            warn(f"cannot delete session {path}: {exc}")
            errors += 1

    empty_dirs_removed = 0
    for path in sorted((p for p in SESSIONS.rglob("*") if p.is_dir()), reverse=True):
        try:
            path.rmdir()
            empty_dirs_removed += 1
        except OSError:
            pass

    log(
        "session prune "
        f"old_seen={seen} deleted={deleted} skipped_open={skipped_open} "
        f"empty_dirs_removed={empty_dirs_removed} bytes_deleted={bytes_deleted} "
        f"errors={errors}"
    )
    return errors


def checkpoint_wal(label):
    before = file_size(WAL)
    log(f"{label}: WAL before={before} bytes")
    if not DB.exists():
        log(f"{DB} not found, skipping checkpoint")
        return None

    try:
        conn = sqlite3.connect(DB, timeout=30)
        try:
            conn.execute("PRAGMA busy_timeout=30000")
            row = conn.execute("PRAGMA wal_checkpoint(TRUNCATE)").fetchone()
        finally:
            conn.close()
    except sqlite3.OperationalError as exc:
        warn(f"{label}: checkpoint skipped ({exc})")
        return None

    busy, log_pages, checkpointed = row
    after = file_size(WAL)
    log(
        f"{label}: result busy={busy} log_pages={log_pages} "
        f"checkpointed={checkpointed} WAL after={after} bytes"
    )
    if busy and log_pages >= 0 and log_pages == checkpointed:
        log(f"{label}: all WAL frames checkpointed, truncate blocked by holders")
    elif busy:
        log(f"{label}: checkpoint incomplete because the database is busy")
    return busy, log_pages, checkpointed


def truncate_wal(label):
    before = file_size(WAL)
    if before == 0:
        log(f"{label}: WAL already zero bytes")
        return

    try:
        with WAL.open("r+b") as file:
            file.truncate(0)
    except FileNotFoundError:
        log(f"{label}: WAL not found, skipping truncate")
        return
    except OSError as exc:
        warn(f"{label}: WAL truncate failed ({exc})")
        return

    after = file_size(WAL)
    log(f"{label}: WAL truncate before={before} after={after} bytes")


def process_cmdline(pid):
    try:
        raw = Path(f"/proc/{pid}/cmdline").read_bytes()
    except OSError:
        return ""
    return raw.replace(b"\0", b" ").decode("utf-8", "replace").strip()


def wal_holders():
    proc = Path("/proc")
    targets = {real(path) for path in [DB, WAL, SHM] if path.exists()}
    if not proc.is_dir() or not targets:
        return []

    holders = {}
    for fd_dir in proc.glob("[0-9]*/fd"):
        try:
            pid = int(fd_dir.parent.name)
            entries = list(fd_dir.iterdir())
        except (OSError, ValueError):
            continue
        for fd in entries:
            try:
                target = os.readlink(fd)
            except OSError:
                continue
            if target.endswith(" (deleted)"):
                target = target[:-10]
            if real(target) in targets:
                holders[pid] = process_cmdline(pid)
                break
    return sorted(holders.items())


if not CODEX_HOME.exists():
    log(f"{CODEX_HOME} not found, skipping")
    sys.exit(0)

open_paths, open_detection = collect_open_paths([SESSIONS, *TMP_ROOTS])
if not open_detection:
    log("open-file detection unavailable; skipping mutable temp/session prune")
    prune_errors = 0
else:
    prune_errors = prune_temp(open_paths) + prune_sessions(open_paths)

first_result = checkpoint_wal("initial checkpoint")
wal_after = file_size(WAL)
free_bytes = shutil.disk_usage(HOME).free
pressure = wal_after >= WAL_PRESSURE_THRESHOLD
critical_pressure = pressure and free_bytes <= CRITICAL_FREE_BYTES
fully_checkpointed = (
    first_result is not None
    and first_result[1] >= 0
    and first_result[1] == first_result[2]
)
log(
    "pressure check "
    f"wal_after={wal_after} free_bytes={free_bytes} pressure={pressure} "
    f"critical_pressure={critical_pressure} fully_checkpointed={fully_checkpointed}"
)

if pressure:
    holders = wal_holders()
    if holders:
        if fully_checkpointed:
            log("large fully-checkpointed WAL is still held open; truncating WAL")
        elif critical_pressure:
            warn(
                "critical filesystem pressure and checkpoint incomplete; "
                "emergency truncating WAL without SQLite full-checkpoint proof"
            )
        else:
            warn(
                "large WAL pressure remains but checkpoint incomplete; "
                "policy truncates WAL anyway"
            )
        for pid, cmdline in holders:
            log(f"holder pid={pid} cmdline={cmdline!r}")
    elif fully_checkpointed:
        log("large fully-checkpointed WAL has no visible /proc holders; truncating WAL")
    elif critical_pressure:
        warn(
            "critical filesystem pressure, checkpoint incomplete, and no visible "
            "/proc holders; emergency truncating WAL without SQLite full-checkpoint proof"
        )
    else:
        warn(
            "large WAL pressure remains but checkpoint incomplete "
            "and no visible /proc holders; policy truncates WAL anyway"
        )
    if fully_checkpointed:
        truncate_wal("pressure truncate")
    elif critical_pressure:
        truncate_wal("emergency pressure truncate")
    else:
        truncate_wal("pressure truncate without checkpoint proof")
else:
    log("no pressure truncate needed")

if prune_errors:
    sys.exit(1)
