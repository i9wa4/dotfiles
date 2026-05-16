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
