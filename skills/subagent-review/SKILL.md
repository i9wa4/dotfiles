---
name: subagent-review
license: MIT
metadata:
  version: "1.0.0"
description: "USE FOR: Guardian/critic native multi-perspective review workflow, peer critic evidence, material-finding convergence, and blocking-finding synthesis. DO NOT USE FOR: implementation, dispatcher fan-out, overrides, or public posting."
---

# Subagent Review

## 1. Ledger and authority

Guardian freezes target, scope, criteria, baseline, mode, and boundary. The
task owner declares mitigation mode before this freeze.
Guardian owns never-reused IDs (`F-001`), applies the
[materiality and risk rules](references/review-topology.md), and decides
convergence. Packets supply evidence; nits do not gate rework. Record gaps.

## 2. Review loop

1. Run cheapest verification. Guardian MUST request critic for substantive
   review; deduplicate its set and self-review. Reviewers cannot edit, commit,
   push, approve, or decide materiality. Follow the
   [packet contract](references/review-topology.md).
2. Give each prior ID exactly one round disposition: recurrence, regression,
   closure, supersession, accepted risk, unchanged, or changed criterion.
   Record new discoveries separately. Record changed/tightened criteria as
   old/new/reason/owner; never portray them as previously frozen.
3. Review the full change; freeze material IDs, observable closure outcomes,
   and named verification in one batch. Separate design suggestions. Attribute
   reviewer prescriptions and `prescription-induced` regressions; reassess the
   prescription and gate regressions by materiality. Re-review that batch.
4. Repeat fix, verification, and diff review through confirmation.
   Count `initial`, `rework 1 of 2`, `rework 2 of 2`; invalid packets consume no
   slot. At cap or unavailable proof, report `BLOCKED` with IDs and gaps. Only
   the human user through the interface node may extend the rework cap. This
   cap is separate from the Tier 1 attempt cap.

## 3. Round report

Use the [contract's report](references/review-topology.md): counter, frozen
criteria/baseline/mode, criterion changes, accepted-risk authority and owners,
reviewer-reachable proof, base-versus-head latency/liveness check, ledger,
verdict, and next action.
