# Orchestration Migration and Verification

## 1. Rule Ownership Map

Baseline: the post-#490 role contract, with #498 coordination reads, #496 review
semantics and #494 canonical selection applied. The old dotfiles
`orchestrator-runbook.md` is already absent at this baseline; do not resurrect a
second copy. This Skill's `runbook.md` is the sole generic procedure.

| Existing requirement                                                              | Disposition and authoritative owner                                                                                                                |
| --------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Role identity, contacts, topology, read/write authority and no bypass             | Retain short common/recipient role contracts.                                                                                                      |
| Original goals, constraints, owners, no overlap, truthful outcomes                | Retain manager responsibility; runbook sections 2–5 supply procedure.                                                                              |
| Coordination reading versus source investigation/tests/all writes                 | Retain role boundary from #498; runbook section 2 applies it.                                                                                      |
| Supplied/discovered/new paths, active index protection and authorized replacement | Replace role algorithm with required Logbook invocation; its selection procedure remains sole owner.                                               |
| Compact index fields, detail purpose/path/task and reciprocal parent links        | Move procedure from role section 6.4 to runbook section 4; no layout or private-record change.                                                     |
| Update index/details together, verify links, evidence and old-to-new coverage     | Move to runbook section 4, retaining delegated one-writer and exact replacement authorization.                                                     |
| Start/resume, delegation/reply/review/scope-change and completion reconciliation  | Retain mandatory role triggers; runbook sections 2–5 own steps. No-change inspection is not a write.                                               |
| Recursive finite-depth scopes, exact return routes and independent correlations   | Retain role duties; runbook sections 3, 4 and 6 own mechanics.                                                                                     |
| Review procedure, perspectives, materiality, caps and prose/JSON admission        | Replace copied recipes with mandatory #496 review contract; local route and completion gates remain visible.                                       |
| Mail/approval CLI schemas and recovery                                            | Required matching upstream Postman guidance; no local protocol copy.                                                                               |
| Escalation and original-goal decisions                                            | Retain manager authority/gates; runbook section 6 supplies decision packet procedure.                                                              |
| Explicit team-management inquiry                                                  | Retain one-shot upstream team-manager trigger; no background monitoring.                                                                           |
| Worker versus worker-alt instructions                                             | Retain standalone recipient contracts: their shared duties must not be put in common text that could grant execution to reviewers/transport roles. |
| Default startup and full per-message policy                                       | Retain no initial injection, complete archived common/recipient policy and read-through-EOF guidance.                                              |
| Dotfiles environment maintenance                                                  | Remains with Dotfiles; routine coordination routes to Orchestration.                                                                               |

## 2. Reviewed Procedure Scenarios

These are authored acceptance examples, not model-behavior evidence.

| Event                                                   | Expected procedure and retained gate                                                                                       |
| ------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Start/resume with an active index                       | Required Skill/Logbook loading, verify same scope/path and reconcile relevant links; no new dated index or startup PING.   |
| Unknown index or unreadable required reference          | Bounded delegated discovery or specific BLOCKED; no task-cwd fallback or silent skip.                                      |
| Delegate to a busy primary and free secondary           | Verify current state; assign explicit non-overlapping ownership/criteria and retain one artifact writer.                   |
| Reply reports changed detail evidence                   | Reconcile original criteria, delegate affected detail/index updates together and verify reciprocal links/read-back.        |
| No reportable state change                              | Inspect relevant records; no fabricated update, message or worker write.                                                   |
| Guardian returns a malformed report after work rework 1 | Return report structure to Guardian under its own counter; do not order worker reimplementation or spend rework 2.         |
| New supplied B conflicts with active index A            | Apply Logbook; preserve A and require exact authorization/verified migration for replacement.                              |
| Nested child delegates to its child                     | Preserve each immediate interface, original criteria and exact correlations at every hop; no fixed three-level assumption. |
| Parent receives ACK or intermediate answer              | Retain unfinished task criteria and final route; no user-facing DONE from transport closure.                               |
| Completion or out-of-authority decision                 | Verify original outcomes, review/evidence and local human gates; otherwise report concrete owner/decision/blocker.         |

## 3. Evidence Boundaries

Record the tested revision and checks in the PR. Metadata/trigger/link checks,
actual parser/terminal fixtures, installed-bundle reads, substantive instruction
review and separately authorized real-agent trials provide different evidence.
No paid account, live fleet activation, artifact migration or automatic prompt
injection is part of this change. A shorter role is not proof of better
behavior.

Compare common-plus-recipient bytes and representative total required reading
before/after this extraction. Include this Skill and applicable owner references
in the latter; do not hide newly deferred reading cost behind a role-only
saving.

### 3.1. Measured Policy and Cold Reading Cost

Compared the #494 baseline with this extraction using the actual selected
Postman revision `a0d7290`'s topology/recipient-policy parser. Values are UTF-8
bytes of common + recipient instructions + generated catalog; fixed archive
headings, contacts, guidance and user message bodies are excluded. The private
catalog roots have equal pathname lengths. The catalog adds one discoverable
Skill; it does not inline the runbook.

| Recipient    | Before | After | Difference |
| ------------ | -----: | ----: | ---------: |
| orchestrator | 23152  | 16989 | -6163      |
| worker       | 12689  | 13063 | +374       |
| worker-alt   | 13015  | 13389 | +374       |
| guardian     | 13004  | 13378 | +374       |
| critic       | 13197  | 13571 | +374       |
| messenger    | 13868  | 14242 | +374       |
| approver     | 17416  | 17790 | +374       |

For representative first-use manager turns, add all applicable owner bodies and
required references once. Start/resume includes Logbook entry/selection
guidance; structured review/completion additionally includes the review
entry/contract and optional JSON shape. After extraction both also include
Orchestration entry and runbook. Task artifacts are excluded equally; byte
counts are not model tokens.

| Cold reading case            | Before | After | Difference |
| ---------------------------- | -----: | ----: | ---------: |
| Start/resume                 | 41060  | 46562 | +5502      |
| Structured review/completion | 72398  | 77900 | +5502      |

The manager's repeated message policy shrinks; other recipients pay the added
catalog entry. Cold first-use reading grows because the reusable procedure is
explicit, complete and independently discoverable. This trades initial reading
for smaller repeated manager policy and one procedure owner, not a claim of
universal token savings, better model compliance or an arbitrary size target.
Reused, already-read current procedures need no invented repeated load, while
changed or missing guidance still requires reconciliation.
