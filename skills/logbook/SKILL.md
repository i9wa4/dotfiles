---
name: logbook
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Non-code working artifacts: local markdown task trackers, plans,
  research notes, review packets, drafts, scratch outputs, supplied artifact
  paths, work-start/resume discovery and reuse, canonical-vs-multiple
  artifact decisions, cwd-independent mkmd invocation, and readable
  human-facing Markdown delivery copies.
  DO NOT USE FOR: code/config changes, planning semantics, public publication
  without approval, cross-machine agent memory, or claude.ai's `/artifacts`
  feature (see `artifact-design`).
---

# Logbook

Owns local Markdown artifact creation, discovery, reuse, and lifecycle.

A logbook entry is a local Markdown file (`mkmd`). It remains the canonical
task source throughout the work, including after a delivery copy is prepared.
Route claude.ai's `/artifacts` feature to `artifact-design`.

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
5. Keep updating the canonical local artifact as task state. For human-facing
   Markdown, follow the readability guidance in the same reference. A request
   for a readable document does not authorize external publication.

## 2. References

- [Local Markdown Artifacts](references/local-markdown.md)

For explicitly requested Gist delivery only, follow
[Secret-Gist Delivery](references/gist-delivery.md).
