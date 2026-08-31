# Local Markdown Artifacts

Use local markdown artifacts when work must survive chat compaction, handoff,
review loops, or terminal DONE/BLOCKED evidence. They are operational records,
not source changes or test substitutes.

These files are AI/agent-facing working memory kept locally, not a
human-facing delivery format and not claude.ai's rendered Artifact/canvas
feature. For an approved human-facing delivery copy, see
[Secret-Gist Delivery](gist-delivery.md) instead.

## 1. Canonical Path Selection

Use this precedence:

1. A path supplied by the user, orchestrator, reviewer, or task artifact.
2. The already-active artifact recorded in the current task or handoff.
3. A discovered recent artifact that clearly matches the same repo, branch,
   task, and purpose.
4. A new artifact created with the installed artifacts `mkmd` script.

Do not create a second tracker because the current artifact is inconvenient.
Update or rename only when the requester explicitly changes the canonical path.

## 2. Work-Start And Resume Discovery

Before creating a new artifact, search the local state root for recent
candidates. Use this search root:

```sh
mkmd_root="${MKMD_BASE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/mkmd}"
```

When the current directory is inside a Git worktree, map candidates by:

- repo: remote owner and repository name, or `local/<repo-dir>` when no origin
  remote exists;
- branch: current branch with `/` rendered as `-`;
- worktree: the Git top-level directory and whether it matches the active
  checkout;
- purpose: directory label, filename label, title, task paragraph, checklist,
  and evidence log.

Use this command as the default candidate list:

```sh
find "$mkmd_root" -type f -name '*.md' -mtime -14 -print 2>/dev/null |
  sort -r
```

Inspect candidates in this order:

1. Supplied path or active artifact from the latest handoff.
2. Same repo and same branch session directory.
3. Same repo with a related branch or PR branch name.
4. Same owner/repo directory with matching task title, issue number, PR number,
   or filename label.

Reject stale candidates when the branch, task, or purpose no longer matches, or
when the evidence log says the work was completed and the current task is a new
scope. If several candidates tie, choose the one referenced by the latest
trusted message; otherwise choose the newest candidate only after inspecting
the title, task paragraph, checklist, and most recent evidence entry. When two
files are both live for the same repo and task but different purposes, keep
both and name their roles in the handoff. When two files claim the same role,
reuse the clearer or newer canonical file and record the rejected path in the
evidence log instead of merging content ad hoc.

Create a new artifact only when no candidate clearly matches the same repo,
branch, task, and purpose. Create multiple artifacts only for distinct purposes,
for example a `research` digest plus a `plans` tracker. Do not split one
original checklist across multiple canonical trackers.

## 3. Cwd-Independent Mkmd Contract

Callers must receive the installed or currently loaded artifacts skill root
before invoking `mkmd`. Relative calls such as
`skills/artifacts/scripts/mkmd`, and roots derived from the active target
repository, must not appear in reusable snippets because most repositories do
not vendor this skill tree.

Reusable callers:

```sh
: "${ARTIFACTS_SKILL_ROOT:?set ARTIFACTS_SKILL_ROOT}"
"${ARTIFACTS_SKILL_ROOT}/scripts/mkmd" --dir plans --label implement-feature-x
```

`ARTIFACTS_SKILL_ROOT` is a runtime-provided contract from the session, wrapper,
or explicit caller setup. It should point to the installed/current artifacts
skill root, not to the repository being worked on.

Dotfiles source-local maintenance is the only documented case that may derive
the root from the repository checkout:

```sh
repo_root=$(git rev-parse --show-toplevel)
ARTIFACTS_SKILL_ROOT="${repo_root}/skills/artifacts"
```

Use the absolute path returned by the script. The path is the canonical artifact
identifier for future Postman traffic and handoffs.

## 4. Creating Artifacts

Run the skill-owned script directly:

```sh
: "${ARTIFACTS_SKILL_ROOT:?set ARTIFACTS_SKILL_ROOT}"
"${ARTIFACTS_SKILL_ROOT}/scripts/mkmd" --dir plans --label implement-feature-x
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

| Label      | Use when                                                 |
| ---------- | -------------------------------------------------------- |
| `plans`    | The artifact is an execution plan or milestone tracker.  |
| `research` | The work is investigation, synthesis, or decision notes. |
| `reviews`  | The artifact records review findings or approvals.       |
| `draft`    | The artifact is temporary text for a handoff or message. |
| `tmp`      | The artifact is scratch output with low retention value. |

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

## 7. Suggested Artifact Shape

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
