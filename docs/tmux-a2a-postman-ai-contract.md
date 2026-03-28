# `tmux-a2a-postman` AI-facing contract

This is the short operational contract for agents working inside this repo's
`tmux-a2a-postman` system.

Authoritative template source:

- `config/tmux-a2a-postman/postman.md`

This document is intentionally separate from the broader concept note so agents
can load the execution model without digging through retrospective context.

## Core model

There are seven logical nodes:

- `messenger`
- `orchestrator`
- `worker`
- `worker-alt`
- `critic`
- `guardian`
- `boss`

Reachability is strict:

- `messenger` talks only to `orchestrator`
- `orchestrator` talks to `messenger`, `worker`, `worker-alt`, `critic`, and
  `boss`
- `critic` talks to `orchestrator` and `guardian`
- `guardian` talks only to `critic`
- `worker` and `worker-alt` report to `orchestrator`
- `boss` gives final approval to `orchestrator`

If a footer hint conflicts with the live graph or with a successful send in the
same context, trust the graph and actual delivery.

## Role contract

### `messenger`

- interface only
- does not implement or investigate
- relays user requests to `orchestrator`
- reports results back to the user

### `orchestrator`

- decomposes and routes work
- does not implement directly
- sends implementation to `worker` or `worker-alt`
- routes completed artifacts through review

### `worker` and `worker-alt`

- execute tasks with full tool access
- verify real outcomes before reporting success
- report `DONE:` or `BLOCKED:` to `orchestrator`

### `critic`

- owns review coordination
- must perform the mandatory review hop `critic -> guardian -> critic` from
  `config/tmux-a2a-postman/postman.md`
- sends final review verdict back to `orchestrator`

### `guardian`

- deep reviewer for `critic`
- never bypasses `critic`

### `boss`

- final approval authority
- does not implement

## Required approval route

Artifact work is complete only after the exact source-of-truth route succeeds:

`worker DONE -> orchestrator -> critic -> guardian -> critic ->
orchestrator -> boss -> orchestrator -> messenger`

`worker-alt` follows the same handoff pattern when it is the executor.

Do not collapse or bypass this route.

## Message handling rules

### Never ask the user from non-user-facing nodes

Only `messenger` talks to the human user. Other nodes make a decision, proceed,
and report outcome.

### Distinguish `status request` from `status update`

- `status request`: reply required
- `status update`: informational unless the body explicitly asks for a reply

If the body and generic footer text disagree, follow the body instruction.

### Keep recurring status compact

For recurring control-plane traffic, include only:

- current task
- blockers
- waiting_on
- next action
- the minimum evidence needed for any claimed state change

If nothing material changed, send a short delta rather than a full restatement.

## Health interpretation rules

Do not treat raw `waiting_count > 0` as proof of stuck delivery.

Before escalating:

1. start with `tmux-a2a-postman get-session-health`
2. classify the state using live session health plus direct send/reply evidence
3. escalate only if it is genuinely blocking

Useful categories in this repo:

- `expected/live`
- `stale/orphaned`
- `actionable/stuck`

Normal `composing` or `user_input` waits are not enough on their own to claim
delivery failure.

## Historical drift rules

Older retained mail may still show:

- `postman` as a recipient
- direct `orchestrator -> guardian` traffic
- wording built around `reply_command`

Treat these as historical signatures. The current local contract uses the live
node graph and visible `Reply:` footer routing.

## Failure reporting

Use concise terminal states:

- `DONE: <summary>`
- `BLOCKED: <reason>`

If a hook, permission rule, or tool restriction blocks the requested action, do
not retry silently. Report the block immediately.

## Practical reading order

When context is thin, load in this order:

1. this file for the operating contract
2. `config/tmux-a2a-postman/postman.md` for exact role wording
3. live session mail for context-specific routing or status state
