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

HARD CONSTRAINT: Every review MUST launch exactly 10 subagents in parallel
(self x 5 + external x 5). No exceptions. No lightweight mode. No partial
execution. If either engine is unavailable, halt and report — do NOT silently
degrade to 5-parallel.

## 1. Review Workflow

### 1.1. Pre-flight Check

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] || [ "$BRANCH" = "develop" ]; then
  echo "HALT: On protected branch (${BRANCH})."
fi
```

If code/PR review was requested and no diff exists: halt and report.
Do NOT fall back silently to design review.

### 1.2. Finding Output Format

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

Severity levels:

| Level     | Meaning                                        |
| --------- | ---------------------------------------------- |
| BLOCKING  | Must fix before merge; correctness or security |
| IMPORTANT | Should fix; maintainability or reliability     |
| MINOR     | Nice to fix; style or minor improvement        |

Rules:

- Each finding MUST have all 5 fields (What/Severity/Where/Confidence/Fix)
- "What" must be specific enough to locate the problem without reading the file
- "Fix" must be a concrete code diff or exact action, not a suggestion to
  "consider"
- When no findings exist: state "No findings from {ROLE} perspective."

### 1.3. Review Execution

#### 1.3.1. Step 1: Prepare

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

CONTEXT_FILE=$(mkmd --dir reviews --label review-context)
echo "# Review Context" > "$CONTEXT_FILE"

if [ -n "$PR_NUM" ]; then
  echo "## PR #${PR_NUM}" >> "$CONTEXT_FILE"
  gh pr view "$PR_NUM" --json title,body,comments >> "$CONTEXT_FILE"
  gh pr view "$PR_NUM" --json body --jq '.body' \
    | rg -o --pcre2 '#\K[0-9]+' | sort -u | while read -r REF; do
      echo "## Referenced #${REF}" >> "$CONTEXT_FILE"
      gh issue view "$REF" --json title,body,comments >> "$CONTEXT_FILE" 2>/dev/null \
        || gh pr view "$REF" --json title,body,comments >> "$CONTEXT_FILE" 2>/dev/null \
        || echo "(not found)" >> "$CONTEXT_FILE"
    done
elif [ -n "$ISSUE_NUM" ]; then
  echo "## Issue #${ISSUE_NUM}" >> "$CONTEXT_FILE"
  gh issue view "$ISSUE_NUM" --json title,body,comments >> "$CONTEXT_FILE"
fi

# 3. Detect engine labels for file naming
_CMD=$(tmux display-message -p '#{pane_current_command}')
case "$_CMD" in
  *claude*) SELF_LABEL="cc"; EXT_LABEL="cx" ;;
  *codex*)  SELF_LABEL="cx"; EXT_LABEL="cc" ;;
  *) echo "HALT: Cannot detect engine from '${_CMD}'"; exit 1 ;;
esac
```

#### 1.3.2. Step 2: Launch 10 Subagents (Self x 5 + External x 5)

YOU MUST launch all 10 subagents. Both self and external branches are mandatory.

**Roles** (each role runs twice = 10 total):

| Priority | Role         | Focus                                          |
| -------- | ------------ | ---------------------------------------------- |
| 1        | security     | Vulnerabilities, injection, secrets            |
| 2        | architecture | Patterns, dependencies, structure              |
| 3        | historian    | History, context, intent alignment             |
| 4        | code / data  | Code review: code. Design review: data         |
| 5        | qa           | Acceptance criteria, edge cases, coverage gaps |

**Subagent prompt template**:

```text
git diff {BASE}...HEAD
Context: {CONTEXT_FILE}
```

**Self branch**: Launch reviewer-security, reviewer-architecture,
reviewer-historian, reviewer-code/reviewer-data, reviewer-qa as native
subagents in parallel in a single message/turn using the prompt template above.

**External branch** (5 subagents via shell, in parallel):

```bash
for ROLE in security architecture historian data qa; do
  PROMPT_FILE=$(mkmd --dir reviews --label "prompt-${ROLE}-${EXT_LABEL}")
  OUTPUT_FILE=$(mkmd --dir reviews --label "review-${ROLE}-${EXT_LABEL}")
  cat << EOF > "$PROMPT_FILE"
reviewer-${ROLE}
git diff ${BASE}...HEAD
Context: ${CONTEXT_FILE}
EOF
  case "$EXT_LABEL" in
    cx) codex exec --sandbox workspace-write -o "$OUTPUT_FILE" "$(cat "$PROMPT_FILE")" & ;;
    cc) claude -p "$(cat "$PROMPT_FILE")" > "$OUTPUT_FILE" & ;;
  esac
done
wait
```

#### 1.3.3. Step 3: Collect and Verify 10 Results

Before proceeding to summary, verify ALL 10 results have been collected:

- Self results: 5 native subagent responses
- External results: 5 output files (review-{ROLE}-{EXT_LABEL})

If any result is missing, retry that specific subagent. Do NOT proceed to
summary with fewer than 10 results.

### 1.4. Reviewer Deliberation (Optional)

Execute only when running as orchestrator or explicitly requested.

Share all Phase 1 results with each reviewer:

```text
reviewer-{ROLE}
## Phase 1 Results
{All Phase 1 findings sorted by severity}

From your perspective, what did others miss or get wrong?
```

Launch 10 subagents (self x 5 + external x 5) same as Section 1.3.2.

### 1.5. Summary Output

```bash
SUMMARY_FILE=$(mkmd --dir reviews --label summary)
```

Generate the complete summary in one pass. Do NOT require a follow-up.

````markdown
# Review Summary

## Target

- Directory: {dir_name}

## Findings

| #   | Issue           | Reporter     | Severity  | Confidence | File               |
| --- | --------------- | ------------ | --------- | ---------- | ------------------ |
| 1   | {concise title} | {role}-{src} | BLOCKING  | High       | `path/to/file:123` |

## Key Findings Detail

(BLOCKING, IMPORTANT, or flagged by 3+ reviewers)

### {title}

**What**: {description}

**Where**:

- `path/to/file.ext:NN` -- `code`

**Reviewers**: {role}-{src}, ...

**Fix**:

\```lang
-- Before
-- After
\```

## Coverage

| Perspective  | Count |
| ------------ | ----- |
| Security     | N     |
| Architecture | N     |
| Historian    | N     |
| Code/Data    | N     |
| QA           | N     |
| **Total**    | **N** |
````
