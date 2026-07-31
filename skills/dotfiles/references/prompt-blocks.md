# Prompt Blocks

Use these blocks selectively when composing prompts for agents in this repo.

Wrap each block in the XML tag shown in its heading.

## 1. `task`

Use in nearly every prompt.

```xml
<task>
Describe the concrete job, the relevant repository or failure context, and the
expected end state.
</task>
```

## 2. `structured_output_contract`

Use when the response shape matters.

```xml
<structured_output_contract>
Return exactly the requested output shape and nothing else.
Keep the answer compact.
Put findings, decisions, or blockers first.
</structured_output_contract>
```

## 3. `compact_output_contract`

Use when concise prose is enough.

```xml
<compact_output_contract>
Keep the answer compact and structured.
Do not add scene-setting, repeated recap, or filler.
</compact_output_contract>
```

## 4. `default_follow_through_policy`

Use when the agent should keep going without routine questions.

```xml
<default_follow_through_policy>
Default to the most reasonable low-risk interpretation and keep going.
Only stop when a missing detail changes correctness, safety, or an
irreversible action.
</default_follow_through_policy>
```

## 5. `completeness_contract`

Use for implementation, debugging, or any task that should not stop early.

```xml
<completeness_contract>
Resolve the task fully before stopping.
Do not stop at the first plausible answer.
Check for follow-on fixes, edge cases, or cleanup needed for a correct result.
</completeness_contract>
```

## 6. `verification_loop`

Use when correctness matters.

```xml
<verification_loop>
Before finalizing, verify the result against the task requirements and the
changed files or tool outputs.
If a check fails, revise the answer instead of reporting the first draft.
</verification_loop>
```

## 7. `missing_context_gating`

Use when guessing would hurt quality.

```xml
<missing_context_gating>
Do not guess missing repository facts.
If required context is absent, retrieve it with tools or state exactly what
remains unknown.
</missing_context_gating>
```

## 8. `grounding_rules`

Use for review, research, or diagnosis.

```xml
<grounding_rules>
Ground every claim in the provided context or tool outputs.
Do not present inferences as facts.
If a point is a hypothesis, label it clearly.
</grounding_rules>
```

## 9. `citation_rules`

Use when source traceability matters.

```xml
<citation_rules>
Back important claims with citations or explicit references to the material
you inspected.
Prefer primary sources.
</citation_rules>
```

## 10. `action_safety`

Use for write-capable or potentially broad tasks.

```xml
<action_safety>
Keep changes tightly scoped to the stated task.
Avoid unrelated refactors, renames, or cleanup unless they are required for
correctness.
Call out any risky or irreversible action before taking it.
</action_safety>
```

## 11. `tool_persistence_rules`

Use for long-running, tool-heavy tasks.

```xml
<tool_persistence_rules>
Keep using tools until you have enough evidence to finish confidently.
Do not abandon the workflow after a partial read when another targeted check
would change the answer.
</tool_persistence_rules>
```

## 12. `research_mode`

Use for comparisons, recommendations, or exploratory work.

```xml
<research_mode>
Separate observed facts, reasoned inferences, and open questions.
Prefer breadth first, then go deeper only where the evidence changes the
recommendation.
</research_mode>
```

## 13. `dig_deeper_nudge`

Use for review and adversarial inspection.

```xml
<dig_deeper_nudge>
After you find the first plausible issue, check for second-order failures,
empty-state behavior, retries, stale state, and rollback paths before
finalizing.
</dig_deeper_nudge>
```

## 14. `decision_quality_check`

Use for research, diagnosis, recommendation, or review prompts where the agent
must reach a defensible conclusion without overstating certainty.

```xml
<decision_quality_check>
Run at least two genuinely independent checks before relying on a conclusion;
if only one is feasible, say so and lower confidence.
Do not relabel the same evidence as independent confirmation.
For consequential work, keep a cumulative finding ledger across the task:
claims and assumptions, supporting and conflicting evidence, confidence or
uncertainty, discarded alternatives, and newly discovered relevant issues.
Revisit the accumulated ledger before later decisions and self-audits. Add new
relevant findings as they emerge; mark resolved items closed only when closure
is supported by evidence.
In a review workflow, only Guardian/critic synthesis owns that authoritative
ledger. Reviewer checks are packet-local: they cannot create, close, or change
Guardian ledger IDs.
Challenge the load-bearing assumption only when a concrete alternative, failure
mode, or counterexample could change the decision.
State a direct recommendation when evidence supports one, then name material
uncertainty and what would change the conclusion.
Do not expose private chain-of-thought. For the decision-quality audit summary
only, report at most three concise bullets: lead claim, disconfirming check or
why none was feasible, and decision impact. This cap does not limit required
review findings, attestations, or task output sections.
Use neutral language: no pressure, flattery, shame, false urgency, or emotional
steering.
</decision_quality_check>
```

## 15. `progress_updates`

Use when the run may take a while.

```xml
<progress_updates>
If you provide progress updates, keep them brief and outcome-based.
Mention only major phase changes or blockers.
</progress_updates>
```
