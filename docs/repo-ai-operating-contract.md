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

`nix/home-manager/agents/AGENTS.md` is the shared operating baseline for both
engines. It defines persona, workflow, safety, file handling, and repo-local
expectations.

On the Claude side, `CLAUDE.md` is appended as a small Claude-specific suffix.

On the Codex side, `instruction-artifacts.nix` takes the shared core plus the
repo-local rule files and emits the installed `.codex/AGENTS.md`.

### 2.2. Declarative installation

`claude-code.nix`, `codex-cli.nix`, and `agent-skills.nix` declaratively
materialize the runtime under:

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

These rules come from the shared agent core and are expected regardless of
engine:

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
- milestone state: track each plan milestone in two places:
  `[status: pending|in-progress|done]` on the milestone itself and timestamped
  checkbox lines in `Progress`
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
- preserve resumable handoff state
- reload handoff context on resume
- tighten cheap repair loops after deterministic failures

### 4.2. Claude runtime hooks

The Claude runtime currently carries:

- `UserPromptSubmit` for role, cwd, git, and usage context
- `PreToolUse` for observation plus Bash and write denials
- `PostToolUse` and `PostToolUseFailure` for observation
- `SessionStart` for reloading `CLAUDE.md` and saved handoff state
- `PreCompact` for saving a structured handoff snapshot

### 4.3. Codex runtime hooks

The Codex runtime currently carries:

- `UserPromptSubmit` for role, cwd, and git context
- `PreToolUse` for Bash denials
- `PostToolUse` for deterministic Bash remediation feedback
- `SessionStart` for saved handoff reload
- `Stop` for lightweight handoff persistence

The surface is not identical, but the repo is aiming for equivalent operating
discipline.

## 5. Shared policy sources

Two repo files matter especially because they are single sources of truth
consumed by both engines.

### 5.1. `denied-bash-commands.nix`

This file defines the dangerous Bash patterns once and then emits:

- Claude deny permissions
- the generated Bash deny patterns file used by Claude hooks
- the Codex `prefix_rule(...)` content used in `.codex/rules/default.rules`

If the repo changes a Bash safety policy, this is where it should happen.

### 5.2. `review/review-artifacts-gen.nix`

This file generates the installed review stack from shared fragments:

- reviewer agent definitions for Claude and Codex
- generated `subagent-review-*` skills for the engine and depth variants

That is how the repo keeps the review contract synchronized across engines.

### 5.3. Review-system specification

This section is the canonical repo-side specification for the review system.
`review/review-artifacts-gen.nix` remains the runtime generation SSOT, but
questions about public entrypoints, internal labels, normalization, aggregation,
and installed tree shape should be answered from this document.

#### 5.3.1. Canonical components

- `nix/home-manager/agents/review/review-artifacts-gen.nix`
- `nix/home-manager/agents/review/skills/subagent-review/SKILL.md`
- `nix/home-manager/agents/agent-skills.nix`
- `nix/home-manager/agents/claude-code.nix`
- `nix/home-manager/agents/codex-cli.nix`

#### 5.3.2. Current public state

Today the public review skill surface is five entrypoints in both
`~/.claude/skills` and `~/.codex/skills`:

- `subagent-review`
- `subagent-review-cc`
- `subagent-review-cc-deep`
- `subagent-review-cx`
- `subagent-review-cx-deep`

The wrapper currently accepts the same four internal labels directly:

- `cc`
- `cc-deep`
- `cx`
- `cx-deep`

With no arguments, `subagent-review` defaults to `cc cx`.

#### 5.3.3. Proposed public state

The approved simplification target is a smaller public surface, not a different
review topology. The target public entrypoints are:

- `subagent-review`
- `subagent-review-cc`
- `subagent-review-cx`

This is a visibility change only. The internal canonical labels remain:

- `cc`
- `cc-deep`
- `cx`
- `cx-deep`

Do not make bare `cc` and bare `cx` imply different default depths. Depth stays
explicit in the public syntax whenever it changes from the standard tier.

#### 5.3.4. Normalization rules

Public syntax may get shorter, but it must normalize to the same internal
labels before dispatch, counting, aggregation, or artifact naming happens.

| Public Syntax | Canonical Internal Label |
| ------------- | ------------------------ |
| `cc`          | `cc`                     |
| `cc deep`     | `cc-deep`                |
| `cx`          | `cx`                     |
| `cx deep`     | `cx-deep`                |

`subagent-review` with no arguments still normalizes to the pair `cc cx`.

#### 5.3.5. Aggregation contract

The aggregation layer stays keyed to the canonical labels, even if the public
skill surface shrinks.

- Baseline capture and result verification stay keyed to `cc`, `cc-deep`, `cx`,
  and `cx-deep`
- Review artifact filenames stay label-stable, such as `review-*-cc.md` and
  `review-*-cx-deep.md`
- Coverage tables, reporter labels, and merged-summary deduplication stay keyed
  to the canonical labels
- Public wrapper simplification must be a parsing layer over the canonical
  labels, not a rename of the aggregation contract

#### 5.3.6. `nix switch` materialization

Current materialization:

```text
~/.claude/skills/
  subagent-review/
  subagent-review-cc/
  subagent-review-cc-deep/
  subagent-review-cx/
  subagent-review-cx-deep/
~/.codex/skills/
  subagent-review/
  subagent-review-cc/
  subagent-review-cc-deep/
  subagent-review-cx/
  subagent-review-cx-deep/
~/.claude/agents/
  reviewer-{role}.md
  reviewer-{role}-deep.md
  ... 12 reviewer markdown files total
~/.codex/agents/
  reviewer-{role}.toml
  reviewer-{role}-deep.toml
  ... 12 reviewer TOML files total
```

Target materialization after the public-surface simplification:

```text
~/.claude/skills/
  subagent-review/
  subagent-review-cc/
  subagent-review-cx/
~/.codex/skills/
  subagent-review/
  subagent-review-cc/
  subagent-review-cx/
~/.claude/agents/
  reviewer-{role}.md
  reviewer-{role}-deep.md
  ... full reviewer runtime retained
~/.codex/agents/
  reviewer-{role}.toml
  reviewer-{role}-deep.toml
  ... full reviewer runtime retained
```

`agent-skills.nix` owns the skill-tree materialization into both engines.
`claude-code.nix` owns the installed Claude reviewer runtime under
`~/.claude/agents`. `codex-cli.nix` owns the installed Codex reviewer runtime
under `~/.codex/agents`, converting the generated reviewer markdown into TOML
agent definitions while keeping the same role and tier shape.

## 6. Claude/Codex parity contract

The repo expects parity of quality bar, not literal product sameness.

In practice that means:

- both engines should inherit the same repo-local operating core
- both engines should see the same review topology
- both engines should obey the same Bash deny policy
- both engines should have resumable handoff support
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

- Claude heavier reload/hook path
- Codex denser installed rules artifact
- launch-command parity now restored on both sides

These differences are acceptable only so long as they keep the same local
intent: safe execution, explicit handoff, and verifiable reporting.

## 7. `tmux-a2a-postman` routing contract

The repo-local postman graph has seven logical nodes:

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

If footer prose conflicts with the live graph or with successful delivery in
the same context, trust the graph and actual delivery.

## 8. Bounded approval-lane contract

This section is the canonical approval-lane policy for this repo.
`nix/home-manager/agents/AGENTS.md`,
`config/tmux-a2a-postman/postman.md`, and
`config/tmux-a2a-postman/postman.toml` should point here or restate this
section faithfully instead of drifting into separate policy variants.

### 8.1. Approval route

Artifact work is not complete until this exact Approval route succeeds:

`worker DONE -> orchestrator -> critic -> guardian -> critic ->
orchestrator -> boss -> orchestrator -> messenger`

`worker-alt` follows the same route when it is the executor.

Do not collapse or bypass the `critic -> guardian -> critic` hop.

### 8.2. Pass criteria

An approval-lane pass means all of the following are true:

- the worker reports `DONE:` with the artifact verified against the plan and
  intended file set
- critic returns `APPROVED:` with no remaining BLOCKING defects
- boss approves after critic approval
- orchestrator has no pending review cycle before sending `DONE:` onward

### 8.3. Defect-specific rejection

Approval failure must stay defect-specific.

- `NOT APPROVED:` from critic or boss must name the concrete blocking defects
- orchestrator returns that exact defect list to the worker instead of vague
  "try again" wording
- a reopened attempt must address the cited defects or explicitly explain why
  they no longer apply

### 8.4. Hard iteration cap

The approval loop is bounded.

- each artifact gets at most 3 approval attempts: the initial review plus 2
  rework attempts
- any critic `NOT APPROVED:` or boss rejection consumes one attempt
- if the third attempt still fails, stop the loop and report `BLOCKED:` with
  the blocking defect list instead of restarting again

### 8.5. Watchdog and fallback behavior

Approval-lane fallback behavior uses the same shared vocabulary everywhere:

- timeout assumptions come from `postman.toml`: `worker` and `worker-alt`
  900s / 15m, `critic`, `guardian`, `messenger`, and `orchestrator` 1800s /
  30m, `boss` 3600s / 60m
- guardian fallback: after the existing watchdog and resend ladder, critic may
  finish with a critic-only fallback verdict if guardian remains stale
- critic fallback: orchestrator sends one `[WATCHDOG]` prompt at or beyond the
  1800s / 30m threshold, then reports `BLOCKED:` if critic still does not
  reply; never bypass critic
- boss fallback: never bypass boss; at or beyond the 3600s / 60m threshold,
  report `BLOCKED:` waiting for boss instead of forcing completion
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

1. `nix/home-manager/agents/AGENTS.md`
2. `nix/home-manager/agents/claude-code.nix`
3. `nix/home-manager/agents/codex-cli.nix`
4. `nix/home-manager/agents/agent-skills.nix`
5. `config/tmux-a2a-postman/postman.md`
6. this file
