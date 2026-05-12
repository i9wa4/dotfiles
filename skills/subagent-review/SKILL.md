---
name: subagent-review
license: MIT
description: |
  USE FOR: Native reviewer subagent usage when guardian or critic needs
  bounded review or investigation help. DO NOT USE FOR:
  dispatcher fan-out, model/tier selection, implementation delegation, or
  replacing the active reviewer role's final verdict.
---

# Subagent Review

Use native reviewer subagents as focused helpers. The active role still owns
the review, evidence synthesis, and final verdict.

Normal review lane:

```text
orchestrator -> guardian -> critic -> guardian -> orchestrator
```

Guardian runs in Codex and is the first review gate. Critic runs in Claude and
is the final review gate. Guardian sends critic a compact review package, waits
for critic's final verdict, and relays that verdict to orchestrator.

## Workflow

1. Run the cheapest relevant verifier before requesting reviewer help when a
   code or config diff is present.
2. Select only the reviewer perspectives needed for the current risk:
   security, architecture, historian, code, data, QA, or technical research.
3. Use the current runtime's native subagent mechanism. Do not route through a
   generated dispatcher and do not ask for model or tier selection.
4. Give each subagent a bounded read-only request with concrete paths,
   issue/PR context, and expected output shape.
5. Synthesize the evidence yourself. Suppress unverified findings, deduplicate
   overlaps, and produce the active guardian or critic result.

## Role Rules

- Guardian may use Codex native reviewer subagents for bounded review or
  investigation.
- Guardian sends critic a review package and later relays critic's final
  verdict to orchestrator without changing the outcome.
- Critic may use Claude native reviewer subagents for bounded review or
  investigation.
- Critic sends the final review verdict to guardian, not orchestrator.
- Reviewer subagents must not implement, edit files, commit, push, or act as
  the final approval authority.
- If subagent evidence is incomplete or unavailable, the active role continues
  the review directly and reports the limitation.

## Output Contract

For each reviewer result, preserve:

- reviewer perspective
- target paths
- evidence checked
- findings with severity and confidence
- unresolved gaps

For final verdicts, use the normal guardian-mediated review surface instead of
forwarding raw subagent output.
