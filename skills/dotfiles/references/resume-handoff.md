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
# agent-task-gist-create-read-back
set -e
expected_account='i9wa4'
expected_description='agent-task:<repo>:<task>'
expected_filename='task.md'
task_file=${task_file:-task.md}
pending_cleanup_record=${pending_cleanup_record:-agent-task-gist-pending-cleanup.txt}
gh auth status >/dev/null
account=$(gh api user --jq .login)
test "$account" = "$expected_account"
set +e
rg -n '/\.local/|tmux-a2a|pop_receipt|BEGIN (RSA|OPENSSH|PRIVATE)' "$task_file" >/dev/null
local_scan_status=$?
set -e
if [ "$local_scan_status" -eq 0 ]; then
  exit 1
fi
if [ "$local_scan_status" -ne 1 ]; then
  exit 1
fi
gist_id=
create_log=
post_create_lifecycle=0
write_pending_cleanup() {
  reason=$1
  {
    printf 'status=pending-cleanup\n'
    printf 'reason=%s\n' "$reason"
    printf 'account=%s\n' "${account:-unknown}"
    printf 'description=%s\n' "$expected_description"
    printf 'filename=%s\n' "$expected_filename"
    if [ -n "$gist_id" ]; then
      printf 'gist_id=%s\n' "$gist_id"
    fi
  } > "$pending_cleanup_record"
}
fail_with_pending_cleanup() {
  write_pending_cleanup "$1"
  exit 1
}
cleanup_after_signal() {
  cleanup_create_log
  if [ "$post_create_lifecycle" = 1 ]; then
    write_pending_cleanup interrupted
  fi
  exit 1
}
cleanup_create_log() {
  if [ -n "$create_log" ]; then
    rm -f "$create_log"
  fi
}
trap cleanup_create_log EXIT
trap cleanup_after_signal HUP INT TERM
create_log=$(mktemp "${TMPDIR:-/tmp}/agent-task-gist-create.XXXXXX") || exit 1
post_create_lifecycle=1
if ! create_output=$(gh gist create --desc "$expected_description" "$task_file" 2>"$create_log"); then
  fail_with_pending_cleanup create-command-failed
fi
if [ -s "$create_log" ]; then
  fail_with_pending_cleanup create-stderr
fi
rm -f "$create_log"
create_log=
case "$create_output" in
https://gist.github.com/*) ;;
*) fail_with_pending_cleanup create-output-unvalidated ;;
esac
case "$create_output" in
*'
'*) fail_with_pending_cleanup create-output-unvalidated ;;
esac
gist_id=${create_output#https://gist.github.com/}
if [ "$gist_id" = "$create_output" ]; then
  fail_with_pending_cleanup create-output-unvalidated
fi
if [ "$gist_id" != "${gist_id##*/}" ]; then
  gist_id=
  fail_with_pending_cleanup create-output-unvalidated
fi
case "$gist_id" in
"" | *[!A-Za-z0-9]*)
  gist_id=
  fail_with_pending_cleanup create-output-unvalidated
  ;;
esac
if [ "$create_output" != "https://gist.github.com/$gist_id" ]; then
  gist_id=
  fail_with_pending_cleanup create-output-unvalidated
fi
create_output=
if ! gh gist edit "$gist_id" --filename "$expected_filename" "$task_file" >/dev/null; then
  fail_with_pending_cleanup metadata-edit-failed
fi
if ! gist_public=$(gh api "gists/$gist_id" --jq .public); then
  fail_with_pending_cleanup metadata-public-read
fi
if [ "$gist_public" != false ]; then
  fail_with_pending_cleanup metadata-public
fi
if ! gist_description=$(gh api "gists/$gist_id" --jq .description); then
  fail_with_pending_cleanup metadata-description-read
fi
if [ "$gist_description" != "$expected_description" ]; then
  fail_with_pending_cleanup metadata-description
fi
if ! gist_file_count=$(gh api "gists/$gist_id" --jq '.files | keys | length'); then
  fail_with_pending_cleanup metadata-file-count-read
fi
if [ "$gist_file_count" != 1 ]; then
  fail_with_pending_cleanup metadata-file-count
fi
if ! gist_filename=$(gh api "gists/$gist_id" --jq '.files | keys[0]'); then
  fail_with_pending_cleanup metadata-filename-read
fi
if [ "$gist_filename" != "$expected_filename" ]; then
  fail_with_pending_cleanup metadata-filename
fi
```

Verify API output reports `public=false`, the expected description, and the
expected single filename. Fetch Raw content into a private unique temporary
directory, compare it with the local source, and scan before retrieving or
sharing the URL:

```sh
# agent-task-gist-raw-verification
set -e
if ! type write_pending_cleanup >/dev/null 2>&1; then
  pending_cleanup_record=${pending_cleanup_record:-agent-task-gist-pending-cleanup.txt}
  write_pending_cleanup() {
    reason=$1
    {
      printf 'status=pending-cleanup\n'
      printf 'reason=%s\n' "$reason"
      printf 'account=%s\n' "${account:-unknown}"
      printf 'description=%s\n' "${expected_description:-unknown}"
      printf 'filename=%s\n' "${expected_filename:-unknown}"
      if [ -n "${gist_id:-}" ]; then
        printf 'gist_id=%s\n' "$gist_id"
      fi
    } > "$pending_cleanup_record"
  }
fi
if ! type fail_with_pending_cleanup >/dev/null 2>&1; then
  fail_with_pending_cleanup() {
    write_pending_cleanup "$1"
    exit 1
  }
fi
tmp_base=${TMPDIR:-/tmp}
umask 077
raw_dir=$(mktemp -d "$tmp_base/agent-task-gist.XXXXXX") ||
  fail_with_pending_cleanup raw-temp
cleanup_raw_dir() {
  rm -rf "$raw_dir"
}
cleanup_raw_after_signal() {
  cleanup_raw_dir
  if type cleanup_after_signal >/dev/null 2>&1; then
    cleanup_after_signal
  fi
  fail_with_pending_cleanup interrupted
}
trap cleanup_raw_dir EXIT
trap cleanup_raw_after_signal HUP INT TERM
raw_file="$raw_dir/task.md"
if ! gh gist view "$gist_id" --raw > "$raw_file"; then
  fail_with_pending_cleanup raw-fetch
fi
if ! local_hash_line=$(shasum -a 256 "$task_file"); then
  fail_with_pending_cleanup raw-local-hash
fi
local_hash=$(printf '%s\n' "$local_hash_line" | awk '{print $1}')
if [ -z "$local_hash" ]; then
  fail_with_pending_cleanup raw-local-hash
fi
if ! raw_hash_line=$(shasum -a 256 "$raw_file"); then
  fail_with_pending_cleanup raw-remote-hash
fi
raw_hash=$(printf '%s\n' "$raw_hash_line" | awk '{print $1}')
if [ -z "$raw_hash" ]; then
  fail_with_pending_cleanup raw-remote-hash
fi
printf '%s  %s\n%s  %s\n' "$local_hash" "$task_file" "$raw_hash" "$raw_file"
if [ "$local_hash" != "$raw_hash" ]; then
  fail_with_pending_cleanup raw-digest-mismatch
fi
set +e
rg -n '/\.local/|tmux-a2a|pop_receipt|BEGIN (RSA|OPENSSH|PRIVATE)' "$raw_file" >/dev/null
scan_status=$?
set -e
if [ "$scan_status" -eq 0 ]; then
  fail_with_pending_cleanup content-scan
fi
if [ "$scan_status" -ne 1 ]; then
  fail_with_pending_cleanup scanner-error
fi
```

The hashes must match and the scan must find no private handoff or secret
material. If any check fails, keep the local artifact canonical and report the
failure through the approved private handoff channel. The create command's
returned URL is private, unapproved transient state until it is normalized to
the exact Gist ID and all checks pass; it must not be logged, handed off, or
stored in cleanup records. Only after every API, identity, filename, hash, and
content check above succeeds may the secret URL be derived from the validated
ID. Do not print it: send it only through that approved private handoff
channel.

```sh
# agent-task-gist-url-handoff
set -e
secret_gist_url="https://gist.github.com/$gist_id"
test -n "$secret_gist_url"
```

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
# agent-task-gist-reviewed-preview
set -e
expected_account='i9wa4'
expected_description_prefix='agent-task:<repo>:'
reviewed_preview=${reviewed_preview:-agent-task-gist-reviewed-preview.tsv}
candidate_data=$(mktemp "${TMPDIR:-/tmp}/agent-task-gist-reviewed-candidates.XXXXXX") || exit 1
preview_data=$(mktemp "${TMPDIR:-/tmp}/agent-task-gist-reviewed-preview.XXXXXX") || exit 1
preview_proof=$(mktemp "${TMPDIR:-/tmp}/agent-task-gist-reviewed-proof.XXXXXX") || exit 1
cleanup_preview_data() {
  rm -f "$candidate_data"
  rm -f "$preview_data"
  rm -f "$preview_proof"
}
trap cleanup_preview_data EXIT HUP INT TERM
gh auth status >/dev/null
account=$(gh api user --jq .login)
test "$account" = "$expected_account"
generated_epoch=$(date +%s)
case "$generated_epoch" in
"" | *[!0-9]*) exit 1 ;;
esac
gh gist list --secret --filter '^agent-task:<repo>:' --limit 100 \
  --json id,description,owner,updatedAt \
  --jq ".[] | [.id, .owner.login, \"$account\", (((($generated_epoch) - (.updatedAt | fromdateiso8601)) / 86400) | floor), .description] | @tsv" \
  > "$candidate_data"
cp "$candidate_data" "$preview_data"
cat "$candidate_data"
if ! awk -F '	' -v prefix="$expected_description_prefix" '
  NF != 5 { exit 1 }
  $4 !~ /^[0-9]+$/ { exit 1 }
  $5 !~ "^" prefix { exit 1 }
' "$preview_data"; then
  exit 1
fi
{
  printf '# schema=agent-task-gist-reviewed-preview-v1\n'
  printf '# account=%s\n' "$account"
  printf '# generated_epoch=%s\n' "$generated_epoch"
  cat "$preview_data"
} > "$preview_proof"
preview_hash=$(shasum -a 256 "$preview_proof" | awk '{print $1}')
{
  cat "$preview_proof"
  printf '# proof_sha256=%s\n' "$preview_hash"
} > "$reviewed_preview"
```

The preview file is the reviewed authority artifact for deletion. Keep the
metadata lines and data rows intact; the deletion step rejects missing,
malformed, stale, or digest-mismatched preview files.

```sh
# agent-task-gist-delete-confirmation
set -e
expected_account='i9wa4'
expected_owner='i9wa4'
expected_description='agent-task:<repo>:<task>'
min_age_days=7
max_preview_age_seconds=3600
reviewed_preview=${reviewed_preview:-agent-task-gist-reviewed-preview.tsv}
approved_gist_id='<reviewed-gist-id>'
gh auth status >/dev/null
account=$(gh api user --jq .login)
test "$account" = "$expected_account"
test "$(awk -F = '$1 == "# schema" { print $2 }' "$reviewed_preview")" = agent-task-gist-reviewed-preview-v1
test "$(awk -F = '$1 == "# account" { print $2 }' "$reviewed_preview")" = "$expected_account"
preview_generated_epoch=$(awk -F = '$1 == "# generated_epoch" { print $2 }' "$reviewed_preview")
case "$preview_generated_epoch" in
"" | *[!0-9]*) exit 1 ;;
esac
now_epoch=${now_epoch:-$(date +%s)}
case "$now_epoch" in
"" | *[!0-9]*) exit 1 ;;
esac
test "$preview_generated_epoch" -le "$now_epoch"
test $((now_epoch - preview_generated_epoch)) -le "$max_preview_age_seconds"
expected_preview_hash=$(awk -F = '$1 == "# proof_sha256" { print $2 }' "$reviewed_preview")
case "$expected_preview_hash" in
"" | *[!A-Fa-f0-9]*) exit 1 ;;
esac
preview_data=$(mktemp "${TMPDIR:-/tmp}/agent-task-gist-reviewed-preview.XXXXXX") || exit 1
preview_proof=$(mktemp "${TMPDIR:-/tmp}/agent-task-gist-reviewed-proof.XXXXXX") || exit 1
cleanup_preview_data() {
  rm -f "$preview_data"
  rm -f "$preview_proof"
}
trap cleanup_preview_data EXIT HUP INT TERM
awk '/^#/ { next } NF { print }' "$reviewed_preview" > "$preview_data"
{
  printf '# schema=%s\n' "$(awk -F = '$1 == "# schema" { print $2 }' "$reviewed_preview")"
  printf '# account=%s\n' "$(awk -F = '$1 == "# account" { print $2 }' "$reviewed_preview")"
  printf '# generated_epoch=%s\n' "$preview_generated_epoch"
  cat "$preview_data"
} > "$preview_proof"
test "$(shasum -a 256 "$preview_proof" | awk '{print $1}')" = "$expected_preview_hash"
preview_row=$(awk -F '	' -v id="$approved_gist_id" '$1 == id { print; found = 1 } END { exit(found ? 0 : 1) }' "$preview_data")
IFS="$(printf '\t')" read -r preview_id preview_owner preview_account preview_age_days preview_description <<EOF
$preview_row
EOF
test "$preview_id" = "$approved_gist_id"
test "$preview_owner" = "$expected_owner"
test "$preview_account" = "$expected_account"
test "$preview_description" = "$expected_description"
case "$preview_age_days" in
"" | *[!0-9]*) exit 1 ;;
esac
test "$preview_age_days" -ge "$min_age_days"
printf '%s' 'Delete this approved agent-task Gist ID: '
IFS= read -r DELETE_GIST_ID
test -n "$DELETE_GIST_ID"
test "$DELETE_GIST_ID" = "$approved_gist_id"
gh gist delete "$DELETE_GIST_ID"
```

Do not use `gh gist delete --yes` in an agent-facing cleanup path. Keep a
preview record and delete only the reviewed Gist after checking its description,
owner/account, and age. `approved_gist_id` must be the exact reviewed ID and
current human approval must still cover that one deletion. On task completion,
delete the approved memo or promote durable knowledge before deletion.

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
