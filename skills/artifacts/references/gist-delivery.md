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

Verify before handing off the URL:

```sh
gh api gists/<gist-id> --jq '{html_url,public,description,files:(.files|keys)}'
curl -L --silent --show-error --head https://gist.github.com/<owner>/<gist-id>
curl -L --silent \
  https://gist.githubusercontent.com/<owner>/<gist-id>/raw/<filename> \
  > "$TMPDIR/gist-raw.md"
shasum -a 256 "$MKMD_ARTIFACT" "$TMPDIR/gist-raw.md"
rg -n '/\.local/|tmux-a2a|pop_receipt|BEGIN (RSA|OPENSSH|PRIVATE)' "$TMPDIR/gist-raw.md"
```

Required result:

- API reports `public=false`;
- URL, description, and filename match expectation;
- Gist page returns HTTP 200;
- Raw SHA-256 matches the local source;
- public-surface scan reports no private content.

If any check fails, keep the local artifact as canonical, do not hand off the
URL, and report the exact blocker. Do not fall back to a public Gist.

## 3. Handoff

Private requester-facing handoff text should include the complete Gist URL,
visibility, filename, source identifier, verification commands/results, changed
scope, and remaining blockers. Do not copy a Secret-Gist URL into public
issues, PRs, commits, reviews, or logs without separate approval.
