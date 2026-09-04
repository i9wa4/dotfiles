# Resume-Oriented Handoff Patterns

Use these patterns for long-running agent tasks, follow-up turns on the same
thread, or result summaries that another agent may need to resume later.

The current harness does not save automatic Codex stop/session-start snapshots.
Those hooks were removed on 2026-04-29 because their saved state was not a
load-bearing handoff mechanism. Keep local artifacts, repository state, and
Postman traffic as the normal handoff record.

Leave a durable artifact of your work rather than relying on chat history
alone. Do not use any human-facing delivery copy (such as a Gist) as
cross-machine agent memory or task-state storage.

## 1. Handoff Rules

- If an agent thread ID is known, surface it explicitly.
- If no thread ID is known, do not invent one.
- Record the smallest useful next action, not a long recap.
- Keep verification evidence close to the result so a resumed run can tell what
  is already proven.
- Prefer delta prompts for resume turns. Do not restate the full original task
  unless the direction changed materially.

## 2. Portable Delivery Boundary

Past guidance allowed optional portable agent Gists. That model is retired:
task state remains local, in repository state, or in Postman traffic. Gists
are only human-facing delivery copies, produced with current explicit
approval, never task memory.
