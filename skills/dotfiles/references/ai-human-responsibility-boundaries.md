# AI/Human Responsibility Boundaries

Use this reference when deciding where harness, postman, prompt-contract, or
skill guidance belongs. The six-stage model is a placement rule: the more
deterministic a rule is, the closer it can live to tooling or transport; the
more contextual or value-laden it is, the closer it should stay to human
approval.

## 1. Placement Rule

Keep `postman.md` small. It should carry live topology, reply flow, compact
role contracts, hard gates, and skill catalog declarations. Put reusable
workflow detail in focused skills or references. Leave design and architecture
policy changes as explicit human decisions.

## 2. Six Stages

| Stage           | Harness meaning                                                      | Primary owner                | Example                                                               |
| --------------- | -------------------------------------------------------------------- | ---------------------------- | --------------------------------------------------------------------- |
| 1. Format       | Syntax and shape checks                                              | Formatter or parser          | Markdown formatting, YAML frontmatter, Mermaid edge syntax            |
| 2. Lint         | Mechanically checkable invariants                                    | Validation scripts or CI     | Skill frontmatter validation, private-content scan, parser load tests |
| 3. Style        | Clarity, naming, compactness, prompt bloat                           | Focused skills and reviewers | Shortening verbose role prose, improving trigger descriptions         |
| 4. Logic        | Route consistency, reply gates, artifact gates, workflow correctness | Worker plus reviewer         | Verifying guardian-to-critic review is not bypassed                   |
| 5. Design       | Which source owns a rule                                             | Human-led, agent-assisted    | Choosing `postman.md` versus a skill or reference                     |
| 6. Architecture | Topology, trust model, approval policy, public-write gates           | Human-owned                  | Adding/removing role nodes, changing final or public approval gates   |

## 3. Role Guidance

- `messenger`: stage 1-2 transport and shape checks only. It should relay and
  check required completion fields, not inspect repo content or make design
  decisions.
- `orchestrator`: stage 4 coordination. It can classify, delegate, enforce
  route shape, and move work through review, but should not own stage 5-6
  choices alone.
- `worker` and `worker-alt`: stage 3-4 execution. They can inspect files, use
  focused skills, create artifacts, validate, and recommend options for stage 5
  decisions.
- `guardian` and `critic`: stage 4 review with stage 5 challenge. Guardian owns
  the final internal review verdict after considering critic's subordinate
  recommendation; neither role replaces final human-owned policy decisions.
- Human reviewer: stage 6 ownership for topology, trust model, approval policy,
  and global runtime-policy changes.

## 4. Change Checklist

Before adding or moving harness instructions, classify the rule:

1. Can a formatter/parser/tool enforce it? Put it in tooling or validation.
2. Is it a reusable workflow detail? Put it in the owning skill or reference.
3. Is it a live routing, reply, authority, or safety gate? Keep a compact rule
   in `postman.md`.
4. Is it choosing the owner surface or changing the trust model? Record options
   and require human approval before implementation.
