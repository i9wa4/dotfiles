# Secret-Gist Delivery

Secret Gists are human-facing delivery copies. They are not task-state storage,
cross-machine agent memory, or access-controlled secret stores. Anyone with the
URL can read them.

For AI/agent-facing working memory kept locally (for example, a handoff memo
to resume tomorrow's work), use
[Local Markdown Artifacts](local-markdown.md) (`mkmd`) instead. A Gist is
also not claude.ai's rendered Artifact/canvas feature.

Use this reference only when a local artifact is intended for approved human
viewing outside the local workspace.

## 1. Approval And Source

Creating, updating, deleting, or sharing a Gist URL requires explicit current
human approval. Approval for the task does not imply approval for an external
mutation.

Before upload:

- keep the local markdown artifact as canonical source;
- follow the active runtime/session output language policy or explicit request;
- remove secrets, tokens, private data, mailbox receipts, private review
  details, and machine-local absolute paths;
- use repo-relative paths or stable Web URLs where references are needed.

## 2. Create And Verify

After approval, confirm the intended account and create a Secret Gist without
`--public`:

```sh
gh auth status
gh gist create --filename "$(basename "$MKMD_ARTIFACT")" \
  --desc '<human-facing artifact description>' "$MKMD_ARTIFACT"
```

Keep the local basename, including the unique suffix, as the Gist filename.
On filename collision or wrong content, create a new local artifact or Gist
copy; do not overwrite unrelated material.

Verify with the executable operator path before handing off the URL:

```sh
export LOGBOOK_SKILL_ROOT=/absolute/path/to/logbook-skill
export MKMD_ARTIFACT=/absolute/path/to/local-artifact.md
export GIST_ID=<gist-id>
export GIST_OWNER=<owner>
export GIST_DESCRIPTION='<human-facing artifact description>'
export GIST_FILENAME="$(basename "$MKMD_ARTIFACT")"
export GIST_EXPECTED_FILES="$GIST_FILENAME"
"${LOGBOOK_SKILL_ROOT}/scripts/verify-gist-delivery"
```

Required result:

- `LOGBOOK_SKILL_ROOT` is set to the local logbook skill directory, so the
  verifier is reachable from any target repository or current working directory;
- the verifier exits nonzero unless the API reports `public=false`;
- URL, description, expected filename, and exact file set match expectation;
- page and raw transports return success; failed transport is a blocker;
- raw bytes match the local source with `cmp`;
- raw SHA-256 matches the local source;
- public-surface scan reports no private content, including machine-local
  `/Users/...` paths;
- `rg` status `0` means prohibited content found, `1` means no match, and any
  other status is a scanner failure.

If any check fails, keep the local artifact as canonical, do not hand off the
URL, and report the exact blocker. Do not fall back to a public Gist.

When replacing an earlier Gist delivery copy, verify the replacement raw bytes
against the intended local artifact before sharing the new URL. Set
`GIST_REPLACEMENT_OLD_FILENAME` to the earlier delivery filename before running
the verifier. Do not hand off the replacement URL when the old and new
filenames collide, transport fails, visibility/metadata differs, the byte/hash
comparison fails, or the scan status is anything except the explicit no-match
status.

## 3. Handoff

Private requester-facing handoff text should include the complete Gist URL,
visibility, filename, source identifier, verification commands/results, changed
scope, and remaining blockers. Do not copy a Secret-Gist URL into public
issues, PRs, commits, reviews, or logs without separate approval.

## 4. Contract Validator

Run the logbook-owned contract check after editing this reference:

```sh
skills/logbook/scripts/validate-gist-delivery-contract.sh
```

The validator uses local fixtures only. It executes the published verifier path
with mocked `gh`, `curl`, and `rg` commands. It checks unique temporary
directories, unrelated-cwd operator reachability through `LOGBOOK_SKILL_ROOT`,
absent-root failure, fail-closed transport, visibility and metadata assertions,
byte and hash equality, explicit `rg` status handling, replacement collision
failure behavior, and machine-local path detection without creating or changing
any Gist.
