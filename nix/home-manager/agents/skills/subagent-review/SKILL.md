---
name: subagent-review
description: |
  10-parallel code/design review using reviewer subagents.
  Use when:
  - Running code reviews on PRs, commits, or branches
  - Running design reviews on issues or documents
  - Need multi-perspective review (security, architecture, code, QA, historian)
---

# Subagent Review Skill

WRAPPER: Delegates to /subagent-claude-review (5 Claude reviewers) and
/subagent-codex-review (5 Codex reviewers). Collects 10 total output files and
produces a merged summary.

NOTE: Callers not using deliberation (§1.4) are unaffected by this change.
Callers requiring the deliberation pass MUST invoke /subagent-claude-review and
/subagent-codex-review directly and perform deliberation themselves.

HARD CONSTRAINT: Both sub-skills MUST complete before proceeding to merge.
Do NOT produce a merged summary with fewer than 10 result files.

## 1. Pre-flight Check

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] || [ "$BRANCH" = "develop" ]; then
  echo "HALT: On protected branch (${BRANCH})."
fi
```

If code/PR review was requested and no diff exists: halt and report.
Do NOT fall back silently to design review.

## 2. Review Workflow

### Step 0: Capture Baseline

```bash
BEFORE_CC=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cc.md 2>/dev/null | wc -l)
BEFORE_CX=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cx.md 2>/dev/null | wc -l)
```

### Step 1: Invoke Claude Reviewers

Invoke the Claude-only review skill as a native Skill call:

/subagent-claude-review

Wait for completion. Verify 5 review-{role}-cc files exist before proceeding.

### Step 2: Invoke Codex Reviewers

Invoke the Codex-only review skill as a native Skill call:

/subagent-codex-review

Wait for completion. Verify 5 review-{role}-cx files exist before proceeding.

### Step 3: Collect and Verify 10 Results

Before merging, confirm 10 new output files were produced by this run:

```bash
AFTER_CC=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cc.md 2>/dev/null | wc -l)
AFTER_CX=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cx.md 2>/dev/null | wc -l)
echo "New cc files: $((AFTER_CC - BEFORE_CC))"  # Expected: 5
echo "New cx files: $((AFTER_CX - BEFORE_CX))"  # Expected: 5
# Total new: $((AFTER_CC + AFTER_CX - BEFORE_CC - BEFORE_CX)) — Expected: 10
```

If delta for either side is less than 5: do NOT proceed. Re-invoke the relevant
sub-skill.

### Step 4: Merged Summary

```bash
SUMMARY_FILE=$(mkmd --dir reviews --label summary)
```

Generate the merged summary in one pass. Do NOT require a follow-up.

````markdown
# Review Summary (Merged: Claude + Codex)

## Target

- Directory: {dir_name}
- Sources: summary-cc (Claude) + summary-cx (Codex)

## Findings

| #   | Issue           | Reporter          | Severity  | Confidence | File               |
| --- | --------------- | ----------------- | --------- | ---------- | ------------------ |
| 1   | {concise title} | {role}-cc/{role}-cx | BLOCKING  | High       | `path/to/file:123` |

Deduplication rule: if the same issue is reported by both cc and cx sides,
merge into one entry with "Reporters: {role}-cc, {role}-cx".
Re-rank by severity after deduplication.

## Key Findings Detail

(BLOCKING, IMPORTANT, or flagged by 3+ reviewers across both engines)

### {title}

**What**: {description}

**Where**:

- `path/to/file.ext:NN` -- `code`

**Reporters**: {role}-cc, {role}-cx

**Fix**:

\```lang
-- Before
-- After
\```

## Coverage

| Perspective  | cc Count | cx Count | Total |
| ------------ | -------- | -------- | ----- |
| Security     | N        | N        | N     |
| Architecture | N        | N        | N     |
| Historian    | N        | N        | N     |
| Code/Data    | N        | N        | N     |
| QA           | N        | N        | N     |
| **Total**    | **N**    | **N**    | **N** |
````

## 3. Reviewer Deliberation (Out of Scope)

The deliberation pass (second-round cross-examination) is NOT performed by
this wrapper. Callers requiring deliberation must invoke /subagent-claude-review
and /subagent-codex-review directly, collect Phase 1 results from both, and
perform deliberation themselves.
