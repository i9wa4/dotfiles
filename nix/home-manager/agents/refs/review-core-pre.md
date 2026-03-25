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

CONTEXT_FILE=$(mkmd --dir reviews --label review-context-LABEL_PLACEHOLDER)
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

LABEL="LABEL_PLACEHOLDER"
```
