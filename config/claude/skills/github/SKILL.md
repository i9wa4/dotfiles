---
name: github
description: |
  GitHub operations guide using gh CLI.
  Use when:
  - Working with GitHub Issues
  - Managing sub-issues (parent-child relationships)
  - GitHub-specific workflows
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

## 3. Sub-issues (Parent-Child Relationship)

Standard gh CLI does not support sub-issues.
Use the `gh sub-issue` extension.

### 3.1. Install Extension

```bash
gh extension install agbiotech/gh-sub-issue
```

### 3.2. Commands

```bash
# Add sub-issue
gh sub-issue add <parent> --sub-issue-number <child>

# List sub-issues
gh sub-issue list <parent>

# Remove sub-issue
gh sub-issue remove <parent> --sub-issue-number <child>
```

### 3.3. Example Workflow

```bash
# Create parent issue
gh issue create --title "Epic: User Authentication" --body "Parent issue"
# Returns: Created issue #100

# Create child issues
gh issue create --title "Implement login form" --body "Sub-task 1"
# Returns: Created issue #101

gh issue create --title "Add OAuth support" --body "Sub-task 2"
# Returns: Created issue #102

# Link as sub-issues
gh sub-issue add 100 --sub-issue-number 101
gh sub-issue add 100 --sub-issue-number 102

# Verify
gh sub-issue list 100
```

## 4. Related Resources

| Resource                   | Purpose                        |
| -------------------------- | ------------------------------ |
| rules/git-github           | Mandatory rules and permissions|
| skills/git                 | Git-specific operations        |
| skills/pull-request-operation | PR-specific operations      |
