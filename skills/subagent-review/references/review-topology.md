# Review Contract

## 1. Perspective Set and Routing

Reviewer prompt mapping:

| Perspective  | Prompt reference                                     |
| ------------ | ---------------------------------------------------- |
| Architecture | [reviewer-architecture.md](reviewer-architecture.md) |
| Code         | [reviewer-code.md](reviewer-code.md)                 |
| Data         | [reviewer-data.md](reviewer-data.md)                 |
| Historian    | [reviewer-historian.md](reviewer-historian.md)       |
| QA           | [reviewer-qa.md](reviewer-qa.md)                     |
| Security     | [reviewer-security.md](reviewer-security.md)         |

- Guardian defines the required perspective set. If omitted, it defaults to
  security, architecture, historian, code, and QA; do not substitute fixed
  five/six/twelve counts after narrowing.
- Self-review accompanies every wave and never replaces it. Guardian-labeled
  trivials may omit subagents; otherwise no direct-only fallback.
- Every ordinary CODE, SECURITY, QA, HISTORIAN, or ARCHITECTURE reviewer launch
  receives bounded read-only paths, bounded context, and a required output
  shape. The specialized data reviewer remains bounded and read-only.
- A Postman request authorizes critic launch; otherwise return
  `BLOCKED: perspective launch not permitted`. Critic sends guardian, not
  orchestrator. Critic reports `Required perspectives`, `Perspectives
  launched`, and `Self-review: complete`; incomplete coverage is
  `BLOCKED: fewer than required perspectives completed`.
- Use the data reviewer only for specialized questions.

## 2. Blind Projection and Reviewer Packet

- Guardian creates a blind packet with a fresh `packet_alias`, frozen
  scope/criteria, and projected files named only by projection-relative aliases
  such as `files/001`. Real repository paths, filenames, diff headers, branch,
  commit, author, issue/PR, transport/session, timestamp, correlation, and
  lineage fields are identity-bearing and rejected if present.
- Guardian alone retains the minimal control envelope: `packet_alias`,
  `candidate_id`, the alias-to-repository-path map, frozen scope/criteria,
  lineage, and routing metadata. It is never sent to reviewers. Guardian uses
  the map when recording repository coordinates in the authoritative ledger.
- Historian receives only a bounded blind evidence digest: aliases, neutral
  decision excerpts, and permitted projected history facts. It excludes real
  paths, filenames, issue/PR identifiers, URLs, commits, authors, branches,
  timestamps, and candidate identity; its output uses aliases for Guardian to
  bind through the control envelope.
- Every ordinary reviewer packet contains `perspective`, `verdict`, findings,
  projection-relative path plus line evidence (or `no file applicable`),
  severity, confidence, and recommendation/required correction. A projected
  path is repo-relative within the blind projection, never a real repository
  path. Packets contain no authoritative ledger IDs.

## 3. Ledger, Batch, and Report

- Every stable entry has severity, materiality, `OPEN`/`CLOSED`, closure
  disposition (`fixed`, `accepted`, `deferred`, or `rejected`), rationale, exact
  path/evidence coordinates, closure condition/evidence, and accepted-risk
  authority/owner. `superseded` is a reconciliation relation naming
  successor/reason.
- Track the evidence owner separately from the reviewer. Reviewer packets
  contain observations, evidence, and risk signals only; Guardian alone
  decides materiality, closure, rework, escalation, and convergence. A
  reviewer cannot satisfy an authority gap, accept risk, publish, or mark
  unavailable external evidence as closed without the named owner.
- Keep candidate identity separate from review packets: strip source identity,
  history, transport/session metadata, and timestamps before blind review.
  Guardian keeps the identity-bearing control envelope and records the mapping
  in the ledger; reviewers do not infer or reconstruct it.
- Before the single material batch, review the complete change and ledger.
  Freeze material IDs, scope/criteria, and reproducible named cheap/full
  verification commands or targets. Change them only after an explicitly
  recorded scope or criterion change.
- Every round and final confirmation reports frozen scope, criteria, targets,
  complete ledger/reconciliation (recurrence, regression, new discovery, or
  changed criterion), material batch, verification evidence, verdict
  (`CONVERGED`, `REWORK`, or `ESCALATE`/`BLOCKED`), and explicit next action.
- For substantive verdicts, apply the `decision_quality_check` prompt block in
  `skills/dotfiles/references/prompt-blocks.md`. Only Guardian/critic synthesis
  may update or close the authoritative ledger; reviewer use is packet-local.

## 4. Failure-Mode Handling

- Invalid review packets enter `QUARANTINED`, a non-substantive pre-round
  rejection that consumes no failed-rework slot. Do not trust packet-supplied
  finding IDs or treat the packet as approval, a finding wave, or rework.
  Guardian records the packet alias, missing/rejected fields, and required
  resubmission: fresh alias, required packet fields, projected evidence, and
  the cheapest verifier needed to make it reviewable.
- Missing evidence keeps the affected ID `OPEN` unless the ledger records a
  named accepted-risk owner. Local fixtures, repository read-back, external
  read-back, publication receipts, and production evidence are distinct
  evidence tiers.
- Authority gaps are `BLOCKED` or `ESCALATE`: name the exact decision owner,
  the IDs affected, and the smallest manual decision required. Reviewers do not
  approve their own authority gaps.
- Rework must address one frozen material batch. New material discoveries are
  classified and added to the ledger, but do not silently broaden the current
  closure target.
- Cap exhaustion stops the loop with `BLOCKED`: include attempted rounds, open
  IDs, remaining evidence gaps, and the owner who can authorize another round
  or accept/defer risk.
- Criterion changes create a new ledger entry or explicit changed-criterion
  reconciliation. Preserve the old closure condition, new closure condition,
  reason, and owner; do not re-use a closed ID as if it were unchanged.
