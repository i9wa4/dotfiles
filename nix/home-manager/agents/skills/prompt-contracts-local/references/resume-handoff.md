# Resume-Oriented Handoff Patterns

Use these patterns for long-running agent tasks, follow-up turns on the same
thread, or result summaries that another agent may need to resume later.

This repo already saves lightweight handoff context through:

- `nix/home-manager/agents/scripts/codex-stop-save.sh`
- `nix/home-manager/agents/scripts/codex-sessionstart-reload.sh`

Write results so those saved summaries stay readable and useful on reload.

## Handoff Rules

- If an agent thread ID is known, surface it explicitly.
- If no thread ID is known, do not invent one.
- Record the smallest useful next action, not a long recap.
- Keep verification evidence close to the result so a resumed run can tell what
  is already proven.
- Prefer delta prompts for resume turns. Do not restate the full original task
  unless the direction changed materially.

## Recommended Result Fields

- current task
- status
- blockers
- next action
- verification
- resume command, when a thread ID is known

## Example Result Shape

```text
current task: tighten the review output contract for worker-side review runs
status: local skill added and repo diff verified
blockers: none
next action: rebuild home-manager when ready to publish the skill to live homes
verification: git diff --check clean; skill files present under nix/home-manager/agents/skills/prompt-contracts-local
resume command: resume the saved thread context when supported
```

## Example Resume Delta Prompt

```xml
<task>
Resume the previous agent thread for this repo and continue from the verified
state below.
</task>

<compact_output_contract>
Return only: current status, remaining work, verification performed, and next
action.
</compact_output_contract>

<default_follow_through_policy>
Continue from the saved state unless a newly discovered blocker changes
correctness or safety.
</default_follow_through_policy>

<grounding_rules>
Base the update on the saved handoff, current repo state, and any fresh tool
output from this run.
</grounding_rules>
```

## What Not To Carry Over From The Plugin

- Do not assume plugin-owned broker state
- Do not assume slash commands or plugin environment variables
- Do not assume Claude-specific command frontmatter or `AskUserQuestion`
