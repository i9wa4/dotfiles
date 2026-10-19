# GitHub Issue mailbox

`gh-issue-mailbox` synchronizes one GitHub Issue's comments with local Markdown
files. It runs in the foreground using the current `gh` login. It needs Python
3.10 or newer and the GitHub CLI.

```sh
gh auth login
gh-issue-mailbox https://github.com/OWNER/REPO/issues/123
gh-issue-mailbox https://github.com/OWNER/REPO/issues/123 --interval 10 \
  --import-from /path/to/outgoing --export-to /path/to/delivery
```

The default interval is five seconds. Both optional directories must already
exist. Put complete UTF-8 `.md` files in `--import-from`; each source path is
imported once. External files are opened once without following symlinks and
read through that same regular-file descriptor. The import directory is
checked against its startup identity, and every path component is opened
without following symlinks. Names are read relative to one directory
descriptor per cycle. A symlinked or replaced import path stops the cycle
before importing its contents. Use a physical path rather than a symlink.
You can also put `.md` files
directly in the mailbox `outbox`.
Write via a temporary name, then rename to `.md` for immediate pickup. The
tool otherwise waits until a file is at least one second old and unchanged
during reading. Each direct `outbox` basename can be used only once for that
Issue. Use a fresh filename for every new comment, even if its body is the
same. A reused basename stays in `outbox` with an error and is never silently
archived as the earlier post.

State lives under
`${XDG_STATE_HOME:-$HOME/.local/state}/gh-issue-mailbox/OWNER/REPO/NUMBER/`:

| Directory     | Meaning                                                                                |
| ------------- | -------------------------------------------------------------------------------------- |
| `inbox/ID.md` | Canonical comment bodies, including comments posted locally                            |
| `outbox/*.md` | Comments waiting to be posted                                                          |
| `sent/ID.md`  | Confirmed locally posted comments                                                      |
| `staging/`    | Temporary files for atomic publication                                                 |
| `records/`    | Page ETags, import receipts, post intents, private claimed drafts, and export receipts |

Each cycle imports, posts and archives, fetches and mirrors, then exports.
The fetch uses conditional requests and checks every page needed to catch up
after downtime. HTTP rate limits and transient API failures cause bounded
backoff. The inbox is a cache of exact comment bodies. Missing inbox files
trigger an unconditional refetch even when a page returns 304. If a comment
body changes remotely after it was cached, the tool stops with a conflict
instead of overwriting the local file; inspect it and remove the stale inbox
file to accept the remote revision.

`--export-to` is a one time delivery directory. Every remote comment is
written there as `ID.md`, except comments with a matching `sent/ID.md`.
After successful delivery, a receipt prevents replay to the same destination
even if a consumer moves or deletes the file. A different destination has its
own receipts. Existing destination files are never overwritten.

Set `GH_ISSUE_MAILBOX_SLACK_WEBHOOK_URL` to send a notification after a
confirmed local post. Its payload contains only the new comment URL and asks
Slack to disable link and media unfurling. Notification failure does not undo
the GitHub post.

## 1. Interrupted writes

A complete outbox file is first moved into `records/claimed-posts/` under a
SHA-256 hash of its basename. Before any GitHub POST, the tool fsyncs the
claimed regular file, then its destination directory, then the public outbox
directory. This order makes the claimed bytes and name durable before the
source-name deletion is committed across a power loss. Recovery repeats the
same order before posting a claim left by an interrupted move. Only the
private claimed file is deleted during archiving; a new
file published under the same public outbox name remains untouched. The
`pending-posts/` record binds the source's device, inode, and SHA-256 before
the move. The record moves from `claiming` to `posting` only after the private
claim matches that binding. A crash in `claiming` can resume automatically if
the original file still matches and no new public file appears. A same-name
replacement, even with the same body, leaves the file and intent for manual
inspection without posting it. If an interrupted claim moved a different
file, recovery restores an independent public copy without replacing a newer
producer file; editing that public copy cannot change the retained private
claim. A public name still counts as occupied when it is a dangling symlink.
Before halting on a public collision, recovery syncs the private claim and
the affected directories again so the observed ambiguity survives a restart.

A POST may succeed even when the CLI cannot confirm its response. In
`posting`, the tool stops and retains the private claim and pending record.
Inspect the Issue for the exact body before resolving it. If the comment
exists, put its numeric ID, `html_url`, and the pending receipt's `sha256` in
the matching `records/posts/` receipt and restart. Recovery archives the
private claim only if its identity and bytes still match the pending record.
If the comment does not exist, keep a copy of the claimed draft, remove the
pending record, and queue the draft under a fresh outbox basename. Never
remove an intent merely because the CLI reported an error.

After the sent file is durable, the pending record enters `deleting` before
the private claim is removed. The `deleting` record stays as a durable
tombstone for the original basename, including after a normal POST. If a
public file appears under that basename, the tool stops and preserves the
file and tombstone for inspection. For a new comment, rename that file to a
never-used basename and restart; retain the old tombstone and confirmed
receipt. Receipt and claim filenames are SHA-256 hashes of the original
outbox basename.

An interrupted export or a preexisting destination file leaves a `reserved`
record in `records/exports/`. Inspect the target file and receipt. If delivery
occurred, change the record state to `delivered`; if it did not, remove the
reservation and restart. Retain the `destination` and `id` fields. The tool
stops instead of guessing and replaying a potentially delivered comment.

Only one process can own the mailbox for a given Issue at a time. Exit with
Ctrl-C after the final cycle.
