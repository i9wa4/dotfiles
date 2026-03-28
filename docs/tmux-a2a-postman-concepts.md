# How this dotfiles repo uses `tmux-a2a-postman`

This repo treats `tmux-a2a-postman` as part of the local development
environment, not as an isolated side tool.

That repo-local footing is visible in a few places:

- Home Manager installs the command and symlinks the live config directory from
  this repo
- tmux status-right calls `tmux-a2a-postman -- get-session-status-oneline`
- agent guidance depends on tmux pane titles as local role identity
- the runtime node templates live in `config/tmux-a2a-postman/postman.md`

So this document is not a generic upstream product overview. It is a concept
note for future readers of this dotfiles repo who need to understand how the
mail-and-role layer fits into the local setup.

AI-specific message rules live separately in
`docs/tmux-a2a-postman-ai-contract.md`.

## Why this exists

The operational template in `config/tmux-a2a-postman/postman.md` is optimized
for execution. It is not the fastest way to understand the local model.

This note is the shorter conceptual bridge between:

- the repo wiring that installs and surfaces the tool
- the node graph this repo expects to be running in tmux
- the local workflow rules layered on top of the runtime
- the known friction already observed in this repo's own sessions

Where this document makes a claim about intent, it is grounded in reasonable
repo-local inference from the current config, tmux integration, agent guidance,
and retained session behavior.

## Repo-local footprint

At the repo level, `tmux-a2a-postman` is wired into the environment in three
different ways.

### 1. Install and config management

Home Manager installs the command and exposes
`config/tmux-a2a-postman/` as the live XDG config directory for the user
environment. That means the checked-in config is intended to be the working
runtime config, not a dormant example.

### 2. tmux session visibility

The tmux module includes `tmux-a2a-postman -- get-session-status-oneline` in
the status line. In other words, mail/session health is treated as part of the
normal pane workflow, alongside repo status and system load.

### 3. Agent-role coordination

The repo's agent guidance says role name comes from the tmux pane title. The
postman layer therefore is not just "messaging in the abstract"; it is the
coordination fabric that ties pane identity, role prompts, and handoffs
together inside a tmux session.

## Local control-plane model

The practical model in this repo is a small tmux-scoped control plane:

- `messenger` talks to the user-facing edge
- `orchestrator` coordinates work and handoffs
- `worker` and `worker-alt` do implementation and investigation
- `critic` runs review routing
- `guardian` is a constrained approval hop behind `critic`
- `boss` is final approval authority

This is a repo-local operating model. It is implemented through the checked-in
templates and lived session behavior, not inferred from the upstream command
name alone.

## Current topology

The current local graph is:

```text
boss <-> orchestrator
messenger <-> orchestrator
orchestrator <-> worker
orchestrator <-> worker-alt
orchestrator <-> critic
critic <-> guardian
```

Practical meaning:

- `messenger` is the only user-facing node
- `orchestrator` coordinates, but does not implement
- `worker` and `worker-alt` execute
- `critic` owns the review pipeline
- `guardian` is only reachable through `critic`
- `boss` is the final approval checkpoint

## Recurring work lanes in this repo

Two lanes show up repeatedly in the local workflow.

### Plan lane

Used when the task needs a reviewed implementation plan before code changes.

Typical shape:

1. `messenger` relays the user request to `orchestrator`
2. `orchestrator` assigns planning work to `worker` or `worker-alt`
3. `orchestrator` sends the completed plan to `critic`
4. `critic` routes review through `guardian` and returns the verdict to
   `orchestrator`
5. `orchestrator` sends the approved plan to `boss`
6. `boss` returns final approval to `orchestrator`
7. `orchestrator` reports the approved result back to `messenger`

### Artifact lane

Used for actual repo edits, verification, and commit-ready artifacts.

The current checked-in approval route is:

`worker DONE -> orchestrator -> critic -> guardian -> critic ->
orchestrator -> boss -> orchestrator -> messenger`

`worker-alt` follows the same shape when it is the executing node.

The key repo-local rule is that `orchestrator` coordinates the lane but does
not do direct implementation.

## Local message rules that matter

The repo now treats two similar-looking message types as different classes:

- `status request`: asks for current state and requires a reply
- `status update`: informational relay, no reply unless the body says so

That distinction matters because generic footer text and older retained mail
can be broader or older than the current intent. In this repo, explicit body
instructions win.

## Repo-local policy versus runtime behavior

This repo intentionally separates local operating policy from upstream tool
behavior.

### Repo-local policy

These are choices this repo makes in the checked-in templates and docs:

- the node graph and role responsibilities
- the artifact approval route
- compact recurring status payloads
- conservative interpretation of health output before escalating a blocker

### Runtime behavior

These come from `tmux-a2a-postman` itself rather than from repo policy:

- message rendering and footer formatting
- session-health row aggregation or duplication
- on-disk wait-state storage
- command/output details of the CLI itself

When troubleshooting, the first question is which layer owns the behavior:
repo policy or runtime/tooling.

## Known friction already seen in this repo

Recent retrospective work in this repo found repeat problems in three areas.

### 1. Health counters are lossy

`waiting_count` alone is not enough to classify stuck delivery. Normal
`composing` and `user_input` waits can look blocked if you only read the
aggregate counter.

Local rule of thumb:

- start from `tmux-a2a-postman get-session-health`
- use direct send/reply evidence before claiming delivery is stuck
- escalate only on verified stale/orphaned waits or real send/reply failure

### 2. Footer wording and older prose can drift

Live mail shows `Reply:` footer lines. Older prose and older retained messages
may still mention `reply_command`. In this repo, agents should follow the live
`Reply:` footer or a direct successful send path, not stale terminology.

### 3. Historical route debris is still visible

Retained dead letters may still show:

- `postman` as if it were a live recipient
- direct `orchestrator -> guardian` traffic

Treat those as older signatures, not the current routing contract.

## How to read the local source of truth

If you need the authoritative version of the repo-local behavior, read these in
order:

1. `config/tmux-a2a-postman/postman.md`
2. `config/tmux-a2a-postman/postman.toml`
3. current live session mail if the issue is runtime-specific

Use this document first when the question is "how does this dotfiles repo use
the system?" Use `postman.md` when the question is operational or role-
specific.

## Related docs

- `docs/tmux-a2a-postman-ai-contract.md`
- `config/tmux-a2a-postman/postman.md`
- `config/tmux-a2a-postman/postman.toml`
