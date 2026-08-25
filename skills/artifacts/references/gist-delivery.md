# Secret-Gist Delivery

Secret Gists are human-facing delivery copies. They are not task-state storage,
cross-machine agent memory, or access-controlled secret stores. Anyone with the
URL can read them.

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

Verify in a unique temporary directory before handing off the URL:

```sh
verify_tmp=$(mktemp -d "${TMPDIR:-/tmp}/artifacts-gist.XXXXXX")
cleanup_verify_tmp() {
  rm -rf "$verify_tmp"
}
trap cleanup_verify_tmp EXIT HUP INT TERM

gh api gists/<gist-id> --jq '{html_url,public,description,files:(.files|keys)}'
curl --fail --location --silent --show-error --head \
  https://gist.github.com/<owner>/<gist-id>
curl --fail --location --silent --show-error \
  https://gist.githubusercontent.com/<owner>/<gist-id>/raw/<filename> \
  > "$verify_tmp/gist-raw.md"
cmp -s "$MKMD_ARTIFACT" "$verify_tmp/gist-raw.md"
shasum -a 256 "$MKMD_ARTIFACT" "$verify_tmp/gist-raw.md"

set +e
rg --quiet '/\.local/|tmux-a2a|pop_receipt|BEGIN (RSA|OPENSSH|PRIVATE)' \
  "$verify_tmp/gist-raw.md"
rg_status=$?
set -e
case "$rg_status" in
0) echo "private content found in Gist raw copy" >&2; exit 1 ;;
1) : ;;
*) echo "private-content scan failed with status $rg_status" >&2; exit 1 ;;
esac
```

Required result:

- API reports `public=false`;
- URL, description, and filename match expectation;
- page and raw transports return success; failed transport is a blocker;
- raw bytes match the local source with `cmp`;
- raw SHA-256 matches the local source;
- public-surface scan reports no private content;
- `rg` status `0` means prohibited content found, `1` means no match, and any
  other status is a scanner failure.

If any check fails, keep the local artifact as canonical, do not hand off the
URL, and report the exact blocker. Do not fall back to a public Gist.

When replacing an earlier Gist delivery copy, verify the replacement raw bytes
against the intended local artifact before sharing the new URL. Do not hand off
the replacement URL when the old and new filenames collide, transport fails,
the byte/hash comparison fails, or the scan status is anything except the
explicit no-match status.

## 3. Handoff

Private requester-facing handoff text should include the complete Gist URL,
visibility, filename, source identifier, verification commands/results, changed
scope, and remaining blockers. Do not copy a Secret-Gist URL into public
issues, PRs, commits, reviews, or logs without separate approval.

## 4. Contract Validator

Run the artifacts-owned contract check after editing this reference:

```sh
skills/artifacts/scripts/validate-gist-delivery-contract.sh
```

The validator uses local fixtures only. It checks unique temporary directories,
fail-closed transport, byte and hash equality, explicit `rg` status handling,
and replacement-copy failure behavior without creating or changing any Gist.
