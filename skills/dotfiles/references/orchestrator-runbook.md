# Orchestrator Runbook

The live role contract is config/tmux-a2a-postman/postman.md. Dotfiles owns
orchestration; Postman owns verified mail and exact correlation. The same
common/role template applies at every configured finite depth.

## 1. Start and identity

Team presets launch clients directly without an injected role message.
Read the complete POP archive for common_template and recipient-role policy.
Runtime models/effort/permissions remain the explicit vde-layout settings.
Use the verified native workspace and declared interface relation. Repeated
role names in other workspaces do not identify a local peer. No daemon, startup
PING, diplomat node or global scan is needed.

Normal routes are messenger <-> orchestrator <-> workers/guardian/approver,
and guardian <-> critic. Worker and worker-alt also have explicit approver
return edges required by the pinned fixed decision helper. The optional agent
is outside the normal reviewed worker lane. Do not open unrelated routes.

## 2. One index per owned scope

Use Logbook's discovery and mkmd convention. Preserve one verified canonical
orchestration index per repository/full branch/worktree, across dates and
restarts. Keep original human goals, constraints, acceptance criteria and
scope before delegation. The index links meaningful tasks and detail files,
with owner, dependency, state, last verified evidence, next action, blockers,
review status, pending decisions and parent/child references. No task database
or shared global mutable index belongs in Postman.

Each child team's orchestrator owns its delegated scope and its own local index.
The parent records the child request/return references and resulting evidence;
it keeps the original acceptance criteria instead of replacing them with a
child's easier checklist. Detailed plans/reviews/results link back to their
parent index. Follow Logbook's canonical-path and replacement rules rather than
silently selecting a different tracker on resume.

## 3. Delegate and return

Choose the local worker for implementation. Use worker-alt for independent,
non-overlapping work or a bounded read-only secondary lane; keep one owner for
an artifact and never let two workers commit overlapping edits.

A declared immediate child can own a meaningful subtask. Ask the local messenger
to relay it to child-session:messenger. That interface forwards to its local
orchestrator, which can delegate again using this same contract. A child
messenger serves its immediate parent, while only the top-level messenger talks
to the human or a supported external channel. Missing/unknown parent evidence
does not make a child top-level.

Every handoff preserves original goal, constraints, acceptance criteria, exact
request and return references, scope, owner and expected evidence. Return deep
questions and decisions through the same immediate-parent chain. Forwarded
agent text does not acquire human authorization. Reject sibling/grandchild
shortcuts, guessed directory relations and ambiguous reused role names.

Use node-addressed mail for a new question/request and ID-addressed replies for
actual results. Read the complete POP'd archive and respond to that actual ID,
not merely the notification hint. Exact replies create no new reply obligation;
an intermediate question does not close the original task. Send only material
work/results/questions/blockers, not one message per turn or endless ACK loops.

## 4. Review and completion

worker readiness -> orchestrator -> guardian -> critic -> guardian ->
orchestrator -> messenger is the normal reviewed completion route.

Guardian aggregates critic evidence. Substantive reviews keep the required
security/architecture/historian/code/QA perspectives, unless the live contract
explicitly authorizes a trivial/degraded path. Preserve the bounded
three-attempt review loop and defect-specific rework. The orchestrator's Tier 1
structural gate is a local checklist, not another recursively launched review
loop.

DONE needs a real Task artifact, Original checklist: PASS, changed-file and
verification evidence, and Remaining blockers: none. Check child evidence
against the original goal before completing the parent. Delivery, POP, an ACK,
transport reply closure or an unverified worker claim is not task acceptance.
Missing child, failed review, stale revision, invalid scope or missing evidence
stays BLOCKED and returns a concrete defect through the parent chain. Do not
require the human to visit lower panes to hide a broken handoff.

## 5. Execution and diagnostics

Workers send exact quoted-heredoc source through execute-heredoc --reason when
Postman review is needed. The approver reads its own claimed typed request and
chooses approve-execution or decline-execution with ID/reason. The requester
executes after an exact decision; reviewer roles do not execute it locally.
Unknown identity or a failed waiting invocation never grants permission.
Review coordination does not replace runtime sandboxing or human authorization.

Use returned self counts for known mail. A positive unread_count permits the
next finite POP/read batch; empty or unknown stops it. get-status is saved-file
inspection, with null unknowns and dated capture evidence, not inferred live
work. No empty-POP/status polling. failed_count is confirmed delivery failure,
not task BLOCKED. Retained own read/sent evidence and the same verified index
support restart reconciliation; late responses cannot complete a fresh request
or replay a possibly started command.

## 6. Validation and rollout

For a multi-session team, declare the complete finite tree once. Session names
must be unique on the selected tmux server; every non-root names its immediate
parent. For example, save this JSON to an absolute local path:

```json
{"sessions":[{"name":"root"},{"name":"child","parent":"root"},{"name":"leaf","parent":"child"}]}
```

Run `postman-team-config --tree /absolute/tree.json --output /absolute/team.md`.
It copies the installed role template, adds the verified interface tree, and
refuses existing output, cycles, disconnected roots and missing parents.
Use that same generated file in every team session: set
`POSTMAN_TEAM_CONFIG=/absolute/team.md` before starting the normal team preset.
The launcher supplies the selected role and explicit Postman config path to
the existing client; model, effort and native permission flags stay in the
preset. Start each declared session with its declared name on the same server.
The compiler does not launch or activate sessions, infer a tree from folders,
or connect independently configured tmux servers. For a single session the
installed template works directly, without a generated tree.

nix run .#postman-team-check runs deterministic private real-tmux trees and
direct-start/route failures using the pinned CLI. Tests retain per-hop archives,
scope records and diagnostics, and check false completion and correlation. They
exercise authored workflows, not real-model understanding or review quality.
The default scenarios cover a root, a four-level chain with restart/late reply,
an unbalanced six-level tree with simultaneous tasks, a declined execution and
a missing child. `--depth` changes the branching fixture's depth (4–12 to bound
test cost); the configuration compiler has no fixed production depth. The same
suite and compiler boundary checks run in `nix flake check`.

After merge, the human activates the landed pin/config/skills and verifies the
live fleet. Source/Nix fixtures do not perform or prove that switch. Postman

## 7. owns external inbox/outbox/read; integrate only at the top-level interface

when its installed version supports it. #954 recall and #830 trigger checks
remain separate upstream features.
