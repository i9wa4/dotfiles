# Repo AI Operating Contract

This is the standalone operating contract for AI work in this repo.

It is broader than `tmux-a2a-postman` alone. The scope here is the whole
repo-local AI runtime under `nix/home-manager/agents`, plus the routing and
approval contract carried by `tmux-a2a-postman`.

For the broader repository philosophy, read
`docs/dotfiles-operating-concepts.md`.

## 1. Scope

Use this document when the question is "how should an AI agent operate inside
this repo right now?"

That includes:

- shared operating instructions
- installed Claude and Codex configuration under Home Manager
- hooks and resumable handoff behavior
- skill and review installation
- tmux role identity
- `tmux-a2a-postman` routing and approval rules

## 2. Repo-local AI stack

The repo-local AI stack is assembled from a few core sources.

### 2.1. Shared instruction core

The current shared instruction core flows through `tmux-a2a-postman` common
delivery rather than generated runtime-root instruction files.

The persona / language / scope contract lives in
`config/tmux-a2a-postman/postman.md` `[common_template]` §2.24, and the
repo-local skill bodies (bash, github, markdown, python, repo-local)
are inlined as `[common_template]` §2.16-§2.22. Postman injects these
into every role pane on each `tmux-a2a-postman pop`.

There is no generated root instruction file under `~/.claude/` or `~/.codex/`
for this repo. Direct non-postman sessions rely on the installed runtime
settings and skill trees until they receive a postman event.

### 2.2. Declarative installation

`nix/home-manager/agents/claude/default.nix`,
`nix/home-manager/agents/codex/default.nix`, and
`nix/home-manager/agents/shared/agent-skills.nix` declaratively materialize
the runtime under:

- `~/.claude/`
- `~/.codex/`
- `~/.claude/skills`
- `~/.codex/skills`

The point is that the installed runtime should come from this repo, not from
manual edits in home directories.

### 2.3. tmux role identity

Inside this repo, role identity is tied to the tmux pane title. That means
role, routing, and prompt context are linked to the pane you are currently in,
not just to abstract agent labels.

## 3. Shared operating rules

These rules are the residual loaded prompt rules kept local because
non-postman Claude/Codex sessions still need them. Postman-role sessions also
receive the stronger common contract from `tmux-a2a-postman`.

They come from the postman common contract plus the installed local skills and
are expected regardless of engine:

- read files in full
- verify against the actual repo before reporting
- prefer small verifiable steps
- use Nix-managed or POSIX-safe tooling where possible
- avoid destructive git operations unless explicitly instructed
- treat pane-title identity as important runtime state

For worker-style nodes inside the postman graph, two more rules matter:

- non-user-facing nodes do not end by asking the human user a question
- success and failure are reported as `DONE:` or `BLOCKED:`

### 3.1. Durable `mkmd` handoff artifacts

`mkmd` is the default way to keep cross-agent context durable in this repo.
Do not rely on chat history or short status traffic alone when later readers
will need to recover why work moved, what changed, or what still needs
verification.

Create or update a durable `mkmd` artifact when any of these are true:

- review findings, rework notes, or approval-defect lists need to move between
  nodes
- a development handoff needs more than `current task`, `blockers`,
  `waiting_on`, and `next action` for the next node to continue safely
- a small decision, rejection, or investigation result is likely to be reused
  by a later pass

A short status update is enough only when the next node needs no context beyond
the current control-plane state.

Use the standard `mkmd` directories by artifact type:

- `draft` for temporary working notes and handoff drafts
- `research` for investigation findings and decision support
- `reviews` for completion or review artifacts
- `plans` for execution plans
- `tmp` for disposable scratch output

### 3.2. Markdown checklist workflow for task artifacts

When work needs a durable task tracker, use a `mkmd` markdown artifact instead
of ad hoc chat prose.

- intake rule: if the work will span multiple steps, nodes, or review rounds,
  create or update a `plans` or `research` artifact before implementation
- single-tracker rule: if a task already provides a plan path, keep updating
  that artifact instead of creating a competing checklist elsewhere
- plan artifact shape: `plans` artifacts must include Purpose, Acceptance
  Criteria, Milestones, Decision Log, Risks, Test Strategy, Progress, Touched
  Files, Verification, and Surprises and Discoveries
- milestone state: track each plan milestone in two places:
  `[status: pending|in-progress|done]` on the milestone itself and timestamped
  checkbox lines in `Progress`
- milestone metadata: each milestone in `plans` artifacts must state scope,
  deliverables, files, and verification metadata
- checklist shape: use
  `- [ ] {YYYY-MM-DD HH:MM} Milestone 1 started` when work begins and
  `- [x] {YYYY-MM-DD HH:MM} Milestone 1 completed -- <evidence>` when it ends
- verification evidence: when a milestone completes, append the actual verifier
  output or result summary under that milestone and log surprises separately
- completion artifact rule: `reviews` artifacts should point to the plan path,
  list the touched files, and summarize the verification outcomes that justify
  the terminal state
- `DONE:` gate: do not send `DONE:` until the markdown artifact, intended file
  set, and observed verification evidence all agree

## 4. Hook contract

Hooks are not optional conveniences in this repo. They are part of the local
operating contract.

### 4.1. Shared intent across engines

Both engines are expected to support these behaviors as closely as their hook
surfaces allow:

- inject live repo context into prompts
- deny dangerous Bash actions before execution
- keep handoff state durable through postman messages and `mkmd` artifacts

### 4.2. Claude runtime hooks

The Claude runtime currently carries:

- `UserPromptSubmit` for role, cwd, git, and usage context
- `PreToolUse` for shared Bash denials
- `PreToolUse` for Claude-only role write denials

### 4.3. Codex runtime hooks

The Codex runtime currently carries:

- `UserPromptSubmit` for role, cwd, and git context
- `PreToolUse` for Bash denials

The surface is not identical, but the repo is aiming for equivalent operating
discipline.

## 5. Shared policy sources

Two repo files matter especially because they are single sources of truth
consumed by both engines.

### 5.1. `shared/denied-bash-commands.nix`

This file defines the dangerous Bash patterns once and then emits:

- Claude deny permissions
- the generated Bash deny patterns file used by Claude hooks
- the Codex `prefix_rule(...)` content used in `.codex/rules/default.rules`

If the repo changes a Bash safety policy, this is where it should happen.

### 5.2. `shared/render-agents.nix`

This file generates the installed shared agent surface from
`subagents/_metadata.nix` and `subagents/*.md`:

- Claude markdown agent definitions
- Codex TOML agent definitions
- the generated `subagent-review` dispatcher skill

That is how the repo keeps reviewer agents and review dispatch synchronized
across engines.

### 5.3. Review-system specification

This section is the canonical repo-side specification for the current review
system. `shared/render-agents.nix` is the runtime generation SSOT, while this
document describes the public entrypoint, tier model, and installed tree shape.

#### 5.3.1. Canonical components

- `nix/home-manager/agents/shared/render-agents.nix`
- `nix/home-manager/agents/subagents/_metadata.nix`
- `nix/home-manager/agents/subagents/*.md`
- `nix/home-manager/agents/shared/agent-skills.nix`
- `nix/home-manager/agents/claude/default.nix`
- `nix/home-manager/agents/codex/default.nix`

#### 5.3.2. Current public state

The public review skill surface is one generated dispatcher in both
`~/.claude/skills` and `~/.codex/skills`:

- `subagent-review`

The dispatcher accepts space-separated engine and tier tokens:

| Token Type | Values          | Meaning                           |
| ---------- | --------------- | --------------------------------- |
| Engine     | `cc`, `cx`      | Claude or Codex reviewer pool     |
| Tier       | `tier1`, `tier2` | Deep or shallow model assignment  |

With no arguments, `subagent-review` defaults to `cc tier2 cx tier2`.
The dispatcher fans out to the five review perspectives currently named in
the generated skill: security, architecture, historian, code, and QA.

#### 5.3.3. Tier contract

Tier defaults live in `subagents/_metadata.nix` and are baked into the
generated dispatcher skill by `shared/render-agents.nix`.

The agent files themselves carry tier 2 defaults. Tier 1 is selected at spawn
time by the dispatcher through per-call model and effort overrides, not by
installing a second set of agent files.

#### 5.3.4. `nix switch` materialization

Current materialization:

```text
~/.claude/skills/
  subagent-review/
~/.codex/skills/
  subagent-review/
~/.claude/agents/
  <metadata agent name>.md
~/.codex/agents/
  <metadata agent name>.toml
```

`shared/agent-skills.nix` owns the skill-tree materialization into both
engines. `claude/default.nix` installs the Claude agent directory under
`~/.claude/agents`. `codex/default.nix` installs the Codex agent directory
under `~/.codex/agents`.

## 6. Claude/Codex parity contract

The repo expects parity of quality bar, not literal product sameness.

In practice that means:

- both postman-driven engines should receive the same repo-local operating core
- both engines should see the same review topology
- both engines should obey the same Bash deny policy
- both engines should use the same durable handoff discipline through postman
  traffic and `mkmd` artifacts
- both engines should be able to participate in the same repo-local review and
  routing model

When an engine cannot match the other feature-for-feature, the fallback should
still preserve the same intent: safe execution, explicit handoff, and
verifiable reporting.

## Intentional Claude/Codex Asymmetries

Shared policy that must stay aligned across Claude and Codex

The shared policy line above is the part that must not drift. Both engines are
still expected to inherit the same repo-local operating core, deny policy,
review topology, resumable handoff discipline, and launch-command visibility in
`UserPromptSubmit`.

Within that shared policy, the repo currently treats these differences as
intentional:

- Claude-only role write-deny hook
- Codex denser installed rules artifact
- Claude script-based status line and Codex declarative TOML status line

These differences are acceptable only so long as they keep the same local
intent: safe execution, explicit handoff, and verifiable reporting.

## 7. `tmux-a2a-postman` routing contract

The approval workflow has seven standing role nodes:

- `messenger`
- `orchestrator`
- `worker`
- `worker-alt`
- `reviewer`
- `guardian`
- `boss`

The live postman graph also contains an auxiliary `agent` node connected to
`orchestrator`. It is excluded from the approval-workflow count because it is
not part of the normal human-facing, execution, review, guardian, or boss
approval lane.

Reachability is strict:

- `messenger` talks only to `orchestrator`
- `orchestrator` talks to `messenger`, `worker`, `worker-alt`, `reviewer`, and
  `boss`
- `reviewer` talks to `orchestrator` and `guardian`
- `guardian` talks only to `reviewer`
- `worker` and `worker-alt` report to `orchestrator`
- `boss` gives final approval to `orchestrator`
- `agent` is reachable from `orchestrator` for auxiliary work outside the
  approval lane

If footer prose conflicts with the live graph or with successful delivery in
the same context, trust the graph and actual delivery.

## 8. Bounded approval-lane contract

This section is the canonical approval-lane policy for this repo.
`config/tmux-a2a-postman/postman.md` should point here or restate this section
faithfully instead of drifting into separate policy variants.

### 8.1. Approval route

Artifact work is not complete until this exact Approval route succeeds:

`worker DONE -> orchestrator -> reviewer -> guardian -> reviewer ->
orchestrator -> boss -> orchestrator -> messenger`

`worker-alt` follows the same route when it is the executor.

Do not collapse or bypass the `reviewer -> guardian -> reviewer` hop.

### 8.2. Pass criteria

An approval-lane pass means all of the following are true:

- the worker reports `DONE:` with the artifact verified against the plan and
  intended file set
- reviewer returns `APPROVED:` with no remaining BLOCKING defects
- boss approves after reviewer approval
- orchestrator has no pending review cycle before sending `DONE:` onward

### 8.3. Defect-specific rejection

Approval failure must stay defect-specific.

- `NOT APPROVED:` from reviewer or boss must name the concrete blocking defects
- orchestrator returns that exact defect list to the worker instead of vague
  "try again" wording
- a reopened attempt must address the cited defects or explicitly explain why
  they no longer apply

### 8.4. Hard iteration cap

The approval loop is bounded.

- each artifact gets at most 3 approval attempts: the initial review plus 2
  rework attempts
- any reviewer `NOT APPROVED:` or boss rejection consumes one attempt
- if the third attempt still fails, stop the loop and report `BLOCKED:` with
  the blocking defect list instead of restarting again

### 8.5. Watchdog and fallback behavior

Approval-lane fallback behavior uses the same shared vocabulary everywhere.
These timeout thresholds are role policy, not daemon configuration:

- all routed nodes use 180s / 3m as the missing-response alert boundary
- `worker` and `worker-alt` use 900s / 15m as the idle boundary
- `reviewer`, `guardian`, `messenger`, and `orchestrator` use 1800s / 30m as
  the idle boundary
- `boss` uses 3600s / 60m as the idle boundary

Fallback behavior:

- guardian fallback: after the existing watchdog and resend ladder, reviewer may
  finish with a reviewer-only fallback verdict if guardian remains stale after
  the 180s / 3m alert and the 1800s / 30m review-node idle boundary
- reviewer fallback: orchestrator sends one `[WATCHDOG]` prompt at or beyond the
  180s / 3m late-reply threshold, then reports `BLOCKED:` if reviewer still does
  not reply once direct send failure evidence appears or the 1800s / 30m
  review-node idle boundary is crossed; never bypass reviewer
- boss fallback: never bypass boss; late-reply alerts still fire after
  180s / 3m, and at or beyond the 3600s / 60m idle boundary report
  `BLOCKED:` waiting for boss instead of forcing completion
- hook, permission, or tool-restriction blocks are immediate `BLOCKED:` states
  with no silent retry

## 9. Status and routing rules

### 9.1. `status request` is not `status update`

- `status request`: reply required
- `status update`: informational unless the body explicitly asks for a reply

If explicit body instructions and generic footer text disagree, follow the body
instruction.

### 9.2. Keep recurring status compact

Use only the smallest useful delta:

- current task
- blockers
- waiting_on
- next action
- the minimum evidence needed to justify a changed state

Do not re-expand the full situation when nothing material changed.

### 9.3. Footer lines are hints, not authority

`You can talk to:`, `Reply:`, and `No reply needed for:` are useful routing
hints, but they do not override the checked-in graph or a known live delivery
result.

## 10. Delivery-health rules

Do not treat raw `waiting_count > 0` as proof of stuck delivery.

Before escalating:

1. start with `tmux-a2a-postman get-health`
2. classify the state using live session health plus direct send/reply evidence
3. escalate only if it is genuinely blocking

Normal `composing` and `user_input` waits are not enough on their own to claim
delivery failure. The repo's current rule is: Do NOT inspect raw wait files.

## 11. Historical-drift rules

Older retained mail may still show:

- `postman` as if it were a current live recipient
- direct `orchestrator -> guardian` traffic
- wording based on `reply_command`

Treat those as historical signatures rather than the current contract.

## 12. Failure reporting

Use concise terminal states:

- `DONE: <summary>`
- `BLOCKED: <reason>`

If a hook, permission rule, or tool restriction blocks the requested action, do
not retry silently. Report the block immediately.

## 13. Recommended reading order

When context is thin, read in this order:

1. `nix/home-manager/agents/README.md`
2. `nix/home-manager/agents/claude/default.nix`
3. `nix/home-manager/agents/codex/default.nix`
4. `nix/home-manager/agents/shared/agent-skills.nix`
5. `config/tmux-a2a-postman/postman.md`
6. this file
