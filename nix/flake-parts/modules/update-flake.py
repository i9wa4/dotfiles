import argparse
import json
import os
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="nix run '.#update' --",
        description="Update all flake inputs from the repo root.",
    )
    parser.add_argument(
        "--min-age-days",
        type=int,
        default=None,
        help="keep the new flake.lock only if every changed input is at least DAYS old",
    )
    return parser.parse_args()


def run_update() -> int:
    gh_bin = os.environ["GH_BIN"]
    nix_bin = os.environ["NIX_BIN"]
    token_process = subprocess.run(
        [gh_bin, "auth", "token"],
        check=False,
        stdout=subprocess.PIPE,
        text=True,
    )
    if token_process.returncode != 0:
        return token_process.returncode

    token = token_process.stdout.strip()
    update_process = subprocess.run(
        [nix_bin, "flake", "update", "--access-tokens", f"github.com={token}"],
        check=False,
    )
    return update_process.returncode


def load_lock(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def changed_inputs(before: dict, after: dict) -> list[dict]:
    changed = []
    now = int(time.time())
    before_nodes = before["nodes"]
    after_nodes = after["nodes"]

    for name, new_node in after_nodes.items():
        old_node = before_nodes.get(name, {})
        new_locked = new_node.get("locked") or {}
        old_locked = old_node.get("locked") or {}
        if not new_locked or new_locked == old_locked:
            continue
        last_modified = new_locked.get("lastModified")
        age_seconds = (
            None if last_modified is None else max(0, now - int(last_modified))
        )
        changed.append(
            {
                "name": name,
                "owner": new_locked.get("owner"),
                "repo": new_locked.get("repo"),
                "rev": new_locked.get("rev")
                or new_locked.get("narHash")
                or new_locked.get("ref")
                or "unknown",
                "last_modified": last_modified,
                "age_seconds": age_seconds,
            }
        )

    return changed


def render_target(item: dict) -> str:
    if item["owner"] and item["repo"]:
        return f"{item['name']} ({item['owner']}/{item['repo']})"
    return item["name"]


def enforce_min_age(changed: list[dict], min_age_days: int) -> int:
    if not changed:
        print("No input version changes detected.")
        return 0

    min_age_seconds = min_age_days * 24 * 60 * 60
    blocked = []
    print(f"Changed inputs after update ({len(changed)}):")
    for item in changed:
        target = render_target(item)
        if item["last_modified"] is None:
            print(f"UNKNOWN: {target} -> {item['rev']} (missing locked.lastModified)")
            blocked.append(item)
            continue
        age_days = item["age_seconds"] / 86400
        last_modified = datetime.fromtimestamp(
            item["last_modified"], tz=timezone.utc
        ).strftime("%Y-%m-%d")
        if item["age_seconds"] < min_age_seconds:
            print(
                f"TOO_FRESH: {target} -> {item['rev']} (age {age_days:.1f}d, lastModified {last_modified} UTC)"
            )
            blocked.append(item)
            continue
        print(
            f"OK: {target} -> {item['rev']} (age {age_days:.1f}d, lastModified {last_modified} UTC)"
        )

    if blocked:
        print("")
        print(
            f"Blocked because one or more updated inputs are newer than {min_age_days} days."
        )
        return 1

    print("")
    print(f"All changed inputs satisfy the minimum age window ({min_age_days} days).")
    return 0


def main() -> int:
    args = parse_args()
    if args.min_age_days is not None and args.min_age_days < 0:
        print("--min-age-days requires a non-negative integer", file=sys.stderr)
        return 2

    if args.min_age_days is None:
        return run_update()

    lock_path = Path("flake.lock")
    backup_path = lock_path.with_suffix(".lock.bak")
    shutil.copy2(lock_path, backup_path)
    try:
        update_status = run_update()
        if update_status != 0:
            shutil.copy2(backup_path, lock_path)
            print("Update command failed; restored flake.lock", file=sys.stderr)
            return 1

        status = enforce_min_age(
            changed_inputs(load_lock(backup_path), load_lock(lock_path)),
            args.min_age_days,
        )
        if status != 0:
            shutil.copy2(backup_path, lock_path)
            print(
                f"Restored flake.lock because one or more updated inputs were newer than {args.min_age_days} days.",
                file=sys.stderr,
            )
        return status
    except OSError as exc:
        shutil.copy2(backup_path, lock_path)
        print(str(exc), file=sys.stderr)
        return 1
    finally:
        backup_path.unlink(missing_ok=True)


if __name__ == "__main__":
    raise SystemExit(main())
