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
    +-- 5. Delegate implementation to Worker/Subagent
    |
    +-- 6. PR or completion report
```

## 3. Orchestrator Constraints During Planning

- NEVER: Edit, Write, NotebookEdit (project files)
- ALLOWED: Read, Glob, Grep, Bash (read-only)
- ALLOWED: Write to `.i9wa4/` (plans, reports)
- DELEGATE: Investigation to Worker/Subagent with READONLY capability

## 4. Plan Output

Save plan to `.i9wa4/plans/` with descriptive filename.

### 4.1. Template

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

## 5. Delegation for Investigation

During investigation, delegate to Worker/Subagent as needed:

```text
[SUBAGENT capability=READONLY]
Investigate <specific area> for plan.
Output: .i9wa4/{timestamp}-cx-research-{id}.md
```

```text
[WORKER capability=READONLY]
Review this design approach. Any concerns?
```

## 6. Delegation for Implementation

After plan approval, delegate implementation:

```text
[SUBAGENT capability=WRITABLE]
Implement Step 1 of the plan.
Reference: .i9wa4/plans/<plan-file>.md
```

```text
[WORKER capability=WRITABLE]
Implement the authentication module as specified in plan.
```
