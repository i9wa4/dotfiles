# Atlassian Usage

## Safe Environment Check

Use this pattern to check variable presence without printing values:

```sh
python - <<'PY'
import os

for name in ("ATLASSIAN_SITE", "ATLASSIAN_EMAIL", "ATLASSIAN_API_TOKEN"):
    print(f"{name}={'set' if os.environ.get(name) else 'missing'}")
PY
```

Do not use commands that dump full environment values. Keep shell tracing
disabled before authenticated commands.

## Jira

- For access checks, request only the fields needed to prove readability, such
  as `summary` and `status`.
- Treat unauthenticated `404` responses as inconclusive for private projects;
  retry with confirmed credentials before reporting no access.
- Avoid copying full descriptions, comments, or attachments unless the task
  explicitly requires that content.

## Confluence

- Prefer targeted reads by page id, title, or CQL search over broad exports.
- Request only the page body representation needed for the task.
- Avoid storing page bodies in durable artifacts unless the user asked for
  extracted content.

## Cleanup

Temporary response files can contain private content. Remove them after
extracting the minimal evidence needed for the task.
