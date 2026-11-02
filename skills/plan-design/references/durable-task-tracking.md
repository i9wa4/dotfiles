# Durable Task Evidence

Use durable evidence when planning/checklist work must survive compaction,
handoff, independent review or completion gates. This reference owns planning
and evidence quality, not artifact creation, selection or storage.

## 1. Required Artifact Owner

Before using a supplied, discovered or new path, load the installed `logbook`
Skill and its required `references/local-markdown.md` from the catalog root,
independently of task cwd. It alone owns canonical selection, creation,
structure, reuse, retention and delivery mechanics. Missing required guidance
blocks the affected action; do not substitute an ad hoc tracker or copy its
Markdown template here. Coordination and index/detail procedures belong to
`orchestration`; review admission and counters belong to `subagent-review`.

Use the selected canonical path consistently in worker, review, handoff, DONE
and BLOCKED traffic. A supplied ordinary plan keeps its intended role under
Logbook's rules; do not turn it into a second competing orchestration index.

## 2. Preserve the Original Checklist

- Preserve every original requested outcome, constraint and checklist item.
  Clarifying subitems do not replace or silently weaken the original criteria.
- Record scope corrections, changed interpretations and their authorization in
  decisions. Never present a newly tightened condition as previously frozen.
- If no checklist was supplied, derive one from assigned success criteria before
  implementation. Plan-specific sections belong to `plan-authoring.md`.
- Keep one selected task artifact through rework. A generated implementation
  plan does not replace the original request or its acceptance checklist.

## 3. Evidence Quality

Record the facts another actor needs to assess or resume the work:

- Relevant skill/file reads, selected source revisions and artifact provenance.
- Changes and why they satisfy the original criteria; decisions and rationale.
- Actual verifier/command, result, important failures and independently
  reachable evidence. Worker claims, local tests, external read-back and
  installed behavior are different evidence, not interchangeable assertions.
- Review defects addressed, authorized dispositions, unresolved gaps, next
  accountable action and required validation.

Use milestone/verification checkboxes, but close an item only with evidence.
Retain dated results and distinguish historical observations from current
verified state. A summary cannot hide missing detail evidence.

## 4. Handoff and Resume

Apply Logbook's required resume record and keep the selected path in the
handoff. Read that artifact before continuing, preserve its evidence log and
original criteria, and reconcile current revision/state rather than rebuilding
history from memory. Pending review/approval and unresolved blockers remain
visible; an ACK or closed mail obligation is not completion.

## 5. DONE and BLOCKED

Local role/review/human gates remain authoritative. A tracked task's DONE needs
all original criteria passing with evidence, `Task artifact: <path>`,
`Original checklist: PASS` and no remaining blockers. Edited files alone do not
prove completion.

BLOCKED names the failing item or exact command/permission/tool/policy/input
blocker, artifact, last useful evidence and the next decision/action needed.
Do not disguise an unavailable verifier as a passed checklist item.

## 6. Publication and Delivery Boundary

Use private local paths for internal task records and source-relative paths or
stable URLs on public surfaces. Follow Logbook's delivery procedure and current
human/publication gates for a readable copy; it never replaces local canonical
state. Do not treat a Secret Gist as task memory, publish without authorization
or claim a delivery URL before its verification. Reuse owner procedures instead
of copying this method into live Postman routing text.
