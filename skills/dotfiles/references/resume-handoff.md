# Resume-Oriented Handoff Patterns

Use these patterns for long-running agent tasks, follow-up turns on the same
thread, or result summaries that another agent may need to resume later.

The current harness does not save automatic Codex stop/session-start snapshots.
Those hooks were removed on 2026-04-29 because their saved state was not a
load-bearing handoff mechanism. Keep local `mkmd` artifacts, repository state,
and Postman traffic as the normal handoff record.

When a task must survive the workspace, machine, or agent session, an optional
secret GitHub Gist may carry a compact portable copy. This extends local
handoff; it never replaces the local artifact.

## 1. Handoff Rules

- If an agent thread ID is known, surface it explicitly.
- If no thread ID is known, do not invent one.
- Record the smallest useful next action, not a long recap.
- Keep verification evidence close to the result so a resumed run can tell what
  is already proven.
- Prefer delta prompts for resume turns. Do not restate the full original task
  unless the direction changed materially.

## 2. Optional Portable Agent Task-Memo Gists

Use a Gist only when the task memo must survive beyond the local workspace,
machine, or agent session. Stay local when a normal `mkmd` artifact and the
repository/issue state are sufficient.

- Use `1 task = 1 Gist = 1 Markdown file`.
- Keep the local task/handoff file as the canonical working copy.
- Use description identity `agent-task:<repo>:<task>`; the Gist ID and
  description identify the memo, while the filename may stay simple.
- Memo contents are compact and resume-oriented: current task, status,
  blockers, next action, verification, and relevant issue/PR/thread IDs.
- Gists are ephemeral task memory, not the knowledge base. At completion,
  promote durable knowledge into repository docs/issues, then delete the Gist
  by default.

### 2.1. Secret, authorization, and URL boundaries

Agent task-memo Gists are always secret/unlisted. Public Gists are prohibited:
never use `--public`, and do not offer a public-mode flag in an agent-facing
helper. Secret means unlisted, not access-controlled private storage; anyone
with the URL can read it.

Never store credentials, tokens, secrets, personal data, or other sensitive
material in a task memo. Before any create, edit, or delete operation, obtain
the current human approval required for that external mutation and confirm the
authenticated account with `gh auth status`. Do not mutate a Gist merely
because a task is in progress.

Do not copy a secret-Gist URL to a public issue, PR, commit, review, or log.
It may be included in the approved private handoff channel only after the
verification below succeeds. A separate current approval is required before
any broader sharing.

### 2.2. Approved mutation and read-back procedure

The following commands are examples for an already approved mutation; they are
not permission to perform one. Each creation command intentionally omits
`--public`.

```sh
gh auth status
gh gist create --desc 'agent-task:<repo>:<task>' task.md
gh gist edit <gist-id> --filename task.md task.md
gh api gists/<gist-id> --jq '{html_url,public,description,files:(.files|keys)}'
```

Verify API output reports `public=false`, the expected description, and the
expected single filename. Fetch Raw content, compare it with the local source,
and scan before sharing the URL:

```sh
gh gist view <gist-id> --raw > "$TMPDIR/agent-task-gist.md"
shasum -a 256 task.md "$TMPDIR/agent-task-gist.md"
rg -n '/\.local/|tmux-a2a|pop_receipt|BEGIN (RSA|OPENSSH|PRIVATE)' "$TMPDIR/agent-task-gist.md"
```

The hashes must match and the scan must find no private handoff or secret
material. If any check fails, keep the local artifact canonical and report the
failure through the approved private handoff channel.

### 2.3. Resume, finish, and safe cleanup

On resume, locate only secret task-memo candidates by their description and
read the identified Gist before acting:

```sh
gh gist list --secret --filter '^agent-task:<repo>:' --limit 100
```

For cleanup, first preview candidates. Filter by the expected repository,
owner/account, and an explicit age threshold before choosing any item. Deletion
is an external mutation: require current human approval and an explicit
per-Gist confirmation; never bulk-delete from a bare list.

```sh
gh gist list --secret --filter '^agent-task:<repo>:' --limit 100
read -r 'DELETE_GIST_ID?Delete this approved agent-task Gist ID: '
test -n "$DELETE_GIST_ID"
gh gist delete "$DELETE_GIST_ID"
```

Do not use `gh gist delete --yes` in an agent-facing cleanup path. Keep a
preview record and delete only the reviewed Gist after checking its description,
owner/account, and age. On task completion, delete the approved memo or
promote durable knowledge before deletion.

## 3. Recommended Result Fields

- current task
- status
- blockers
- next action
- verification
- resume command, when a thread ID is known

## 4. Example Result Shape

```text
current task: tighten the review output contract for worker-side review runs
status: local skill added and repo diff verified
blockers: none
next action: rebuild home-manager when ready to publish the skill to live homes
verification: git diff --check clean; prompt references present under skills/dotfiles/references
resume command: resume the saved thread context when supported
```

## 5. Example Resume Delta Prompt

```xml
<task>
Resume the previous agent thread for this repo and continue from the verified
state below.
</task>

<compact_output_contract>
Return only: current status, remaining work, verification performed, and next
action.
</compact_output_contract>

<default_follow_through_policy>
Continue from the saved state unless a newly discovered blocker changes
correctness or safety.
</default_follow_through_policy>

<grounding_rules>
Base the update on the saved handoff, current repo state, and any fresh tool
output from this run.
</grounding_rules>
```

## 6. What Not To Carry Over From The Plugin

- Do not assume plugin-owned broker state
- Do not assume slash commands or plugin environment variables
- Do not assume Claude-specific command frontmatter or `AskUserQuestion`
