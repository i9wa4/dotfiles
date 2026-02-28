---
name: tmux-a2a-postman
description: |
  Role template auditor for tmux-a2a-postman multi-agent systems.
  Audits nodes/*.toml role definitions to fix node-to-node interaction breakdowns.
  Use when:
  - A node behaves unexpectedly (routes wrongly, ignores messages, approves nothing)
  - Nodes can't see each other in talks_to_line (after confirming PONG/session issue is ruled out)
  - Adding a new node and need to verify its template is complete and consistent
  - User wants to review or improve role definitions for any node
  Do NOT use for daemon-level failures (dead-letter from routing/edge misconfiguration);
  run triage first to determine if the issue is template-level.
---

# a2a-role-auditor

Audits `nodes/*.toml` role templates in a tmux-a2a-postman project to fix
node-to-node interaction breakdowns.

## Mandatory Triage Gate

Before running any template audit, determine whether the issue is daemon-level or
template-level.

**Daemon-level indicators** (stop here — report as config issue, do NOT produce patches):

- Wrong or missing edges in `postman.toml`
- `nodes/{node}.toml` file does not exist
- Session disabled in postman TUI

**Template-level confirmed** (node exists, edges correct, but behavior is wrong):

- Proceed to the 7-check audit below.

## 7-Check Audit

### Pre-check: File Existence (binary)

For every node referenced in `postman.toml` edges, verify `nodes/{node}.toml` exists.

- PASS: file present
- FAIL: file missing → emit BLOCKING finding; abort all further checks for that node

### Check 1 — PONG Awareness

The daemon calls `MarkPongReceived()` only when `info.To == "postman"` (message.go).
A node that does not send TO postman as the explicit recipient is never marked
PONG-active and remains invisible in other nodes' `talks_to_line`.

- PASS: template explicitly instructs the node to send a message with "postman" as
  recipient (e.g., "Send a PONG addressed to postman")
- FAIL: template references postman only as a routing mechanism ("via postman"), or has
  no postman mention at all

### Check 2 — Routing Clarity

- PASS: template names at least one recipient for output messages
- FAIL: template says "send a message" without specifying who receives it

### Check 3 — Completion Protocol

- PASS: template specifies a machine-readable signal word (e.g., APPROVED, DONE, BLOCKED)
  for task completion
- FAIL: completion state is undefined or described only in natural language

### Check 4 — Fallback Routing

- PASS: template names an alternative recipient when the primary contact is absent from
  `talks_to_line`
- FAIL: no fallback specified

### Check 5 — Cross-Edge Consistency

Two sub-checks:

- **Binary**: does the template mention only nodes that exist as edges in `postman.toml`?
  (PASS/FAIL — no judgment)
- **Judgment**: are the described routing semantics consistent with edge direction?
  (LLM assessment — label findings with `Type: JUDGMENT-BASED`)

### Check 6 — on_join Completeness

- PASS: `on_join` field is non-empty
- FAIL: `on_join = ""`

## Findings Format

Every finding MUST use this exact schema:

```text
[SEVERITY] Node: {node}
Field: nodes/{node}.toml:[{node}].{field}
Check: {check name}
[Type: JUDGMENT-BASED]   <- optional, only when applicable
Result: FAIL
Issue: {description}
Fix:
  {exact replacement text}
```

Severity: `BLOCKING` | `IMPORTANT` | `MINOR`

`Type: JUDGMENT-BASED` is a separate flag, not a severity level.
Present findings in order: BLOCKING first, then IMPORTANT, then MINOR.

## Workflow

1. Read `postman.toml` — extract edges, build adjacency map
2. Read each `nodes/{node}.toml` (source of truth; runtime session templates are NOT compared)
3. For each node: run Pre-check, then Checks 1–6 in order
4. Produce findings report sorted by severity
5. Propose concrete patch text for every finding
6. Present to user for feedback; iterate until approved

NOTE: Do NOT auto-apply patches. Propose only; the user applies manually or delegates to worker.

## Baseline Examples

The following issues were identified in a real audit session and serve as illustrative examples.

### Example 1 — Routing clarity (IMPORTANT)

```text
[IMPORTANT] Node: critic
Field: nodes/critic.toml:[critic].template
Check: Routing clarity
Result: FAIL
Issue: Template says "send a message via postman" without specifying a recipient.
Fix:
  "Send findings to orchestrator. If orchestrator is absent from
  talks_to_line, send to guardian who will relay."
```

### Example 2 — Completion protocol (IMPORTANT)

```text
[IMPORTANT] Node: boss
Field: nodes/boss.toml:[boss].template
Check: Completion protocol
Result: FAIL
Issue: No machine-readable approval signal defined. Recipients cannot parse
  the response programmatically.
Fix:
  "Reply with 'APPROVED: <summary>' when approving,
  or 'REJECTED: <reason>' when rejecting."
```

### Example 3 — Cross-edge consistency (IMPORTANT, JUDGMENT-BASED)

```text
[IMPORTANT] Node: guardian
Field: nodes/guardian.toml:[guardian].template
Check: Cross-edge consistency
Type: JUDGMENT-BASED
Result: FAIL
Issue: Guardian acts as a routing relay between critic and orchestrator,
  but this is not documented. Forwarding-to-boss path is also absent.
Fix:
  "After receiving critic findings: if approved, forward to boss.
  If rejected, return to critic with specific revision request."
```

### Example 4 — on_join completeness (MINOR)

```text
[MINOR] Node: worker
Field: nodes/worker.toml:[worker].on_join
Check: on_join completeness
Result: FAIL
Issue: on_join is empty; node receives no startup context.
Fix:
  on_join = "You are worker. Send PONG to postman on startup, then await task assignment from orchestrator."
```

### Example 5 — PONG awareness (BLOCKING)

```text
[BLOCKING] Node: orchestrator
Field: nodes/orchestrator.toml:[orchestrator].template
Check: PONG awareness
Result: FAIL
Issue: Template references postman only as a routing mechanism, never as explicit
  recipient. Node will not be marked PONG-active and will be invisible in
  other nodes' talks_to_line.
Fix:
  Add to startup section: "On session start, send a PONG message addressed TO postman
  (recipient = postman, not via postman). This registers you as active."
```

## Constraints

- Propose patches only; do NOT auto-apply
- When an issue is daemon-level (wrong edges, missing file, disabled session), note it as
  a config finding — template patches cannot fix it
- Manual integration test for `talks_to_line` visibility: if both nodes have not yet
  sent PONG in the current session, mark the result `INCONCLUSIVE` (environment), not
  a skill failure
