---
description: "Summarize Reviews"
---

# summarize-reviews

Aggregate review results after reading this file.

## 1. Steps

1. Load review results from other panes in `.i9wa4/` directory
2. Get PR comments/reviews to identify already-reported issues
   - Get with `gh pr view <number> --json comments,reviews`
3. Classify each pane's findings into 3 categories
   - Needs reporting: New finding with real impact (downstream effects, data loss)
   - No need to report: New finding but acceptable (design decision, low priority)
   - Already reported: CodeRabbit etc. already commented on PR
4. Output aggregation to `.i9wa4/YYYYMMDD-all-reviews.md`

## 2. Output Format

```markdown
# PR #XXX Integrated Review Results

## Needs Reporting (New, Real Impact)

| #   | Severity | Issue Title  | Reporter | Reason               |
| --- | -------- | ------------ | -------- | ---------------      |
| 1   | High     | ...          | p2, p3   | Breaks downstream BI |

## No Need to Report (New, Acceptable)

| #   | Severity | Issue Title  | Reporter | Reason                        |
| --- | -------- | ------------ | -------- | -------------------           |
| 1   | Medium   | ...          | p1       | Acceptable as design decision |

## Already Reported (CodeRabbit etc.)

| Issue Title             | Reporter   | Status     |
| ----------------------- | ---------- | ---------- |
| Boolean type conversion | CodeRabbit | Unresolved |

## Issue Details
...
```

## 3. Classification Criteria

### 3.1. Needs Reporting Criteria

- Potential to break downstream queries or dashboards
- Potential for data loss or inconsistency
- Security issues
- Breaking backward compatibility

### 3.2. No Need to Report Criteria

- Within acceptable design decision range
- Performance improvement already provides benefit
- Low priority with minimal real impact
- Confirmation-level content
