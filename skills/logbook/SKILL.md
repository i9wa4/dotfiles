---
name: logbook
license: MIT
metadata:
  version: "1.1.0"
description: |
  USE FOR: Non-code working artifacts: local markdown task trackers, plans,
  research notes, review packets, drafts, scratch outputs, supplied artifact
  paths, work-start/resume discovery and reuse, canonical-vs-multiple
  artifact decisions, cwd-independent mkmd invocation, and readable
  human-facing Markdown delivery copies, and explicitly requested Issue Mailbox
  creation or Markdown/Mermaid posting to a concrete GitHub Issue.
  DO NOT USE FOR: generic GitHub Issue/project management, code/config changes,
  planning semantics, public publication
  without approval, cross-machine agent memory, or claude.ai's `/artifacts`
  feature (see `artifact-design`).
---

# Logbook

Owns local Markdown artifact creation, discovery, reuse, and lifecycle.

A Logbook entry is a local Markdown file (`mkmd`) and remains canonical after
delivery.

Follow the active runtime/session language policy or explicit request. This
skill does not define its own output language defaults.

## 1. Workflow

1. Before choosing a supplied, discovered or new path, read the required
   [canonical-selection procedure](references/local-markdown.md). Identify
   purpose, scope and active record. Protect verified active orchestration
   indexes; otherwise prefer requester paths for ordinary plans/research.
2. Read that reference from the installed/current Logbook root, independently
   of task cwd. An unavailable reference blocks selection.
3. Reuse the active file for the same repo, branch, task and purpose. Create a
   separate file only for a genuinely separate purpose.
4. When durable state needs a new file, use the reference's cwd-independent
   `mkmd` contract.
5. Update the canonical record as work proceeds. Apply the reference's
   readability guidance for human output; a readable-document request does
   not authorize external publication.

## 2. References

- [Local Markdown Artifacts](references/local-markdown.md)

For explicitly requested Gist delivery only, follow
[Secret-Gist Delivery](references/gist-delivery.md).

For explicitly requested Issue creation or posting to a supplied Issue, follow
[Issue Mailbox delivery](references/issue-mailbox.md). Local artifacts remain
canonical; each machine's creation destination stays private and untracked.
