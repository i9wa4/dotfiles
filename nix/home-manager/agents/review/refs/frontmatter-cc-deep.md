---
name: subagent-review-cc-deep
description: |
  5-parallel code/design review using Claude Tier 1 reviewer subagents
  (claude-opus-4-6, pinned in agent frontmatter).
  Always runs Claude reviewers regardless of calling engine. LABEL is always
  "cc-deep". Each reviewer response is materialized to a disk file.
  Use when:
  - Running thorough pre-merge reviews requiring maximum Claude depth
  - Calling engine is Codex but you want Claude Tier 1 review results
  - Running half of a full dual-engine deep review (pair with
    /subagent-review-cx-deep)
  For Tier 2 (sonnet, default): use /subagent-review-cc
---

# Subagent Review CC Deep Skill (Tier 1)

Launches exactly 5 Claude Tier 1 reviewer subagents in parallel. No engine
detection. LABEL is always "cc-deep". Each reviewer response is materialized to
a disk file. Tier 1: agents have model: claude-opus-4-6 pinned in frontmatter.
