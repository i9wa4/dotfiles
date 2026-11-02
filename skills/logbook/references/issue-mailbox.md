# Issue Mailbox delivery

Local Logbook artifacts remain canonical. An Issue body/comment is a selected
delivery snapshot, readable across agents and in GitHub's iOS app; notification
services remain independent. There is no bidirectional sync, active-Issue global
pointer, daily rotation or automatic upload of raw work logs.

Use this procedure for an explicitly requested Issue creation or post. Review
the selected payload and exact destination under the current human/runtime
authorization gates, including for private Issues. Existing scoped authorization
applies; use the harness's approved execution lane when required. Wrapping `gh`
does not exempt a write from those gates. Creating a local artifact or loading
this Skill performs no remote operation. Never include a private destination or
deployment details in public dotfiles, fixtures, PRs or Nix configuration.

## 1. Create an Issue

Privately create `${XDG_CONFIG_HOME:-$HOME/.config}/logbook/issue-mailbox.conf`
with one plain `owner/repo` value, for example `example-owner/example-mailbox`.
Use the actual intended repository only in that machine-local, Git-untracked
file, outside Git worktrees and `/nix/store`. Do not `source`/`eval` it or embed
it in managed Nix configuration. `XDG_CONFIG_HOME`, when set, must be absolute;
normal `gh` authentication supplies credentials. Restrict this file locally as
appropriate; its value is a destination, not an access credential.

Set `LOGBOOK_SKILL_ROOT` to the installed Skill directory, then run its adapter
from any cwd only for the requested operation:

```sh
"$LOGBOOK_SKILL_ROOT/scripts/issue-mailbox" create
```

The title is the machine's local `YYYY-MM-DD HH:mm` followed by runtime
`hostname -s`. The default body is minimal. An explicitly selected reviewed
initial body can be supplied with `--body-file /absolute/summary.md` or `-` for
stdin. The adapter returns the actual created Issue URL. Missing/invalid config,
hostname/time failures or GitHub errors fail clearly without a fallback repo.
An explicit creation request chooses a new Issue; it does not start a schedule.

## 2. Post a snapshot

Use the concrete Issue URL supplied by the requester/parent, or an explicit
`owner/repo#123`. The create-destination config is neither read nor required for
posting, and cannot override the supplied target:

```sh
"$LOGBOOK_SKILL_ROOT/scripts/issue-mailbox" post \
  --issue 'https://github.com/example-owner/example-mailbox/issues/123' \
  --body-file /absolute/reviewed-summary.md
```

The selected Markdown is passed as exact bytes through stdin to `gh`'s
`--body-file -`; quoted heredocs and fenced `mermaid` blocks are preserved.
Summarize or select the intended artifact first rather than automatically
uploading the full canonical work log. The returned comment URL must belong to
the exact supplied Issue. Keep that URL in task context and pass it to workers
when needed; this Skill does not own delegation or task routing.

There is no retry or destination substitution. A timeout, interrupt, failed
write or unexpected response can leave a remote outcome uncertain: inspect the
intended Issue before repeating. Do not infer non-delivery from lost stdout.
The adapter emits no local routing registry and never scans Issue history.

## 3. Boundaries and checks

GitHub iOS viewing and actual machine hostname/profile mapping require device
verification. Fenced Markdown/Mermaid syntax is preserved; Issue Artifact HTML
and platform rendering parity are not claimed. Existing
[Secret-Gist delivery](gist-delivery.md) remains a separate explicitly requested
delivery path with its own verification, not another canonical task store.

Run the local contract suite after changes:

```sh
python3 "$LOGBOOK_SKILL_ROOT/scripts/test-issue-mailbox.py"
```

It mocks `gh`, date and hostname, including independent machine destinations,
exact payload bytes, explicit target precedence, invalid inputs and failed or
ambiguous writes. It creates no real Issues/comments and reads no actual
machine destination configuration. The installed Skill includes the adapter,
this reference and its deterministic tests together.
