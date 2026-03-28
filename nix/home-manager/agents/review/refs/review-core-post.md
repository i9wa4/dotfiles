### Step 3: Collect and Verify 5 Results

Verify all 5 review-{role}-LABEL_PLACEHOLDER files are non-empty before
proceeding. If any is missing or empty, retry that reviewer. Do NOT proceed with
fewer than 5.

### Step 4: Summary

```bash
SUMMARY_FILE=$(mkmd --dir reviews --label "summary-${LABEL}")
```

Generate summary in one pass:

```markdown
# Review Summary (LABEL_PLACEHOLDER)

## Target

- Directory: {dir_name}
- Label: LABEL_PLACEHOLDER

## Resumable Handoff

- Objective: {current objective or `Not provided`}
- Blockers: {current blockers or `None recorded`}
- Active paths:
  - `{path/to/active-artifact-or-file}`
- Next action: {next action after accepting or retrying this review}
- Latest verification status: {worker verification outcome or `Not provided`}

## Findings

| #   | Issue           | Reporter     | Severity  | Confidence | File               |
| --- | --------------- | ------------ | --------- | ---------- | ------------------ |
| 1   | {concise title} | {role}-LABEL_PLACEHOLDER    | BLOCKING  | High       | `path/to/file:123` |

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
