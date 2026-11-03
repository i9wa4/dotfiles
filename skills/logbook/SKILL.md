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

For local Markdown selection, canonical-index recovery, creation, resume and
retention, read and follow the complete installed
`tmux-a2a-postman help records`. Existing known records remain canonical; a
package upgrade never authorizes replacing or moving them. A missing topic is an
incompatible installation. The optional helper is supplied by Postman resources.

This local entry also owns personal delivery adapters, only when explicitly
requested. Issue Mailbox creation uses this machine's private configured
repository, local timestamp and hostname, and returns the actual Issue URL.
That creation destination stays private and untracked. Markdown/Mermaid posting
uses the exact supplied GitHub Issue. Read the complete applicable reference:

- [Secret-Gist delivery](references/gist-delivery.md)
- [Issue Mailbox delivery](references/issue-mailbox.md)

Keep adapters and credentials in dotfiles; local records stay canonical.
Respect publication authority and the requested language and audience.
