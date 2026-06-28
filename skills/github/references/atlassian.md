# Atlassian

Use this reference when a task asks to use Jira or Confluence and the
environment may already contain Atlassian credentials. Treat credentials as
available only after confirming required variables are present.

## 1. Required Env

- `ATLASSIAN_SITE`: Atlassian Cloud site URL.
- `ATLASSIAN_EMAIL`: account email for API token auth.
- `ATLASSIAN_API_TOKEN`: Atlassian API token.
- `ATLASSIAN_CLOUD_ID`: optional for Confluence APIs that require cloud id.

If `ATLASSIAN_API_TOKEN` is missing, see
`skills/atlassian/references/api-token.md`.

Check presence, not values. Use the reference command or an equivalent that
prints only `set` or `missing`. Never print credential values, authorization
headers, cookies, or shell traces.

## 2. Safe Environment Check

```sh
python - <<'PY'
import os

for name in ("ATLASSIAN_SITE", "ATLASSIAN_EMAIL", "ATLASSIAN_API_TOKEN"):
    print(f"{name}={'set' if os.environ.get(name) else 'missing'}")
PY
```

Do not use commands that dump full environment values. Keep shell tracing
disabled before authenticated commands.

## 3. Workflow

- Confirm required env vars before access. Do not infer access from a URL.
- Jira: use targeted REST calls for issues, searches, comments, transitions,
  or metadata; for access checks request minimal fields like `summary,status`.
- Confluence: use targeted REST calls for pages, search, comments, or spaces;
  request only the body representation required by the task.
- Prefer read-only checks first. For writes, confirm the exact issue or page
  and summarize the intended change before executing.

## 4. Jira

- For access checks, request only the fields needed to prove readability, such
  as `summary` and `status`.
- Treat unauthenticated `404` responses as inconclusive for private projects;
  retry with confirmed credentials before reporting no access.
- Avoid copying full descriptions, comments, or attachments unless the task
  explicitly requires that content.

## 5. Confluence

- Prefer targeted reads by page id, title, or CQL search over broad exports.
- Request only the page body representation needed for the task.
- Avoid storing page bodies in durable artifacts unless the user asked for
  extracted content.

## 6. Reporting

State whether access is readable, blocked by auth, blocked by permissions,
blocked by network, or not found. Include minimal evidence only, such as Jira
issue key/title/status or Confluence page id/title/status plus HTTP result.

## 7. Cleanup

Temporary response files can contain private content. Remove them after
extracting the minimal evidence needed for the task.
