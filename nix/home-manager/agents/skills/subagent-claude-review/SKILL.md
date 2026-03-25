---
name: subagent-claude-review
description: |
  5-parallel code/design review using Claude-based reviewer subagents.
  Always runs Claude reviewers regardless of calling engine.
  Use when:
  - Running code or design reviews using Claude reviewers only
  - Calling engine is Codex but you want Claude-side review results
  - Running half of a full dual-engine review (pair with /subagent-codex-review)
---

# Subagent Claude Review Skill

Launches exactly 5 Claude reviewer subagents in parallel. No engine detection.
LABEL is always "cc". Each reviewer response is materialized to a disk file.

## 1. Pre-flight Check

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] || [ "$BRANCH" = "develop" ]; then
  echo "HALT: On protected branch (${BRANCH})."
fi
```

If code/PR review was requested and no diff exists: halt and report.
Do NOT fall back silently to design review.

## 2. Finding Output Format

Every finding from every subagent MUST use this format.

```text
### {concise title}

What: {specific description — what is wrong, not "could be improved"}
Severity: BLOCKING / IMPORTANT / MINOR
Where: `path/to/file.ext:line` — `relevant code snippet`
Confidence: High / Medium / Low
Fix:
  {exact code change as before/after, or concrete action step}
  {NOT "consider improving X" — show the actual fix}
```

Rules:

- Each finding MUST have all 5 fields (What/Severity/Where/Confidence/Fix)
- When no findings exist: state "No findings from {ROLE} perspective."

## 3. Review Execution

### Step 1: Prepare

```bash
# 1. Detect base commit
for CANDIDATE in develop main master; do
  if git rev-parse --verify "$CANDIDATE" >/dev/null 2>&1; then
    BASE=$(git merge-base "$CANDIDATE" HEAD)
    break
  fi
done

# 2. Fetch context metadata
DIR_NAME=$(basename "$(git rev-parse --show-toplevel)")
PR_NUM=$(echo "$DIR_NAME" | rg -o --pcre2 'pr-\K[0-9]+' || true)
ISSUE_NUM=$(echo "$DIR_NAME" | rg -o --pcre2 'issue-\K[0-9]+' || true)

CONTEXT_FILE=$(mkmd --dir reviews --label review-context-cc)
echo "# Review Context" > "$CONTEXT_FILE"

if [ -n "$PR_NUM" ]; then
  echo "## PR #${PR_NUM}" >> "$CONTEXT_FILE"
  gh pr view "$PR_NUM" --json title,body,comments >> "$CONTEXT_FILE"
elif [ -n "$ISSUE_NUM" ]; then
  echo "## Issue #${ISSUE_NUM}" >> "$CONTEXT_FILE"
  gh issue view "$ISSUE_NUM" --json title,body,comments >> "$CONTEXT_FILE"
fi

# 3. Determine role 4 (code/data conditional)
# Code review (diff present): reviewer-code
# Design review (no diff):    reviewer-data
if git diff "${BASE}...HEAD" --quiet 2>/dev/null; then
  ROLE4="data"
else
  ROLE4="code"
fi

LABEL="cc"
```

### Step 2: Launch 5 Claude Subagents in Parallel

Launch all 5 reviewers in a single turn using the native Agent tool.
Use this prompt template for each:

```text
reviewer-{ROLE}
git diff {BASE}...HEAD
Context: {CONTEXT_FILE}
```

Roles (in order):

| Priority | Role         |
| -------- | ------------ |
| 1        | security     |
| 2        | architecture |
| 3        | historian    |
| 4        | {ROLE4}      |
| 5        | qa           |

After each reviewer responds, materialize its response to disk:

```bash
OUTPUT_FILE=$(mkmd --dir reviews --label "review-${ROLE}-${LABEL}")
# Write the subagent's response to OUTPUT_FILE
```

### Step 3: Collect and Verify 5 Results

Verify all 5 review-{role}-cc files are non-empty before proceeding. If any is
missing or empty, retry that reviewer. Do NOT proceed with fewer than 5.

### Step 4: Summary

```bash
SUMMARY_FILE=$(mkmd --dir reviews --label "summary-${LABEL}")
```

Generate summary in one pass:

```markdown
# Review Summary (Claude)

## Target

- Directory: {dir_name}
- Label: cc

## Findings

| #   | Issue           | Reporter     | Severity  | Confidence | File               |
| --- | --------------- | ------------ | --------- | ---------- | ------------------ |
| 1   | {concise title} | {role}-cc    | BLOCKING  | High       | `path/to/file:123` |

## Key Findings Detail

(BLOCKING, IMPORTANT, or flagged by 2+ reviewers)

## Coverage

| Perspective  | Count |
| ------------ | ----- |
| Security     | N     |
| Architecture | N     |
| Historian    | N     |
| Code/Data    | N     |
| QA           | N     |
| **Total**    | **N** |
```
