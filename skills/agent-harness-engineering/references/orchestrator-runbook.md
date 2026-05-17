# Orchestrator Runbook

This reference preserves durable orchestration procedures that do not belong in
the live role contract.

The live orchestrator identity, routing rules, reply flow, approval lane, and
completion gates remain in `config/tmux-a2a-postman/postman.md`. Keep that file
as the runtime source of truth for what the orchestrator must do during a live
session. Use this reference when maintaining the harness, writing plans, or
auditing whether orchestration details still belong in the live template.

## Ownership Boundary

- Keep live role identity, routing, reply behavior, approval ordering,
  escalation thresholds, and completion vocabulary in
  `config/tmux-a2a-postman/postman.md`.
- Keep durable design notes, historical workflow recipes, and long examples in
  `skills/agent-harness-engineering/references/`.
- Keep task artifacts in `mkmd` plan or research files and cite the same
  artifact in worker, review, and completion traffic.
- Do not restore a standalone role-only `skills/orchestrator/` skill unless the
  live postman role no longer carries enough contract to operate safely.

## Runtime Reference Boundary

- Treat repo `docs/` as background for people and repo readers, not as the only
  home for behavior that installed Agent Skills need at runtime.
- Keep durable orchestration procedures in this reference when global skill
  installation must be able to read them without opening repo docs.
- Keep this reference compact. Mirror operational invariants from docs only
  when they affect live orchestration behavior.
- If this reference and `config/tmux-a2a-postman/postman.md` disagree, update
  the live role contract first, then mirror the durable invariant here.

## Routing and Approval Invariants

The approval workflow has these standing role nodes:

- `messenger`
- `orchestrator`
- `worker`
- `worker-alt`
- `critic`
- `guardian`
- `boss`

An auxiliary `agent` node may be reachable from `orchestrator` for work outside
the normal approval lane.

Reachability is strict:

- `messenger` talks only to `orchestrator`.
- `orchestrator` talks to `messenger`, `worker`, `worker-alt`, `guardian`,
  `boss`, and auxiliary `agent`.
- `critic` talks only to `guardian`.
- `guardian` receives review requests from `orchestrator`, sends review
  packages to `critic`, receives critic recommendations, and relays the
  guardian-owned verdict to `orchestrator`.
- `worker` and `worker-alt` report to `orchestrator`.
- `boss` gives final approval to `orchestrator`.

Artifact work is complete only after this route succeeds:

```text
worker DONE -> orchestrator -> guardian -> critic
-> guardian -> orchestrator -> boss -> orchestrator -> messenger
```

`worker-alt` follows the same route when it is the executor.

Approval requires all of these conditions:

- the executor reports `DONE:` after verifying the artifact against the plan
  and intended file set;
- guardian completed first review and sent evidence to critic;
- critic returned an approval recommendation to guardian with no remaining
  blocking defects;
- guardian relayed a guardian-owned verdict to orchestrator;
- boss approved after guardian approval considered critic's recommendation;
- orchestrator has no pending review cycle before sending `DONE:` onward.

Approval failures must stay defect-specific. `NOT APPROVED:` from guardian or
boss names the blocking defects, and orchestrator returns that concrete defect
list to the executor.

The approval loop is bounded to 3 attempts: the initial review plus 2 rework
attempts. Any guardian `NOT APPROVED:` or boss rejection consumes one attempt.
After the third failed attempt, stop and report `BLOCKED:` with the remaining
defects.

Status and delivery rules:

- `status request` requires a reply; `status update` is informational unless
  the body explicitly asks for a reply.
- Keep recurring status traffic compact: current task, blockers, waiting_on,
  next action, and only the evidence needed for a changed state.
- Treat footer lines such as `You can talk to:` and `Reply:` as hints when they
  conflict with the checked-in graph or observed delivery.
- Before escalating delivery health, start with `tmux-a2a-postman get-status`,
  combine live health with direct send or reply evidence, and escalate only
  genuine blockers.
- Do not treat `composing`, `user_input`, unread mail, or quiet panes as proof
  of stuck delivery by themselves. Do not inspect raw wait files.

Historical retained mail can show old recipients, old review routes, or
`reply_command` wording. Treat those as drift signatures, not the current
contract.

## Task Classification

When a user request reaches orchestrator, classify it before delegation:

| Request signal   | Expected lane                                      |
| ---------------- | -------------------------------------------------- |
| plan, design     | Ask worker to create or update a plan artifact     |
| review           | Route the review package through guardian/critic   |
| code, implement  | Delegate implementation to worker or worker-alt    |
| PR, pull request | Delegate PR preparation or publication separately  |
| status           | Answer from current postman and task artifact data |

For ambiguous requests, delegate the ambiguity-reduction work to a worker with a
compact ask and require the answer to cite the artifact or evidence used.

## Delegation Shape

Normal implementation delegation should include:

- the user-visible objective,
- the issue, PR, or artifact reference,
- required constraints such as no push or no PR,
- the exact worktree rule when issue work is involved,
- the original checklist and completion gate,
- the required reply footer or input request id.

Use worker DONE as an internal artifact-ready signal. Orchestrator still owns
review routing and final messenger-facing completion.

## Plan Lane

For plan-first work:

1. Ask worker to establish or preserve one `mkmd` artifact.
2. Require the plan to include source, context, acceptance criteria,
   implementation milestones, verification commands, progress, and surprises.
3. Route the plan through guardian, critic, guardian, and boss before reporting
   approval to messenger.
4. On `NOT APPROVED:`, return only the defect-specific rework request while the
   approval attempt cap allows it.

## Artifact Lane

For implementation work:

1. Ensure the worker used the required worktree wrapper for issue work.
2. Require path, branch, upstream, and clean/dirty verification before edits.
3. Require focused checks and a clean committed local branch before DONE.
4. Send worker DONE to guardian for review, guardian to critic, critic back to
   guardian, guardian to orchestrator, then boss.
5. Send messenger-facing DONE only after all review and boss approvals pass.

## Rework Lane

When review returns defects:

- Keep the same task artifact.
- Preserve the issue/worktree branch unless the defect explicitly requires a
  different branch.
- Send a compact defect list and expected verification evidence back to worker.
- Count the attempt against the approval cap recorded in
  `config/tmux-a2a-postman/postman.md`.

## Publication Lane

Pushes, PR creation, GitHub comments, releases, and tags are separate public
surface operations. Delegate preparation and local verification separately from
publication, and require explicit human approval when the live contract says a
public write is gated.
