#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

DB="${CODEX_LOG_DB:-$HOME/.codex/logs_2.sqlite}"
WAL="$DB-wal"

if [ ! -f "$DB" ]; then
  echo "codex-wal-checkpoint: $DB not found, skipping"
  exit 0
fi

stat_size() {
  if size=$(stat -c%s "$1" 2>/dev/null); then
    printf '%s' "$size"
  else
    stat -f%z "$1" 2>/dev/null || printf '0'
  fi
}

before=0
if [ -f "$WAL" ]; then before=$(stat_size "$WAL"); fi
echo "codex-wal-checkpoint: WAL before = $before bytes"

CODEX_LOG_DB="$DB" python3 - <<'PY'
import os
import sqlite3
import sys

db = os.environ["CODEX_LOG_DB"]
try:
    conn = sqlite3.connect(db, timeout=30)
    try:
        busy, log_pages, checkpointed = conn.execute(
            "PRAGMA wal_checkpoint(TRUNCATE)"
        ).fetchone()
        print(
            f"codex-wal-checkpoint: result busy={busy} "
            f"log_pages={log_pages} checkpointed={checkpointed}"
        )
        if busy and log_pages >= 0 and log_pages == checkpointed:
            print(
                "codex-wal-checkpoint: all WAL frames checkpointed, "
                "but active readers prevented truncate"
            )
        elif busy:
            print(
                "codex-wal-checkpoint: checkpoint incomplete because "
                "the database is busy"
            )
    finally:
        conn.close()
except sqlite3.OperationalError as exc:
    print(f"codex-wal-checkpoint: skipped ({exc})", file=sys.stderr)
PY

after=0
if [ -f "$WAL" ]; then after=$(stat_size "$WAL"); fi
echo "codex-wal-checkpoint: WAL after  = $after bytes"
