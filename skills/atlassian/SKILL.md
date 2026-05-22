---
name: atlassian
license: MIT
description: |
  USE FOR: Jira and Confluence via Atlassian Cloud when env vars are present/confirmed; safely verify access and report minimal evidence. DO NOT USE FOR: guessing credentials or exposing secrets.
---

# Atlassian

Use this skill when a task asks to use Jira or Confluence and the environment
may already contain Atlassian credentials. Treat credentials as available only
after confirming required variables are present.

Read [Usage](references/usage.md) before authenticated Atlassian requests.

## Required Env

- `ATLASSIAN_SITE`: Atlassian Cloud site URL.
- `ATLASSIAN_EMAIL`: account email for API token auth.
- `ATLASSIAN_API_TOKEN`: Atlassian API token.
- `ATLASSIAN_CLOUD_ID`: optional for Confluence APIs that require cloud id.

Check presence, not values. Use the reference command or an equivalent that
prints only `set` or `missing`. Never print credential values, authorization
headers, cookies, or shell traces.

## Workflow

- Confirm required env vars before access. Do not infer access from a URL.
- Jira: use targeted REST calls for issues, searches, comments, transitions,
  or metadata; for access checks request minimal fields like `summary,status`.
- Confluence: use targeted REST calls for pages, search, comments, or spaces;
  request only the body representation required by the task.
- Prefer read-only checks first. For writes, confirm the exact issue or page
  and summarize the intended change before executing.

## Reporting

State whether access is readable, blocked by auth, blocked by permissions,
blocked by network, or not found. Include minimal evidence only, such as Jira
issue key/title/status or Confluence page id/title/status plus HTTP result.
