---
description: "Universal planning command for any source"
---

# my-plan

Universal planning command. Works with Issue, Jira, memo, PR, or text.

## 1. Usage

```text
/my-plan <source>
<additional context>
```

### 1.1. Source Types

| Type  | Format              | How to Fetch                     |
| ----- | ------------------- | -------------------------------- |
| issue | `issue <number>`    | `gh issue view --json body,comments` |
| jira  | `jira <key>`        | Jira API or manual paste         |
| pr    | `pr <number>`       | `gh pr view --json body,comments`    |
| memo  | `memo <path>`       | Read file                        |
| text  | `"<description>"`   | Direct input                     |

### 1.2. Additional Context

Free-form text after source. Examples:

- Related files or directories
- Reference URLs
- Constraints or requirements
- Technology preferences

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
    +-- 5. Implement
    |
    +-- 6. PR or completion report
```

## 3. Plan Mode Constraints

During planning phase:

- NEVER: Edit, Write, NotebookEdit (project files)
- ALLOWED: Read, Glob, Grep, Bash (read-only)
- ALLOWED: Write to `.i9wa4/` (plans, reports)
- ALLOWED: Delegate to Worker/Subagent with READONLY capability

## 4. Plan Output

Save plan to `.i9wa4/plans/` with descriptive filename.

### 4.1. Plan Template

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

## 5. Worker/Subagent Usage

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

## 6. Examples

### 6.1. Issue-based Planning

```text
/my-plan issue 123
Related files: src/auth/
Must use OAuth2
Need backward compatibility
```

### 6.2. Memo-based Planning

```text
/my-plan memo docs/new-feature.md
Reference: https://api.example.com/docs
Priority: high
```

### 6.3. Text-based Planning

```text
/my-plan "Add dark mode toggle to settings"
Use existing theme system in src/styles/
Follow Material Design guidelines
```
