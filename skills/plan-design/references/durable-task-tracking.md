# Durable Task Tracking

Durable task tracking is needed when work must survive chat compaction, node
handoff, review loops, or original-checklist completion gates. The artifact is
an operational record, not a replacement for source changes or tests.

Use `mkmd` as the local implementation for these artifacts.

## 1. Choosing A Directory Label

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

## 2. Creating A Tracker

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

## 3. Preserving The Original Checklist

When a user, orchestrator, or reviewer supplies a markdown path, treat that file
as the canonical original checklist:

- keep updating that file rather than creating a competing tracker;
- preserve every original checklist item, even if you add clarifying subitems;
- record any scope correction or changed interpretation under decisions;
- use the same artifact path in worker, review, handoff, DONE, and BLOCKED
  traffic.

If the task has no explicit checklist, create one from the assigned success
checks before implementation begins.

## 4. Recommended Artifact Shape

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

## 5. Progress And Evidence Logs

Log the facts another node needs to resume:

- timestamped skill reads and file inspections;
- paths created or preserved;
- edits made and why they satisfy the checklist;
- command names, exit results, and important failures;
- review defects addressed or intentionally left blocked;
- remaining next action when handing off.

Use checkboxes for milestones and verification items. Do not mark a checkbox
complete until there is evidence in the artifact or source tree.

## 6. Handoff And Resume

For handoff or compaction, add:

- active artifact path;
- current branch and dirty/clean status if source files changed;
- last completed action;
- next action;
- blockers or external waits;
- validation still required.

For resumed work, read the artifact before acting. Continue the same evidence
log rather than reconstructing history from memory.

## 7. DONE And BLOCKED Verification

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

## 8. Public Surface Hygiene

Local absolute artifact paths are fine in internal chat, mailbox traffic, and
local task artifacts. Public GitHub surfaces such as commits, issues, PRs, and
reviews should use repo-relative paths or stable URLs.

## 9. Human-Facing Japanese Secret-Gist Workflow

Use this subsection whenever an artifact is intended for human viewing. Do not
use it for machine-only build outputs, internal logs or mailbox receipts, code,
configuration, Nix sources, temporary scratch files, or other non-human output.

### 9.1. Source and language

- Write the human-facing final Markdown body in Japanese. Preserve commands,
  paths, URLs, identifiers, and versions in their exact notation when needed.
- Create the local canonical source with `mkmd`; include title, purpose, scope,
  verification evidence, and remaining work.
- Before upload, remove secrets, tokens, private data, internal mail or review
  details, and machine-local absolute paths. Use repository-relative paths or
  stable Web URLs instead.

### 9.2. Secret-Gist creation and verification

Creating, updating, or deleting an external Gist requires explicit current
human approval. After approval, confirm the intended account with
`gh auth status` and create a Secret Gist without `--public`:

```sh
gh auth status
gh gist create --filename "$(basename "$MKMD_ARTIFACT")" \
  --desc '日本語の人間向け成果物' "$MKMD_ARTIFACT"
```

Keep the `mkmd` basename, including its unique suffix, as the Gist filename;
do not rename it or overwrite an existing same-name file. A Secret Gist is not
an access-controlled secret store: anyone with its URL can read it.

Verify the Gist API reports `public=false`, the expected URL, description, and
filename; verify the page returns HTTP 200; fetch the Raw content and compare
its SHA-256 with the local source; then rescan Raw content for secrets,
machine-local paths, mailbox receipts, and other private material. Do not put
the URL in human-facing text until every check passes.

```sh
gh api gists/<gist-id> --jq '{html_url,public,description,files:(.files|keys)}'
curl -L --silent --show-error --head https://gist.github.com/<owner>/<gist-id>
curl -L --silent https://gist.githubusercontent.com/<owner>/<gist-id>/raw/<filename> > "$TMPDIR/gist-raw.md"
shasum -a 256 "$MKMD_ARTIFACT" "$TMPDIR/gist-raw.md"
rg -n '/\.local/|tmux-a2a|pop_receipt|BEGIN (RSA|OPENSSH|PRIVATE)' "$TMPDIR/gist-raw.md"
```

The Raw hash must equal the local source, the page and API checks must pass,
and the public-surface scan must find no private content. Keep existing Gists
unchanged when outside the request; on a filename collision, create a new
`mkmd` source with its unique suffix rather than overwriting a file.

### 9.3. Handoff and fallback

Postman or requester-facing Japanese handoff text must include the complete
clickable Gist URL, visibility, filename, source identifier, verification
commands and results, changed scope, and remaining blockers. Do not copy a
Secret-Gist URL into public issues, PRs, or logs without separate approval.

If creation or verification fails, keep the local `mkmd` source as the
canonical artifact and report the failure reason and next action. Never fall
back to a public Gist or upload a file containing secrets or private data.

## 10. Common Mistakes

- Creating a repo-local `plans/` or `research/` file instead of using `mkmd`.
- Creating multiple trackers after a markdown path was already supplied.
- Treating a generated plan as the original checklist and dropping user items.
- Marking DONE without evidence for every original checklist item.
- Putting local absolute paths on public GitHub surfaces.
- Copying the full tracker method into live postman routing text.
