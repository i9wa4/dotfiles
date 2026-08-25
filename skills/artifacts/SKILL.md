---
name: artifacts
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Non-code working artifacts: local markdown task trackers, plans,
  research notes, review packets, drafts, scratch outputs, supplied artifact
  paths, resume/discovery of existing artifacts, mkmd lifecycle, and
  human-facing Secret-Gist delivery. DO NOT USE FOR: code/config changes,
  planning semantics, public publication without approval, or cross-machine
  agent memory.
---

# Artifacts

Owns non-code artifact lifecycle and delivery. This skill decides where
working artifacts live, when to create or reuse them, how to discover them on
resume, and how to prepare approved human-facing Secret-Gist delivery.

Follow the active runtime/session language policy or explicit request. This
skill does not define its own output language defaults.

## 1. Workflow

1. If the requester supplied an artifact path, use that path as canonical.
2. If the task already has an active artifact, reopen and update it instead of
   creating a competing file.
3. If durable state is needed and no path exists, create a markdown artifact
   with [Local Markdown Artifacts](references/local-markdown.md).
4. For human-facing Secret-Gist delivery, read
   [Secret-Gist Delivery](references/gist-delivery.md) and require current
   approval before any external mutation.
5. Keep local artifacts as task state. Treat Gists as approved delivery copies,
   not task memory, source of truth, or cross-machine persistence.

## 2. References

- [Local Markdown Artifacts](references/local-markdown.md)
- [Secret-Gist Delivery](references/gist-delivery.md)
