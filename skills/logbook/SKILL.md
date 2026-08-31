---
name: logbook
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Non-code working artifacts: local markdown task trackers, plans,
  research notes, review packets, drafts, scratch outputs, supplied artifact
  paths, work-start/resume discovery and reuse, canonical-vs-multiple
  artifact decisions, cwd-independent mkmd invocation, and human-facing
  Secret-Gist delivery. DO NOT USE FOR: code/config changes, planning
  semantics, public publication without approval, cross-machine agent
  memory, or claude.ai's `/artifacts` feature (see `artifact-design`).
---

# Logbook

Owns non-code artifact lifecycle and delivery: where working artifacts live,
when to create or reuse them, how to discover them on resume, and how to
prepare approved human-facing Secret-Gist delivery.

A logbook entry is a local Markdown file (`mkmd`) or a Secret Gist — never
claude.ai's Artifact/canvas feature (hence this skill's name, not
`artifacts`). Route `/artifacts` questions to `artifact-design`; see
references below for `mkmd` vs. Gist.

Follow the active runtime/session language policy or explicit request. This
skill does not define its own output language defaults.

## 1. Workflow

1. If the requester supplied an artifact path, use that path as canonical.
2. If no path was supplied, use
   [Local Markdown Artifacts](references/local-markdown.md) to discover
   work-start or resume candidates before creating a file.
3. Reuse one matching active artifact for the same repo, branch, task, and
   purpose; create a separate file only for a genuinely separate purpose.
4. If durable state is needed and no path exists, create a markdown artifact
   with the cwd-independent `mkmd` contract in the local markdown reference.
5. For human-facing Secret-Gist delivery, read
   [Secret-Gist Delivery](references/gist-delivery.md) and require current
   approval before any external mutation.
6. Keep local artifacts as task state. Treat Gists as approved delivery copies,
   not task memory, source of truth, or cross-machine persistence.

## 2. References

- [Local Markdown Artifacts](references/local-markdown.md)
- [Secret-Gist Delivery](references/gist-delivery.md)
