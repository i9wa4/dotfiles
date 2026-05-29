# Task Artifact Method

Durable task tracking is needed when work must survive chat compaction, node
handoff, review loops, or original-checklist completion gates. The artifact is
an operational record, not a replacement for source changes or tests.

Use `mkmd` as the local implementation for these artifacts.

## Choosing A Directory Label

Use the `--dir` value as an `mkmd` directory label. It is not a repo-local
directory to create by hand.

| Label      | Use when                                                 |
| ---------- | -------------------------------------------------------- |
| `plans`    | The artifact is an execution plan or milestone tracker.  |
| `research` | The work is investigation, synthesis, or decision notes. |
| `reviews`  | The artifact records review findings or approvals.       |
| `draft`    | The artifact is temporary text for a handoff or message. |
| `tmp`      | The artifact is scratch output with low retention value. |

Prefer the narrowest label that matches the work. For implementation tasks that
already have a supplied markdown path, preserve that path instead of creating a
new one.

## Creating A Tracker

Create a new artifact before deep work only when no canonical markdown path was
provided.

```sh
mkmd --dir plans --label implement-feature-x
```

```sh
mkmd --dir research --label investigate-feature-x
```

Use the absolute path returned by `mkmd`. It should live under
`$MKMD_BASE_DIR`. Do not create repo-local `plans/` or `research/` task
artifacts unless the user explicitly provided that repo path as the original
checklist.

## Preserving The Original Checklist

When a user, orchestrator, or reviewer supplies a markdown path, treat that file
as the canonical original checklist:

- keep updating that file rather than creating a competing tracker;
- preserve every original checklist item, even if you add clarifying subitems;
- record any scope correction or changed interpretation under decisions;
- use the same artifact path in worker, review, handoff, DONE, and BLOCKED
  traffic.

If the task has no explicit checklist, create one from the assigned success
checks before implementation begins.

## Recommended Artifact Shape

Use headings like these. Keep the artifact compact, but make the evidence
sufficient for resume and review.

```markdown
# <Task Title>

## Task

One paragraph describing the requested outcome.

## Original Checklist

- [ ] Required item from user or orchestrator.

## Plan And Progress

- [ ] Milestone or active work item.

## Evidence Log

- YYYY-MM-DD HH:MM TZ: Read files or skills.
- YYYY-MM-DD HH:MM TZ: Ran command and result.

## Decisions

- Decision and reason.

## Surprises And Discoveries

- Unexpected finding and impact.

## Verification

- Command/result or inspection evidence.

## Blockers

- None, or exact blocker.

## Completion Verdict

- Original checklist: PASS/BLOCKED.
```

## Progress And Evidence Logs

Log the facts another node needs to resume:

- timestamped skill reads and file inspections;
- paths created or preserved;
- edits made and why they satisfy the checklist;
- command names, exit results, and important failures;
- review defects addressed or intentionally left blocked;
- remaining next action when handing off.

Use checkboxes for milestones and verification items. Do not mark a checkbox
complete until there is evidence in the artifact or source tree.

## Handoff And Resume

For handoff or compaction, add:

- active artifact path;
- current branch and dirty/clean status if source files changed;
- last completed action;
- next action;
- blockers or external waits;
- validation still required.

For resumed work, read the artifact before acting. Continue the same evidence
log rather than reconstructing history from memory.

## DONE And BLOCKED Verification

DONE requires:

- every original checklist item passing with evidence;
- the report includes `Task artifact: <path>`;
- the report includes `Original checklist: PASS`;
- remaining blockers are `none`.

BLOCKED requires:

- the failing checklist item or exact command, permission, tool, policy, or
  missing-input blocker;
- the artifact path;
- evidence of the last useful action;
- the next action that would unblock progress.

Do not report DONE because code was edited. Report DONE only when the artifact
proves the original checklist passed.

## Public Surface Hygiene

Local absolute artifact paths are fine in internal chat, mailbox traffic, and
local task artifacts. Public GitHub surfaces such as commits, issues, PRs, and
reviews should use repo-relative paths or stable URLs.

## Common Mistakes

- Creating a repo-local `plans/` or `research/` file instead of using `mkmd`.
- Creating multiple trackers after a markdown path was already supplied.
- Treating a generated plan as the original checklist and dropping user items.
- Marking DONE without evidence for every original checklist item.
- Putting local absolute paths on public GitHub surfaces.
- Copying the full tracker method into live postman routing text.
