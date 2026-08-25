# Local Markdown Artifacts

Use local markdown artifacts when work must survive chat compaction, handoff,
review loops, or terminal DONE/BLOCKED evidence. They are operational records,
not source changes or test substitutes.

## 1. Canonical Path Selection

Use this precedence:

1. A path supplied by the user, orchestrator, reviewer, or task artifact.
2. The already-active artifact recorded in the current task or handoff.
3. A discovered recent artifact that clearly matches the same repo, branch,
   task, and purpose.
4. A new artifact created with `skills/artifacts/scripts/mkmd`.

Do not create a second tracker because the current artifact is inconvenient.
Update or rename only when the requester explicitly changes the canonical path.

## 2. Creating Artifacts

Run the skill-owned script directly:

```sh
skills/artifacts/scripts/mkmd --dir plans --label implement-feature-x
```

The script creates:

```text
$MKMD_BASE_DIR/<owner>-<repo>/YYYY-MM-DD-<branch>/<dir>/<label>-<XXXXXX>.md
```

`MKMD_BASE_DIR` defaults to `${XDG_STATE_HOME:-$HOME/.local/state}/mkmd`.
The script works inside git repositories and local directories.

Use single-component `--dir` and `--label` values with letters, numbers,
dots, underscores, and hyphens. Do not use path separators or `..`.

## 3. Directory Labels

| Label      | Use when                                                 |
| ---------- | -------------------------------------------------------- |
| `plans`    | The artifact is an execution plan or milestone tracker.  |
| `research` | The work is investigation, synthesis, or decision notes. |
| `reviews`  | The artifact records review findings or approvals.       |
| `draft`    | The artifact is temporary text for a handoff or message. |
| `tmp`      | The artifact is scratch output with low retention value. |

Prefer the narrowest label that fits. Use `tmp` only when the output can be
discarded without losing task state.

## 4. Scope And Retention

- Branch or worktree-specific artifacts should stay under the script-generated
  branch session directory.
- Repo-independent scratch belongs in `tmp`; discard it when it no longer
  carries evidence or handoff value.
- Do not create repo-local `plans/`, `research/`, or similar directories unless
  the requester supplied that repo path or the repository explicitly owns those
  artifacts.
- Local absolute paths are fine in private task artifacts and Postman traffic.
  Public GitHub surfaces should use repo-relative paths or stable URLs.

## 5. Suggested Artifact Shape

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
