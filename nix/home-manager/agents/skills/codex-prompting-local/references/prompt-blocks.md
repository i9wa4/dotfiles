# Prompt Blocks

Use these blocks selectively when composing prompts for Codex or GPT-5.4-based
subagents in this repo.

Wrap each block in the XML tag shown in its heading.

## `task`

Use in nearly every prompt.

```xml
<task>
Describe the concrete job, the relevant repository or failure context, and the
expected end state.
</task>
```

## `structured_output_contract`

Use when the response shape matters.

```xml
<structured_output_contract>
Return exactly the requested output shape and nothing else.
Keep the answer compact.
Put findings, decisions, or blockers first.
</structured_output_contract>
```

## `compact_output_contract`

Use when concise prose is enough.

```xml
<compact_output_contract>
Keep the answer compact and structured.
Do not add scene-setting, repeated recap, or filler.
</compact_output_contract>
```

## `default_follow_through_policy`

Use when Codex should keep going without routine questions.

```xml
<default_follow_through_policy>
Default to the most reasonable low-risk interpretation and keep going.
Only stop when a missing detail changes correctness, safety, or an
irreversible action.
</default_follow_through_policy>
```

## `completeness_contract`

Use for implementation, debugging, or any task that should not stop early.

```xml
<completeness_contract>
Resolve the task fully before stopping.
Do not stop at the first plausible answer.
Check for follow-on fixes, edge cases, or cleanup needed for a correct result.
</completeness_contract>
```

## `verification_loop`

Use when correctness matters.

```xml
<verification_loop>
Before finalizing, verify the result against the task requirements and the
changed files or tool outputs.
If a check fails, revise the answer instead of reporting the first draft.
</verification_loop>
```

## `missing_context_gating`

Use when guessing would hurt quality.

```xml
<missing_context_gating>
Do not guess missing repository facts.
If required context is absent, retrieve it with tools or state exactly what
remains unknown.
</missing_context_gating>
```

## `grounding_rules`

Use for review, research, or diagnosis.

```xml
<grounding_rules>
Ground every claim in the provided context or tool outputs.
Do not present inferences as facts.
If a point is a hypothesis, label it clearly.
</grounding_rules>
```

## `citation_rules`

Use when source traceability matters.

```xml
<citation_rules>
Back important claims with citations or explicit references to the material
you inspected.
Prefer primary sources.
</citation_rules>
```

## `action_safety`

Use for write-capable or potentially broad tasks.

```xml
<action_safety>
Keep changes tightly scoped to the stated task.
Avoid unrelated refactors, renames, or cleanup unless they are required for
correctness.
Call out any risky or irreversible action before taking it.
</action_safety>
```

## `tool_persistence_rules`

Use for long-running, tool-heavy tasks.

```xml
<tool_persistence_rules>
Keep using tools until you have enough evidence to finish confidently.
Do not abandon the workflow after a partial read when another targeted check
would change the answer.
</tool_persistence_rules>
```

## `research_mode`

Use for comparisons, recommendations, or exploratory work.

```xml
<research_mode>
Separate observed facts, reasoned inferences, and open questions.
Prefer breadth first, then go deeper only where the evidence changes the
recommendation.
</research_mode>
```

## `dig_deeper_nudge`

Use for review and adversarial inspection.

```xml
<dig_deeper_nudge>
After you find the first plausible issue, check for second-order failures,
empty-state behavior, retries, stale state, and rollback paths before
finalizing.
</dig_deeper_nudge>
```

## `progress_updates`

Use when the run may take a while.

```xml
<progress_updates>
If you provide progress updates, keep them brief and outcome-based.
Mention only major phase changes or blockers.
</progress_updates>
```
