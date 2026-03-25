---
name: subagent-review-cx-deep
description: |
  5-parallel code/design review using Codex Tier 1 reviewer subagents (gpt-5.4, xhigh effort).
  Always runs Codex reviewers with explicit model pin and reasoning effort.
  Use when:
  - Running thorough pre-merge reviews requiring maximum depth
  - Calling engine is Claude but you want Codex-side Tier 1 review results
  - Running half of a full dual-engine deep review (pair with /subagent-review-cc-deep)
---

# Subagent Review CX Deep Skill (Tier 1)

Launches exactly 5 Codex Tier 1 reviewer subagents in parallel via `codex exec`.
No engine detection. LABEL is always "cx-deep". Each reviewer output is written
to disk. Tier 1: explicit model pin and xhigh reasoning effort (hardcoded in
codex exec call).
