# Delta Communication

Format for reporting changes from Worker to Orchestrator.

## 1. Purpose

Communicate what changed efficiently with:

- Clear change summary
- Risk assessment
- Alternative approaches considered
- Whether user consultation is needed

## 2. Structure

| Item         | Key           | Description                        |
| ------------ | ------------- | ---------------------------------- |
| Changes      | changes       | Specific modifications made        |
| Risks        | risks         | Risk level and description         |
| Alternatives | alternatives  | Other approaches considered        |
| Consult      | needs_consult | User consultation required (yes/no)|

## 3. Format

### 3.1. In Response Messages

```text
DELTA:
  changes:
    - "src/auth/middleware.ts: Added JWT verification"
    - "src/types/user.ts: Added UserToken type"
  risks:
    - level: low
      desc: "All existing tests pass"
  alternatives:
    - "Session-based: Rejected (scalability concern)"
  needs_consult: no
```

### 3.2. Risk Levels

| Level    | Meaning                     |
| -------- | --------------------------- |
| critical | Data loss, security issue   |
| high     | Breaking change, API impact |
| medium   | Design decision needed      |
| low      | Minor implementation detail |

## 4. When to Include

| Situation                  | Include Delta |
| -------------------------- | ------------- |
| Task completion report     | Required      |
| Progress update            | Recommended   |
| Requesting guidance        | Required      |
| Simple status update       | Optional      |

## 5. Examples

### 5.1. Low Risk Change

```text
DELTA:
  changes:
    - "Added input validation to login form"
  risks:
    - level: low
      desc: "Non-breaking, tests added"
  alternatives: []
  needs_consult: no
```

### 5.2. Medium Risk Change

```text
DELTA:
  changes:
    - "Refactored database connection pooling"
    - "Changed default pool size from 10 to 20"
  risks:
    - level: medium
      desc: "May affect memory usage in production"
  alternatives:
    - "Keep pool size at 10: Would limit concurrency"
    - "Dynamic sizing: More complex, deferred"
  needs_consult: no
```

### 5.3. High Risk Change (Requires Consultation)

```text
DELTA:
  changes:
    - "Changed authentication from session to JWT"
  risks:
    - level: high
      desc: "Existing sessions will be invalidated"
  alternatives:
    - "Dual support during transition: Adds complexity"
    - "Migration script: Requires downtime"
  needs_consult: yes
```

## 6. Integration with State Record

When reporting, combine state and delta:

```text
STATE:
  objective: "..."
  current_state: "Step 3/5 complete"
  next_action: "Step 4: ..."

DELTA:
  changes: [...]
  risks: [...]
  needs_consult: no
```

This gives Orchestrator complete picture for decision making.
