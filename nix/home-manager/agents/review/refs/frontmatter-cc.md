---
name: subagent-review-cc
description: |
  5-parallel code/design review using Claude-based reviewer subagents.
  Always runs Claude reviewers regardless of calling engine.
  Use when:
  - Running code or design reviews using Claude reviewers only
  - Calling engine is Codex but you want Claude-side review results
  - Running half of a full dual-engine review (pair with /subagent-review-cx)
---

# Subagent Review CC Skill

Launches exactly 5 Claude reviewer subagents in parallel. No engine detection.
LABEL is always "cc". Each reviewer response is materialized to a disk file.
