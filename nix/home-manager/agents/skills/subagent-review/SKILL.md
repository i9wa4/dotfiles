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

## 1. Review Workflow

### 1.1. Pre-flight Check

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "HALT: On main/master branch."
fi

if ! git diff --quiet main...HEAD; then
  echo "Diff detected: code review."
else
  echo "No diff detected."
fi
```

If code/PR review was requested and no diff exists: halt and report.
Do NOT fall back silently to design review.

### 1.2. Setup (Fully Automatic)

| Item        | Detection                                              |
| ----------- | ------------------------------------------------------ |
| review_type | `git diff main...HEAD` has output -> code, else design |
| scope       | Always `git diff main...HEAD`                          |
| context     | Directory name pattern (see 1.4.1)                     |

### 1.3. Finding Output Format

Every finding from every subagent MUST use this format.
Define once here; all task prompts and summaries reference this section.

```text
### [{SEVERITY}] {concise title}

What: {specific description — what is wrong, not "could be improved"}
Why: {concrete impact — what breaks, what degrades, what risk arises}
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

- Each finding MUST have all 5 fields (What/Why/Where/Confidence/Fix)
- "What" must be specific enough to locate the problem without reading the file
- "Why" must explain the consequence, not just restate the problem
- "Fix" must be a concrete code diff or exact action, not a suggestion to
  "consider"
- When no findings exist: state "No findings from {ROLE} perspective."

### 1.4. Review Execution

#### 1.4.1. Step 1: Auto-detect and Prepare

```bash
# 1. Save diff
DIFF_FILE=$(mkoutput --dir reviews --label review-diff)
git diff main...HEAD > "$DIFF_FILE"

# 2. Detect review_type
if [ -s "$DIFF_FILE" ]; then REVIEW_TYPE="code"; else REVIEW_TYPE="design"; fi

# 3. Detect context from directory name
DIR_NAME=$(basename "$(git rev-parse --show-toplevel)")
PR_NUM=$(echo "$DIR_NAME" | rg -o --pcre2 'pr-\K[0-9]+' || true)
ISSUE_NUM=$(echo "$DIR_NAME" | rg -o --pcre2 'issue-\K[0-9]+' || true)

# 4. Fetch context metadata
CONTEXT_FILE=$(mkoutput --dir reviews --label review-context)
echo "# Review Context" > "$CONTEXT_FILE"

if [ -n "$PR_NUM" ]; then
  echo "## PR #${PR_NUM}" >> "$CONTEXT_FILE"
  gh pr view "$PR_NUM" --json title,body,comments >> "$CONTEXT_FILE"
  # Chase references in PR body
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
```

#### 1.4.2. Step 2: Launch cc x 5 (Single Message, Parallel)

Launch 5 Task tools in one message:

| Priority | Role         | Focus                                          |
| -------- | ------------ | ---------------------------------------------- |
| 1        | security     | Vulnerabilities, injection, secrets            |
| 2        | architecture | Patterns, dependencies, structure              |
| 3        | historian    | History, context, intent alignment             |
| 4        | code / data  | Code review: code. Design review: data         |
| 5        | qa           | Acceptance criteria, edge cases, coverage gaps |

Task prompt template:

```text
[SUBAGENT capability=READONLY]
Review from {ROLE} perspective.
Diff: {DIFF_FILE}
Context: {CONTEXT_FILE}

Investigation steps:
1. Read the diff file in full
2. Read the actual source files (not just the diff) for surrounding context
3. Read the PR/Issue context for intent and requirements
4. For each concern, verify it against the actual code before reporting

Output each finding using the format in Section 1.3 of subagent-review skill.
Use all 5 fields: What, Why, Where, Confidence, Fix.
If no findings: state "No findings from {ROLE} perspective."
```

#### 1.4.3. Step 3: Launch cx x 5 (Background)

```bash
for ROLE in security architecture historian data qa; do
  FILE=$(mkoutput --dir reviews --label "review-${ROLE}-cx")
  codex exec --sandbox workspace-write -o "$FILE" \
    "[SUBAGENT capability=READONLY] Review from ${ROLE} perspective. Diff: ${DIFF_FILE} Context: ${CONTEXT_FILE}" &
done
wait
```

NEVER use `&` with codex exec if output interleaving is a problem.
Use sequential loop instead (remove `&` and `wait`).

### 1.5. Reviewer Deliberation (Optional)

Execute only when:

- Running as orchestrator (role name is "orchestrator")
- User explicitly requests deliberation

For standalone execution, Section 1.4 alone is sufficient.

#### 1.5.1. Deliberation Prompt

Share all Phase 1 results with each reviewer and ask for additional findings:

```text
[SUBAGENT capability=READONLY]
## Phase 1 Review Results
{All Phase 1 findings sorted by severity}

## Questions
From your expert perspective ({ROLE}), based on other reviewers' findings:
1. Additional issues they missed from your perspective?
2. Supplementary concerns triggered by their findings?
3. Contradictions or disagreements with their assessments?

Output each finding using the format in Section 1.3.
If no findings: state "No additional findings from {ROLE} perspective."
```

Launch 10-parallel (cc x 5 + cx x 5) same as Section 1.4.

### 1.6. Summary Output

```bash
SUMMARY_FILE=$(mkoutput --dir reviews --label summary)
```

IMPORTANT: Generate the complete summary (table + detail) in one pass.
Do NOT require a follow-up request for details.

#### 1.6.1. Summary Template

````markdown
# Review Summary

## Target

- Type: {review_type}, Directory: {dir_name}

## Findings

### Phase 1: Initial Review

| #   | Issue           | Reporter     | Severity  | Confidence | File               |
| --- | --------------- | ------------ | --------- | ---------- | ------------------ |
| 1   | {concise title} | {role}-{src} | BLOCKING  | High       | `path/to/file:123` |
| 2   | {concise title} | {role}-{src} | IMPORTANT | Medium     | `path/to/file:456` |
| 3   | {concise title} | {role}-{src} | MINOR     | High       | `path/to/file:789` |

### Phase 2: Deliberation

(Include only when Phase 2 was executed)

| #   | Issue                | Reporter     | Triggered By | Severity  | File               |
| --- | -------------------- | ------------ | ------------ | --------- | ------------------ |
| 1   | {additional finding} | {role}-{src} | {role}       | IMPORTANT | `path/to/file:456` |

## Key Findings Detail

(BLOCKING, IMPORTANT, or flagged by 3+ reviewers)

### #{N} [{SEVERITY}] {title}

**What**: {specific problem description}

**Why**: {concrete consequence — what breaks, what degrades}

**Where**:

- `path/to/file.ext:NN` -- `problematic code`
- `path/to/other_file.ext:MM` -- `same pattern`

**Reviewers**: {role1}-cc, {role2}-cx (list all who flagged this)

**Fix**:

\```lang
-- Before
{exact current code}
-- After
{exact corrected code}
\```

## Coverage

| Perspective  | Phase 1 | Phase 2 | Total |
| ------------ | ------- | ------- | ----- |
| Security     | N       | M       | N+M   |
| Architecture | N       | M       | N+M   |
| Historian    | N       | M       | N+M   |
| Code/Data    | N       | M       | N+M   |
| QA           | N       | M       | N+M   |
| **Total**    | **X**   | **Y**   | **Z** |
````

#### 1.6.2. Key Findings Selection

Include in "Key Findings Detail" when ANY condition is met:

- Severity is BLOCKING
- Severity is IMPORTANT
- 3+ reviewers independently flagged the same issue

MINOR findings appear in table only (no detail section).

## 2. Standalone Usage (Lightweight Mode)

1. Execute Section 1.4 only (skip deliberation)
2. Create summary per Section 1.6

Skip Section 1.5 to reduce execution time and token usage.
