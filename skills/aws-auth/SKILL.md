---
name: aws-auth
license: MIT
description: |
  USE FOR: Cloud auth compatibility trigger for user-authenticated pane workflows. Detailed owner: data-platform. DO NOT USE FOR: agent harness runtime or generated outputs.
---

# Aws Auth

Compatibility trigger for cloud authentication workflows that must run through
a user-authenticated pane. Classification is confirmed under `data-platform`
because the guidance protects cloud/data operations from credential misuse; use
`agent-harness-engineering` only for generic tmux or pane mechanics.

The durable implementation guidance now lives in
`skills/data-platform/references/cloud-auth.md`.

## Use For

- Cloud authentication workflows where the user has already authenticated in a
  shell pane.
- Sending read-only credential confirmation commands to that pane.
- Preserving the boundary that agents do not run interactive login flows.

## Do Not Use For

- Generic tmux pane operation guidance; use `agent-harness-engineering`.
- Broad data-platform work; use `data-platform`.
- Unrelated domains, broad rewrites, or generated runtime outputs.

## Workflow

1. Inspect the relevant files, current repo conventions, and `git status`.
2. Read `skills/data-platform/references/cloud-auth.md`.
3. Make the smallest scoped change that satisfies the request.
4. Run the checks named in the preserved guidance or the nearest repo harness.
5. Report verification results and any remaining risk.

## Examples

For a request in this domain, load preserved guidance, update the relevant
source, run focused checks, and summarize the result.

## References

- `skills/data-platform/references/cloud-auth.md`

## Troubleshooting

If Waza or repo validation disagrees with preserved guidance, follow the
stricter rule and record the exception in the handoff.
