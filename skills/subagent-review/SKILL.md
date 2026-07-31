---
name: subagent-review
license: MIT
metadata:
  version: "1.0.0"
description: "USE FOR: Guardian/critic native multi-perspective review workflow, peer critic evidence, material-finding convergence, and blocking-finding synthesis. DO NOT USE FOR: implementation, dispatcher fan-out, overrides, or public posting."
---

# Subagent Review

## 1. Ledger

1. Before review, guardian freezes target, criteria, scope, and the
   design/public boundary. Broadening is recorded, never inferred.
2. Guardian owns a never-reused ledger (`F-001`); use the
   [contract](references/review-topology.md) for required fields and reports.
3. Guardian alone decides materiality and convergence; packets supply
   observations, evidence, and risk signals. Nits never gate rework. Invalid
   packets, missing evidence, authority gaps, cap exhaustion, and criterion
   changes are guardian-recorded states.

## 2. Review to Convergence

1. Run cheapest verification. Guardian defines the required perspective set;
   critic is guardian-specified and never self-selects. Waves are parallel.
2. Deduplicate. Guardian MUST request critic for substantive review; critic
   returns its set plus self-review; guardian aggregates both sets. Reviewers
   never edit, commit, push, approve, or decide materiality. See the packet
   schema and blind-projection contract in
   [contract](references/review-topology.md).
3. Each round reconciles every prior ID: recurrence, regression, new discovery,
   closure, supersession, accepted risk, or unchanged; record changed criteria.
4. Review the full change, then deduplicate material findings and freeze IDs,
   closure conditions, and reproducible verification in one executor batch.
   After rework, verify and review only that set unless scope/criteria changed.
5. Repeat batched fix → verification → diff-review until closure, then final
   confirmation. Cap: initial plus two failed reworks. At cap/unavailable
   evidence, `BLOCKED` includes IDs, gap, authority needed, and next owner.
   Quarantine invalid packets before a round; they consume no rework slot.

## 3. Round Report

Each round follows the [contract](references/review-topology.md): frozen
scope/criteria/targets, ledger, evidence, batch, verdict, and next action.
