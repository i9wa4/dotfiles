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

This is the extraction snapshot at #495 revision `6064da22`; later procedure
additions are not included in these historical measurements.

Compared the #494 baseline with this extraction using the actual selected
Postman revision `a0d7290`'s topology/recipient-policy parser. Values are UTF-8
bytes of common + recipient instructions + generated catalog; fixed archive
headings, contacts, guidance and user message bodies are excluded. The private
catalog roots have equal pathname lengths. The catalog adds one discoverable
Skill; it does not inline the runbook.

| Recipient    | Before | After | Difference |
| ------------ | -----: | ----: | ---------: |
| orchestrator | 23152  | 16999 | -6153      |
| worker       | 12689  | 13073 | +384       |
| worker-alt   | 13015  | 13399 | +384       |
| guardian     | 13004  | 13388 | +384       |
| critic       | 13197  | 13581 | +384       |
| messenger    | 13868  | 14252 | +384       |
| approver     | 17416  | 17800 | +384       |

For representative first-use manager turns, add all applicable owner bodies and
required references once. Start/resume includes Logbook entry/selection
guidance; structured review/completion additionally includes the review
entry/contract and optional JSON shape. After extraction both also include
Orchestration entry and runbook. Task artifacts are excluded equally; byte
counts are not model tokens.

| Cold reading case            | Before | After | Difference |
| ---------------------------- | -----: | ----: | ---------: |
| Start/resume                 | 41060  | 47306 | +6246      |
| Structured review/completion | 72398  | 78644 | +6246      |

The manager's repeated message policy shrinks; other recipients pay the added
catalog entry. Cold first-use reading grows because the reusable procedure is
explicit, complete and independently discoverable. This trades initial reading
for smaller repeated manager policy and one procedure owner, not a claim of
universal token savings, better model compliance or an arbitrary size target.
Reused, already-read current procedures need no invented repeated load, while
changed or missing guidance still requires reconciliation.

## 4. Event-Driven Reporting Verification

### 4.1. Covered, Missing and Conflicting Guidance

The inherited post-#490 common contract already allows quiet turns, requires
exact replies/new requests/material results/blockers and rejects quota traffic.
Its complete-archive reading and fixed approval helpers also remain in force.
No second quota-removal change is needed. The operating-contract status section
correctly says informational node mail still requires an exact reply; the old
`Reply:` footer is mentioned only as historical guidance not to reuse.

The residual gap was the relationship between an intermediate exchange, the
original task's mail obligation and unfinished acceptance criteria. Runbook
section 6.1 now gives that relationship one owner, including parallel requests,
helper-only decisions and uncertain-send recovery. It adds no local no-reply
flag, CLI schema, automatic resend or notification success heuristic.

| Required scenario                          | Existing duty / residual clarification                                                                                         | Deterministic native trace                                                                                                                                                                                                                                       |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Delegated work finishes                    | Exact evidence-backed response and local review gates precede user-facing DONE.                                                | One request plus one exact result: 2 archives, no ACK-of-ACK. Review quality remains a separate gate.                                                                                                                                                            |
| Cannot continue / authority blocker        | Report specific impact, owner and needed decision promptly.                                                                    | One request plus exact BLOCKED response: 2; no command effect.                                                                                                                                                                                                   |
| Material change affects another actor      | Send a meaningful delta, retaining original goals and task state.                                                              | Independent change/answer exchange plus original request/final result: 4.                                                                                                                                                                                        |
| Successful approve/decline helper          | Helper resolves the exact typed request; no quota-only approver message. The worker still owes its genuine parent-task result. | Each case has task request, execution request, one helper decision and task result: 4. Approval makes one harmless effect; decline makes none.                                                                                                                   |
| Failed or unknown send/decision            | Preserve IDs/evidence; no delivery claim or blind replay.                                                                      | Invalid route creates 0 archives. Absorbed Enter produces unknown notification but one durable request; recovering the original hint yields one exact reply, 2 total and 0 mail resends. Existing pinned decision-failure tests cover the typed lane separately. |
| Exact answer with no further work/question | Reconcile without another response obligation.                                                                                 | Final answers are consumed without ACK-of-ACK; the 2-archive completion case terminates.                                                                                                                                                                         |
| Duplicate notification / empty POP         | No empty announcement or polling.                                                                                              | Duplicate hint causes an empty POP and 0 additional archives.                                                                                                                                                                                                    |
| Unchanged wait                             | Passive unless an explicit management/workflow event calls for investigation.                                                  | Bounded quiet observation makes 0 additional archives. This does not prove model patience over arbitrary durations.                                                                                                                                              |
| Several parallel requests                  | Close only the exact answered obligations; keep intermediate questions separate.                                               | Two held tasks: finishing A leaves B outbound. Finishing B closes it. Four explicit requests (two tasks and two finish instructions) plus four exact replies: 8. Intermediate-question case preserves original inbound until its final answer, 4.                |

### 4.2. Tested Transport and Evidence Limits

The native trial uses the selected `git-a0d7290` binary, Linux tmux 3.8, the
complete candidate role policy and all 19 selected Skill metadata entries.
No startup message is injected. Deterministic terminal editors respond only
after notification input is submitted; recipients perform real POP/read/tool
actions. The controller initiates requests and observes evidence, not recipient
POPs. Use the upstream editor with fixture-callback support and archive reader;
the older selected editor lacks that callback extension, so it is not silently
treated as the newer harness. Binary/protocol assertions match the selected pin.

The completed trace has 11 bounded cases, 30 archived messages and 28 receiver
POP/full-file SHA-256 proofs. The other two messages are typed decisions
consumed by the execution CLI. Every recorded full-read hash matches its
retained archive. All three participating roles finish with
unread/inbound/outbound/draft/failed counts zero and exactly one harmless
command effect. Notification acceptance, durable mail, exact reply closure and
task result are recorded separately.

Existing selected-pin tests already executed for #499 additionally verify
waiting failures never downgrade, unknown initial identity never runs,
unknown results identify their audit, late decisions cannot authorize fresh
invocations, and cancellation/changing reviewers do not grant execution. Those
unit/process results are distinct from this notification-driven terminal trace.

Fixed actors are scripted choices: they prove actual terminal/mail behavior,
correlations and counts, not model understanding, spontaneous reporting,
substantive Guardian review, human receipt or installed fleet activation.
Authorized real-agent behavior and installed rollout remain separate evidence;
do not mark those passed from these fixtures. Metadata/link/trigger/Nix results
and the exact tested revision belong in the PR. Private raw transcripts and
synthetic mailbox records remain local; public summaries contain no real paths.

### 4.3. Reproduction Outline for an AI Developer

1. Use the existing cloud-development procedure and an isolated private tmux
   socket/HOME/state tree. Build or select the intended Postman revision and
   matching protocol evidence reader; retain the full candidate role policy
   and catalog instead of replacing it with two bare node names.
2. Start the terminal editors for manager, worker and command approver without
   initial prompt injection. Supply temporary deterministic callbacks for the
   cases above, using upstream fixture helpers rather than a new installed
   Dotfiles test engine. Record full-file hashes before handling each POP.
3. Exercise the exact request/question/change/decision/parallel flows in the
   table. Compare archived-message deltas and original obligation state, not
   only a lower send count. The declared scripted outcomes are not AI verdicts.
4. For unknown notification, absorb Enter in the worker editor, verify one
   durable original request, restore the editor and recover that same hint/ID.
   Do not send the mail again or replay a command. Duplicate and quiet cases
   must leave archive counts unchanged.
5. Check final counts, independent correlations, archive hashes and the single
   harmless approval effect. Retain raw evidence and label source/static,
   scripted-native, real-model and installed observations separately.
6. Stop only the owned server after verifying its process/start identity;
   leave live sessions/configuration and user mail untouched.
