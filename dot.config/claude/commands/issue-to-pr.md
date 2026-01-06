---
description: "Issue to PR - 3-phase workflow management"
---

# issue-to-pr

Manage work flow: Explore -> Plan -> Code -> PR

Reference: Anthropic's Best Practices

## 1. Prerequisites

- Issue number can be obtained from directory name or branch name
- Always confirm with user before and after each phase

## 2. Phase State Management

Record phase transitions in `.i9wa4/phase.log`

```text
2025-01-01 10:00:00 | START -> EXPLORE
2025-01-01 11:00:00 | EXPLORE -> PLAN
...
```

When resuming:

1. Check last line of `.i9wa4/phase.log` to identify current phase
2. Continue work from that phase

## 3. Phases

### 3.1. EXPLORE (Investigation Phase)

ultrathink recommended

Pre-start confirmation:

- Get Issue body and all comments to understand requirements
- Record `START -> EXPLORE` in `.i9wa4/phase.log`
- Confirm investigation start with user

Actions:

- Analyze requirements
- Investigate scope of impact
- Review related code
- IMPORTANT: Do not write code in this phase. Investigation only.

Post-completion confirmation:

- Save investigation results to `.i9wa4/explore.md`
- Record `EXPLORE -> PLAN` in `.i9wa4/phase.log`
- Confirm investigation completion with user

### 3.2. PLAN (Planning Phase)

ultrathink recommended

Pre-start confirmation:

- Confirm planning start with user

Actions:

- Technical selection and architecture decisions
- Create implementation plan
- Determine testing strategy
- IMPORTANT: Do not write code in this phase. Planning only.

Post-completion confirmation:

- Save design content to `.i9wa4/plan.md`
- Record `PLAN -> CODE` in `.i9wa4/phase.log`
- Confirm planning completion with user

### 3.3. CODE (Implementation Phase)

Pre-start confirmation:

- Confirm implementation start with user

Actions:

- Implement according to plan
- Create commits as appropriate
- IMPORTANT: Verify solution validity as you progress

Post-completion confirmation:

- Verify all implementation is complete
- Record `CODE -> PR` in `.i9wa4/phase.log`
- Confirm implementation completion with user

### 3.4. PR (PR Creation Phase)

Pre-start confirmation:

- Confirm PR creation start with user

Actions:

1. Get last 10 PRs by @i9wa4 for style reference

    ```sh
    gh pr list --author i9wa4 --state all --limit 10 --json number,title,body
    ```

2. Load PR template if exists

    ```sh
    cat .github/PULL_REQUEST_TEMPLATE.md
    ```

3. Check if README or changelog needs updating, update if needed

4. Create draft PR

    ```sh
    gh pr create --draft --title "Title" --body "Body"
    ```

Post-completion confirmation:

- Show PR URL
- Record `PR -> COMPLETE` in `.i9wa4/phase.log`
- Confirm completion with user
