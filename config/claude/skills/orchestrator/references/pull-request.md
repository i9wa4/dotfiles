# Pull Request Workflow

PR creation workflow after implementation.

## 1. Prerequisites

- Implementation complete
- Tests passing
- Ready for PR creation
- IMPORTANT: Always create as **draft** PR

## 2. Flow

```text
Orchestrator
    |
    +-- 1. Confirm with user: ready for PR?
    |
    +-- 2. Gather PR context
    |
    +-- 3. Consult both Workers (codex + claude)
    |
    +-- 4. Fix issues if any
    |
    +-- 5. Create PR (Worker WRITABLE)
    |
    +-- 6. Report PR URL
```

NOTE: PR phase has no parallel review.

For Capability and Header format, see SKILL.md Section 2.2 and 2.3.

## 3. Gather PR Context

### 3.1. Reference Past PRs

Get style reference from recent PRs:

```bash
gh pr list --author i9wa4 --state all --limit 10 --json number,title,body
```

### 3.2. Load PR Template

```bash
cat .github/PULL_REQUEST_TEMPLATE.md
```

### 3.3. Check Documentation

- README needs update?
- CHANGELOG needs update?
- Other docs affected?

## 4. Worker Consultation

Before creating PR, consult both Workers:

```text
[WORKER capability=READONLY to=%N]

## PR Draft Review

Title: <title>
Body: <body>

## Ask

Any concerns before creating PR?
```

## 5. Create PR

### 5.1. Delegation Template

```text
[WORKER capability=WRITABLE to=%N]

Create draft PR with:
- Title: <title>
- Body: <body>
- Base: main

Use: gh pr create --draft --title "..." --body "..."
```

NOTE: Always use `--draft` flag. User will mark as ready when reviewed.

### 5.2. PR Body Template

```markdown
## Summary

- <change 1>
- <change 2>

## Background

<why this change>

## Changes

- <specific change 1>
- <specific change 2>

## Test Plan

- [ ] <test item 1>
- [ ] <test item 2>

## Related

- Issue: #<number>
```

## 6. Post-PR

1. Record in phase.log: `CODE -> PR -> COMPLETE`
2. **IMPORTANT**: Display PR URL to user

```text
PR created: https://github.com/<owner>/<repo>/pull/<number>
```
