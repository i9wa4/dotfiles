---
description: "Issue to PR - 4-phase workflow management"
---

# issue-to-pr

Manage work flow: Explore -> Plan -> Code -> PR

Reference: [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)

## 1. Prerequisites

- Issue number can be obtained from directory name or branch name
- Always confirm with user before and after each phase
- Use tmux-pane-relay for consultation at phase boundaries

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

## 3. Relay Consultation (tmux-pane-relay)

### 3.1. When to Consult

- Required: End of EXPLORE/PLAN/CODE, before PR creation
- Optional: When uncertain (unclear requirements, technical decisions)

### 3.2. Consultation Template

```text
[AI REQUEST id=YYYYMMDD-HHMMSS-XXXX from=claude pane=%1 to=codex to_pane=%2]

## Phase: <current phase>

## Summary
- <brief summary of work done>

## Key Points
- <point 1>
- <point 2>

## Open Questions
- <question 1>
- <question 2>

## Ask
<specific question: OK to proceed? Any concerns?>

[RESPONSE INSTRUCTIONS]
When done, send response via:
tmux send-keys -t %1 -l -- "[AI RESPONSE id=YYYYMMDD-HHMMSS-XXXX from=codex pane=%2 to=claude to_pane=%1] {your response}" && sleep 0.5 && tmux send-keys -t %1 Enter
```

### 3.3. Decision Flow

After receiving consultation response:

1. **Continue**: Proceed to next phase
2. **Revise**: Make adjustments based on feedback
3. **Ask User**: If unclear or needs human decision, ask user

## 4. Phases

### 4.1. EXPLORE (Investigation Phase)

ultrathink recommended

Pre-start:

- Get Issue body and all comments to understand requirements
- Record `START -> EXPLORE` in `.i9wa4/phase.log`
- Confirm investigation start with user

Actions:

- Analyze requirements
- Investigate scope of impact
- Review related code
- IMPORTANT: Do not write code in this phase. Investigation only.

Post-completion:

- Save investigation results to `.i9wa4/explore.md`
- Relay consultation with summary:
    - Problem summary, constraints, impact scope, open questions
    - Ask: OK to proceed to PLAN?
- Based on consultation: continue / revise / ask user
- Record `EXPLORE -> PLAN` in `.i9wa4/phase.log`

### 4.2. PLAN (Planning Phase)

ultrathink recommended

Pre-start:

- Confirm planning start with user

Actions:

- Technical selection and architecture decisions
- Create implementation plan
- Determine testing strategy
- IMPORTANT: Do not write code in this phase. Planning only.

Post-completion:

- Save design content to `.i9wa4/plan.md`
- Relay consultation with summary:
    - Change approach, key files, risks, test strategy
    - Ask: OK to proceed to CODE?
- Based on consultation: continue / revise / ask user
- Record `PLAN -> CODE` in `.i9wa4/phase.log`

### 4.3. CODE (Implementation Phase)

Pre-start:

- Confirm implementation start with user

Actions:

- Implement according to plan
- Create commits as appropriate
- IMPORTANT: Verify solution validity as you progress

Post-completion:

- Verify all implementation is complete
- Relay consultation with summary:
    - Notable changes, concerns, test results
    - Ask: OK to proceed to PR?
- Based on consultation: continue / revise / ask user
- Record `CODE -> PR` in `.i9wa4/phase.log`

### 4.4. PR (PR Creation Phase)

Pre-start:

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

4. Relay consultation with PR draft:
   - Title, body, risks, verification
   - Ask: Any concerns before creating PR?

5. Based on consultation: continue / revise / ask user

6. Create draft PR

    ```sh
    gh pr create --draft --title "Title" --body "Body"
    ```

Post-completion:

- Show PR URL
- Record `PR -> COMPLETE` in `.i9wa4/phase.log`
- Confirm completion with user
