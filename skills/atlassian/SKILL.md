---
name: atlassian
license: MIT
description: |
  USE FOR: Jira and Confluence via Atlassian Cloud when env vars are present/confirmed; safely verify access and report minimal evidence. Detailed owner: github. DO NOT USE FOR: guessing credentials or exposing secrets.
---

# Atlassian

Compatibility trigger for Atlassian (Jira/Confluence) tasks. The durable
guidance now lives in `skills/github/references/atlassian.md`.

## 1. Use For

- Jira issue reads, searches, comments, transitions, or metadata via Atlassian
  Cloud when `ATLASSIAN_API_TOKEN` is confirmed present.
- Confluence page reads, searches, comments, or space queries via Atlassian
  Cloud when env vars are confirmed.
- Minimal safe evidence reporting for access checks.

## 2. Do Not Use For

- Guessing or exposing credentials.
- Tasks where Atlassian env vars are absent or unconfirmed.

## 3. Workflow

1. Inspect the relevant task context and `git status`.
2. Read `skills/github/references/atlassian.md` for safe env checks, Jira,
   Confluence, reporting, and cleanup guidance.
3. Confirm required env vars before making any authenticated request.
4. Prefer read-only checks first; summarize intended writes before executing.
5. Report access state, minimal evidence, and any blocker.

## 4. References

- `skills/github/references/atlassian.md`
- `skills/atlassian/references/api-token.md`
