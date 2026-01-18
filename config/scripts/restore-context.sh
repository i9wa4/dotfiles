#!/usr/bin/env bash
# reload CLAUDE.md after autocompaction
CLAUDE_MD="${CLAUDE_CONFIG_DIR}/CLAUDE.md"

if [[ -f $CLAUDE_MD ]]; then
  cat <<'HEADER'
=====================================
CLAUDE.md RELOADED AFTER COMPACTION
Re-read and follow these rules carefully
=====================================

HEADER
  cat "$CLAUDE_MD"
  cat <<'FOOTER'

=====================================
END OF CLAUDE.md
=====================================
FOOTER
fi
