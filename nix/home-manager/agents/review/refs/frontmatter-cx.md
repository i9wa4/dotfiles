---
name: subagent-review-cx
description: |
  5-parallel code/design review using Codex Tier 2 reviewer subagents (no model/effort flags).
  Always runs Codex reviewers regardless of calling engine.
  Use when:
  - Running code or design reviews using Codex reviewers only
  - Calling engine is Claude but you want Codex-side review results
  - Running half of a full dual-engine review (pair with `subagent-review-cc`)
  For Tier 1 (gpt-5.4, xhigh effort): use `subagent-review-cx-deep`
---

# Subagent Review CX Skill

Launches exactly 5 Codex reviewer subagents in parallel via `codex exec`. No
engine detection. LABEL is always "cx". Each reviewer output is written to disk.
