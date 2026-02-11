---
name: github
description: |
  GitHub operations guide using gh CLI.
  Use when:
  - Working with GitHub Issues
  - Managing sub-issues (parent-child relationships)
  - Posting comments to a PR
  - Posting inline comments to a PR
  - Replying to PR comments
  - Checking diffs with line numbers
---

# GitHub Skill

Guide for GitHub operations using gh CLI.
For mandatory rules, see `rules/git-github.md`.

## 1. Prerequisites

- gh CLI installed and authenticated
- jq installed (for JSON processing)

## 2. Issue Operations

### 2.1. Get Issue Information

```bash
gh issue view NUMBER --repo OWNER/REPO --json title,body,comments
```

### 2.2. Create Issue

```bash
gh issue create --repo OWNER/REPO --title "Title" --body "Body"
```

With template:

```bash
# Check templates first
ls .github/ISSUE_TEMPLATE/

# Create with specific template
gh issue create --template "bug_report.md"
```

### 2.3. Sub-issues (Parent-Child Relationship)

Standard gh CLI does not support sub-issues.
Use the `gh sub-issue` extension.

#### Install Extension

```bash
gh extension install agbiotech/gh-sub-issue
```

#### Commands

```bash
# Add sub-issue
gh sub-issue add <parent> --sub-issue-number <child>

# List sub-issues
gh sub-issue list <parent>

# Remove sub-issue
gh sub-issue remove <parent> --sub-issue-number <child>
```

## 3. Pull Request Operations

### 3.1. Get PR Information

Basic information:

```bash
gh pr view NUMBER --repo OWNER/REPO --json title,body,author,state,baseRefName,headRefName,url
```

Get current branch PR number:

```bash
gh pr view --json number -q '.number'
```

Get latest commit SHA (required for inline comments):

```bash
gh pr view NUMBER --repo OWNER/REPO --json commits --jq '.commits[-1].oid'
```

### 3.2. Check Diff

Diff with line numbers (for identifying inline comment positions):

```bash
gh pr diff NUMBER --repo OWNER/REPO | awk '
BEGIN { old_line=0; new_line=0; in_hunk=0 }
/^diff --git/ { in_hunk=0; print; next }
/^---/ || /^\+\+\+/ { print; next }
/^@@/ {
  in_hunk=1
  match($0, /-([0-9]+)/, old)
  match($0, /\+([0-9]+)/, new)
  old_line = old[1]
  new_line = new[1]
  print
  next
}
in_hunk && /^-/ { printf "L%-4d     | %s\n", old_line++, $0; next }
in_hunk && /^\+/ { printf "     R%-4d| %s\n", new_line++, $0; next }
in_hunk { printf "L%-4d R%-4d| %s\n", old_line++, new_line++, $0; next }
{ print }
'
```

Output format:

- `L123      |` - Deleted line (left side line number)
- `R456      |` - Added line (right side line number)
- `L123 R456 |` - Unchanged line (both line numbers)

### 3.3. Get Comments

Issue comments (PR-wide):

```bash
gh api repos/OWNER/REPO/issues/NUMBER/comments --jq '.[] | {id, user: .user.login, created_at, body}'
```

Review comments (inline):

```bash
gh api repos/OWNER/REPO/pulls/NUMBER/comments --jq '.[] | {id, user: .user.login, path, line, body, in_reply_to_id}'
```

Get all at once:

```bash
FILE1=$(mkoutput tmp --type output)
FILE2=$(mkoutput tmp --type output)
gh api repos/OWNER/REPO/issues/NUMBER/comments > "$FILE1"
gh api repos/OWNER/REPO/pulls/NUMBER/comments > "$FILE2"
```

### 3.4. Post Comments

PR-wide comment:

```bash
gh pr comment NUMBER --repo OWNER/REPO --body "Comment body"
```

For multiple lines:

```bash
gh pr comment NUMBER --repo OWNER/REPO --body "$(cat <<'EOF'
## Review Results

- Issue 1
- Issue 2
EOF
)"
```

Inline comment:

```bash
# Get latest commit SHA
COMMIT_SHA=$(gh pr view NUMBER --repo OWNER/REPO --json commits --jq '.commits[-1].oid')

# Post inline comment
gh api repos/OWNER/REPO/pulls/NUMBER/comments \
  --method POST \
  -f body="Comment body" \
  -f commit_id="$COMMIT_SHA" \
  -f path="path/to/file.py" \
  -F line=15 \
  -f side=RIGHT
```

| Parameter | Description                                     |
| --------- | ----------------------------------------------- |
| body      | Comment body                                    |
| commit_id | Target commit SHA                               |
| path      | File path (relative from repository root)       |
| line      | Line number (use R number from diff right side) |
| side      | RIGHT (added line) or LEFT (deleted line)       |

Reply to comment:

```bash
gh api repos/OWNER/REPO/pulls/NUMBER/comments/COMMENT_ID/replies \
  --method POST \
  -f body="Reply body"
```

## 4. Notes

### 4.1. Inline Comment Line Numbers

- Use diff right side (R) line numbers
- For comments on deleted lines, use `side=LEFT` and left side (L) line number
- Line numbers are absolute positions in file, not positions within diff hunk

### 4.2. Permissions

- Comment posting depends on GitHub permissions
- Only executable on repositories you have access to

## 5. Related Resources

| Resource         | Purpose                         |
| ---------------- | ------------------------------- |
| rules/git-github | Mandatory rules and permissions |
| skills/git       | Git-specific operations         |
