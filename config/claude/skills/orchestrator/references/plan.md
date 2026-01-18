# Plan Workflow

Universal plan workflow for any source.

## 1. Source Types

| Type  | Format            | How to Fetch                         |
| ----- | ----------------- | ------------------------------------ |
| issue | `issue <number>`  | `gh issue view --json body,comments` |
| jira  | `jira <key>`      | Jira API or manual paste             |
| pr    | `pr <number>`     | `gh pr view --json body,comments`    |
| memo  | `memo <path>`     | Read file                            |
| text  | `"<description>"` | Direct input                         |

## 2. Flow

```text
/my-plan <source>
<context>
    |
    v
[Plan Mode - READONLY]
    |
    +-- 1. Parse source and context
    |
    +-- 2. Investigate (use Worker/Subagent if needed)
    |
    +-- 3. Create plan -> .i9wa4/plans/
    |
    +-- 4. ExitPlanMode (user approval)
    |
    v
[Normal Mode]
    |
    +-- 5. Consult both Workers (codex + claude)
    |
    +-- 6. Fix issues if any
    |
    +-- 7. Ask user for parallel review count
    |
    +-- 8. Execute parallel review (see references/review.md)
    |
    +-- 9. Delegate implementation to Worker
    |
    +-- 10. PR or completion report
```

## 3. Plan Output

Save plan to `.i9wa4/plans/` with descriptive filename.

### 3.1. Template

```markdown
# Plan: <title>

## Source

- Type: <source_type>
- Reference: <source_reference>

## Context

<additional context from user>

## Investigation Summary

<findings from investigation phase>

## Implementation Plan

### Step 1: <step title>

- Files: <affected files>
- Changes: <what to change>

### Step 2: ...

## Risks and Considerations

- <risk 1>
- <risk 2>

## Test Strategy

- <how to verify>
```

## 4. Delegation

For Capability and Header format, see SKILL.md Section 2.2 and 2.3.

### 4.1. Investigation (READONLY)

```text
[SUBAGENT capability=READONLY]
Investigate <specific area> for plan.
Output: .i9wa4/plans/<descriptive-name>.md
```

### 4.2. Consultation (READONLY)

```text
[WORKER capability=READONLY to=%N]
Review this design approach. Any concerns?
```

### 4.3. Implementation (WRITABLE)

After plan approval:

```text
[WORKER capability=WRITABLE to=%N]
Implement the authentication module as specified in plan.
Reference: .i9wa4/plans/<plan-file>.md
```
