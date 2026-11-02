# Local Markdown Artifacts

Use local markdown artifacts when work must survive chat compaction, handoff,
review loops, or terminal DONE/BLOCKED evidence. They are operational records,
not source changes or test substitutes.

Working records are AI/agent-facing memory kept locally, separate from
claude.ai's rendered Artifact/canvas feature. Human-facing Markdown can also
be prepared locally; use the readability guidance below. A readable document
does not require external publication.

This reference is the single deterministic location convention for where
working artifacts live in this environment: the path template in
[Creating Artifacts](#4-creating-artifacts) plus the directory labels in
[Directory Labels](#5-directory-labels) together form that index. Other
skills should not restate this convention, the `mkmd` invocation contract, or
the label table — they should point here generically (for example, "leave a
durable artifact of your work") and let this file stay the one place that
changes when the convention changes.

## 1. Canonical Path Selection

This section is the sole selection/replacement procedure. Read it before any
supplied, discovered or newly created path is adopted. Identify purpose and
owning scope first: repository identity, full unsanitized branch, relevant
worktree relationship and task. Directory labels are discovery hints, not
proof of that identity. Do not add another registry or storage convention.

### 1.1. Ordinary Artifacts

For plans, research and other non-orchestration purposes, preserve this order:

1. The path supplied by the requester or trusted task/handoff.
2. The already-active artifact for that task and purpose.
3. A discovered artifact verified to match repository, branch, task and purpose.
4. A new artifact through the installed Logbook mechanism when none matches.

A requester may intentionally name a new ordinary plan path; it does not need
the protected orchestration replacement approval below. Preserve that intent
within existing write authority, and do not manufacture evidence for missing
contents. A genuinely different purpose may have its own file. Never split one
original checklist into competing trackers or combine distinct-purpose records
merely because their names look similar.

### 1.2. Protected Orchestration Index

For an orchestration index, identify the verified active canonical path before
applying ordinary supplied-path precedence. An active index remains canonical
for its verified repository/full-branch/worktree scope across dates and
subordinate-task completion. A later supplied path is not a replacement.

- If active A is readable, reuse it. For supplied B, determine whether B is a
  different-purpose reference, a mistaken pointer or an explicitly authorized
  replacement. Keep A while resolving the conflict; do not silently migrate.
- If A is known but missing/unreadable or its identity conflicts, preserve the
  known pointer and report recovery/conflict. This is not proof of absence and
  does not authorize creating or adopting B to continue affected work.
- Replacement requires current explicit human authorization naming A and B.
  Delegate the authorized migration to the existing writer: preserve contents,
  checklist/evidence and references with an old-to-new coverage map, verify the
  resulting content and reciprocal links, then record B in task state and
  handoffs. A proposal or authorization alone is not evidence of migration.
- If no active canonical path is known, use discovery below. Adopt a candidate
  only after checking repository, full branch, purpose, relevant worktree,
  contents and creation provenance. Ambiguous same-purpose candidates require
  reconciliation before affected work or completion claims; mtime, filename
  ordering or a newly supplied pointer alone cannot choose a winner.
- If no valid candidate exists and no known-path recovery is outstanding,
  create one index once through the installed Logbook mechanism under existing
  update ownership. A new branch's first index is not a replacement.

Managers own the decision; existing delegated one-writer rules govern all
creation, migration and updates. Verify the returned path/content and relevant
links before reporting records current. Selection supplies artifact mechanics,
not authority to change objectives, delegate tasks or implement source work.

## 2. Work-Start And Resume Discovery

Search across dates before creating a new artifact, using the existing root:

```sh
mkmd_root="${MKMD_BASE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/mkmd}"
find "$mkmd_root" -type f -name '*.md' -print 2>/dev/null |
  sort -r
```

Sorting is only a candidate listing. Inspect trusted supplied/active references
first, then matching repo/branch sessions, related branch/worktree records and
matching task/issue labels. The repo key is remote owner/repository, or
`local/<repo-dir>` without origin. Branch directories render `/` as `-`, so
verify the full branch from trusted task state and contents; different full
branches can have the same rendered name. Verify Git top-level/worktree
relationship and purpose from the title, task, checklist, evidence and creation
provenance. A related worktree is not automatically the same owning scope.

Reject nonmatching candidates. A completed ordinary task may be stale for a
new task; subordinate completion does not retire its persistent orchestration
index. For ordinary same-purpose candidates, a trusted current canonical
reference wins; otherwise adopt a clearer/newer candidate only after inspecting
contents and provenance, and record the rejected pointer. Protected-index
ambiguity follows section 1.2 instead: preserve candidates and reconcile.
Keep distinct-purpose files and name their roles in handoffs. Do not merge
content ad hoc, choose solely by path/mtime or create another tracker simply
because recovery is inconvenient.

### 2.1. Reviewed Selection Scenarios

These are authored contract examples, not behavioral proof of an agent.

| Context                                                         | Selection and required action                                                                                                     |
| --------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Verified active orchestration A; later supplied same-purpose B  | Keep A; classify B and reconcile before affected work.                                                                            |
| Human explicitly authorizes A to B                              | Delegate migration with coverage/evidence map; B becomes canonical only after verification and recorded handoff.                  |
| Known A missing or unreadable; B happens to exist               | Recovery/conflict, not absence; neither adopt B nor create another index.                                                         |
| Midnight passes while the scope is unchanged                    | Reuse A across date directories.                                                                                                  |
| A child task completes and a new subordinate task starts        | Reuse A and reconcile its task entries; no fresh branch tracker.                                                                  |
| Candidate is from another full branch or unrelated worktree     | Reject scope mismatch; verify that scope's own record instead of sharing A.                                                       |
| Full branches render to the same directory label                | Compare full identities and provenance; the rendered name cannot establish sameness.                                              |
| Two same-purpose candidates remain equally plausible            | Reconcile before adoption or completion; newest mtime is insufficient.                                                            |
| No active pointer or valid candidate exists                     | One authorized writer creates one artifact via Logbook; manager verifies the returned path.                                       |
| Supplied ordinary research B while orchestration A is active    | B is a distinct-purpose artifact, not replacement of A.                                                                           |
| Requester supplies ordinary plan B while ordinary plan A exists | Preserve ordinary supplied-path intent and existing write authority; do not impose orchestration-only human replacement approval. |

## 3. Cwd-Independent Mkmd Contract

Callers must receive the installed or currently loaded logbook skill root
before invoking `mkmd`. Relative calls such as
`skills/logbook/scripts/mkmd`, and roots derived from the active target
repository, must not appear in reusable snippets because most repositories do
not vendor this skill tree.

Reusable callers:

```sh
: "${LOGBOOK_SKILL_ROOT:?set LOGBOOK_SKILL_ROOT}"
"${LOGBOOK_SKILL_ROOT}/scripts/mkmd" --dir plans --label implement-feature-x
```

`LOGBOOK_SKILL_ROOT` is a runtime-provided contract from the session, wrapper,
or explicit caller setup. It should point to the installed/current logbook
skill root, not to the repository being worked on.

Dotfiles source-local maintenance is the only documented case that may derive
the root from the repository checkout:

```sh
repo_root=$(git rev-parse --show-toplevel)
LOGBOOK_SKILL_ROOT="${repo_root}/skills/logbook"
```

Use the absolute path returned by the script. The path is the canonical artifact
identifier for future Postman traffic and handoffs.

## 4. Creating Artifacts

Run the skill-owned script directly:

```sh
: "${LOGBOOK_SKILL_ROOT:?set LOGBOOK_SKILL_ROOT}"
"${LOGBOOK_SKILL_ROOT}/scripts/mkmd" --dir plans --label implement-feature-x
```

The script creates:

```text
$MKMD_BASE_DIR/<owner>-<repo>/YYYY-MM-DD-<branch>/<dir>/<label>-<XXXXXX>.md
```

`MKMD_BASE_DIR` defaults to `${XDG_STATE_HOME:-$HOME/.local/state}/mkmd`.
The script works inside git repositories and local directories.

Use single-component `--dir` and `--label` values with letters, numbers,
dots, underscores, and hyphens. Do not use path separators or `..`.

## 5. Directory Labels

| Label           | Use when                                                     |
| --------------- | ------------------------------------------------------------ |
| `plans`         | The artifact is an execution plan or milestone tracker.      |
| `orchestration` | The artifact is canonical branch-scoped orchestration state. |
| `research`      | The work is investigation, synthesis, or decision notes.     |
| `reviews`       | The artifact records review findings or approvals.           |
| `draft`         | The artifact is temporary text for a handoff or message.     |
| `tmp`           | The artifact is scratch output with low retention value.     |

Prefer the narrowest label that fits. Use `tmp` only when the output can be
discarded without losing task state.

## 6. Scope And Retention

- Branch or worktree-specific artifacts should stay under the script-generated
  branch session directory.
- Repo-independent scratch belongs in `tmp`; discard it when it no longer
  carries evidence or handoff value.
- Do not create repo-local `plans/`, `research/`, or similar directories unless
  the requester supplied that repo path or the repository explicitly owns those
  artifacts.
- Local absolute paths are fine in private task artifacts and Postman traffic.
  Public GitHub surfaces should use repo-relative paths or stable URLs.

## 7. Save-Point Usage Pattern

One of several recommended usage patterns alongside plans, research notes,
review packets, drafts, and scratch outputs: use a single local artifact as
a periodic save point during an in-progress task. Create it once at task
start, then update it in place — checklist, evidence log, decisions — as
work progresses, so state stays resumable without replaying chat or message
history. This is the same canonical-file rule as
[Canonical Path Selection](#1-canonical-path-selection): reuse one file
across the task rather than creating a new snapshot per update.

Keep the local artifact canonical and current, including after preparing or
sharing a human-facing copy. Delivery does not replace the task record.

## 8. Suggested Artifact Shape

Keep artifacts compact but resumable:

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

For resume, record the current branch, dirty/clean status, last completed
action, next action, blockers, and validation still required.

## 9. Human-Facing Markdown

Make the document concise, scannable, and sufficiently explanatory. Lead with
the main conclusion, then include necessary context, evidence, and action
items. Preserve critical reasoning, constraints, and findings; adjust length
to the request and task complexity without fixed word or line limits.

Keep detailed working history in the canonical local artifact when needed.
A delivery copy can summarize that history rather than reproduce raw
operational logs or every working note verbatim. Do not proactively create
or propose a Gist merely because the requester wants readable Markdown.

Use Mermaid when a diagram materially improves understanding. Large
end-to-end diagrams are welcome for architecture or workflow context; add
smaller, focused diagrams of important parts when those close-ups help,
especially on a phone. There is no node-count limit or required number of
diagrams. Detailed authoring belongs to the separate `diagramming` skill.

GitHub's web experience can render Mermaid; do not assume GitHub Mobile can.
Keep important relationships, findings, and actions understandable from the
surrounding prose and labels even when a diagram does not render.

## 10. Recursive Team Scope Composition

Each child team's orchestrator uses the same canonical-path rules for its own
verified repo/full-branch/worktree scope. Keep the original delegated goal,
constraints, acceptance criteria, owner and exact parent request/return
references in that index. Its children can delegate again; depth does not
select another artifact convention or a special role prompt.

The parent index links child scope evidence and preserves its own original
acceptance criteria. Child detail files retain their parent reference, current
scope, owner, evidence, result and next action. Different workspaces/branches
do not share one mutable global index. Parallel tasks in one verified scope
can share its canonical index while keeping separate task/request IDs and
artifact owners. A parent is not complete merely because a child ACKed or a
mail reply obligation closed.

On restart, reuse and reconcile the same verified index and retained own mail.
Never replace it with a newly convenient file, manufacture missing progress,
apply an old result to a new request, or bypass canonical-path reconciliation.
The live Postman role contract owns delegation/review behavior; this reference
owns artifact location and composition, not a second scheduler.
