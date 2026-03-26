---
name: plan-design
description: Create high-quality, executable implementation plans for complex tasks by combining source digestion, parallel worker investigations, critic+guardian+boss review gates, and beginner-friendly packaging. Use when a user needs a step-by-step plan (not immediate implementation), especially when source material is large, fragmented, or hard for newcomers to understand.
---

# Plan Design

Extend (not replace) the base `orchestrator` workflow for high-rigor plan
authoring.

Use this skill when the output is a plan artifact requiring:

- Multi-source synthesis
- Parallel investigation
- Iterative review gates
- Newcomer-safe clarity and verifiability

## 1. Relationship to Existing Skills

- Base orchestration mechanics: use `orchestrator` skill.
- Multi-perspective review mechanics: reuse `subagent-review` concepts
  selectively.
- GitHub fetch/comment commands: follow `github` rule where needed.
- Do not duplicate those skills; add only plan-design specific workflow.

## 2. Trigger Conditions

Use this skill when one or more apply:

- User asks for a migration plan, rollout plan, or execution roadmap.
- Input includes large docs, predecessor notes, or investigation artifacts.
- User asks for beginner-friendly documentation or says they cannot understand
  the current plan.
- Plan must pass explicit approval gates (critic/boss or equivalents; critic
  consults guardian internally).

## 3. Pre-Step: Overlap Check (Mandatory)

Before drafting, run the following and read the results:

1. List existing skills:
   ls ~/ghq/github.com/i9wa4/dotfiles/nix/home-manager/agents/skills/

2. Read at minimum:
   - ~/ghq/github.com/i9wa4/dotfiles/nix/home-manager/agents/skills/orchestrator/SKILL.md
   - ~/ghq/github.com/i9wa4/dotfiles/nix/home-manager/agents/review/skills/subagent-review/SKILL.md

3. Read any skill whose name suggests planning, review, or session workflow.

4. Record the overlap matrix in the research artifact:
   - Already covered by existing skills
   - New behavior unique to this plan-design session

Do not proceed until the unique delta is explicit.

## 4. Migration Gate (Mandatory for Migration Tasks)

Activate this gate when the task description contains any of:
`migrate`, `migration`, `move`, `port`, `transfer`, `subtree`.

When activated, complete all of the following before writing the main plan:

1. Identify source artifacts (required)
   - Read existing files, workflows, and configs in the source repo/directory in
     full.
   - Record exact source locations used as migration references.

2. Define feature parity target (required)
   - List exactly what must be replicated in the destination.
   - Scope to parity only: no missing items, no extra additions.

3. Separate concerns (required)
   - `Required for migration`: minimal set needed to make the source behavior
     work in the new environment.
   - `Improvements`: any enhancement beyond parity.
   - Defer all `Improvements` to a later phase.

4. Apply diff minimization constraint (required)
   - Phase 1 scope must be the smallest possible delta from source.
   - Prefer compatibility-preserving changes over ideal redesign.

5. Log deferred items (required)
   - Add all out-of-scope improvements to the Decision Log.
   - Mark each as explicitly deferred and assign a target phase/gate owner where
     possible.

## 5. 5-Step Workflow

NOTE: This workflow departs from orchestrator base behavior by dispatching
workers (Step 2) BEFORE the annotation cycle (Step 3). This is intentional for
plan authoring: workers provide raw investigation inputs that the annotation
cycle then synthesizes. This overrides orchestrator section 3.2 for plan-design
tasks only. In all other contexts, follow the base orchestrator order.

### 5.1. Step 1: Fetch Source and Build Ground Truth

1. Create a research artifact for source digestion:
   mkmd --dir research --label "plan-investigation"
   - Note: add a suffix to disambiguate if multiple plans exist in the same
     session.
   - Example: `mkmd --dir research --label "plan-investigation-dbt-merge"`
2. Read all source artifacts in full.
3. For large files, read in chunks (`offset/limit` or line ranges).
4. Extract:
   - Constraints
   - Open decisions/placeholders
   - Risk points
   - Missing prerequisites/access assumptions

Output: source digest with section references.

### 5.2. Step 2: Parallel Investigation

Dispatch worker and worker-alt in parallel with non-overlapping focus:

- worker focus:
  - Architecture correctness
  - Dependency/order integrity
  - Missing technical steps
- worker-alt focus:
  - Beginner-friendliness
  - Phase verifiability
  - Preconditions/tools/access completeness

Required response format from each worker:

- Severity buckets: `BLOCKING`, `IMPORTANT`, `MINOR`
- For each finding: section reference + missing detail + suggested addition

### 5.3. Step 3: Annotation and Synthesis

1. Aggregate both worker outputs into one review package.
2. Resolve contradictions between worker findings:
   - If worker and worker-alt disagree, prefer the more conservative (safer)
     finding.
   - Document the resolution in the Decision Log.
3. Tighten the draft:
   - Remove ambiguity
   - Ensure all commands are copy-pasteable
   - Ensure all expected outputs are specified
4. Keep a decision log for each non-obvious choice.

When synthesis is complete, proceed to Step 4 (formal review gate).
Do NOT dispatch to critic or guardian here -- that is Step 4's responsibility.

### 5.4. Step 4: Review Gate Order (Strict)

1. Send to critic. (Critic will consult guardian; orchestrator does not contact
   guardian directly.)
2. If critic rejects: revise the plan artifact, resubmit to critic. Repeat until
   critic approves (with guardian's endorsement).
   - Maximum 3 revision rounds per gate pass.
   - If consensus is not reached after 3 rounds: a. Record the disagreement in
     the Decision Log. b. Notify messenger: "BLOCKED: critic deadlock
     after 3 rounds -- human decision required." c. Do not proceed to boss until
     messenger resolves the deadlock.
3. Submit to boss only after critic approves (with guardian's endorsement).
4. If boss rejects: a. Record the rejection reason in the Decision Log. b.
   Revise the plan artifact per boss feedback. c. Return to step 1 of this gate
   (re-run critic before resubmitting to boss). d. Maximum 2 boss
   rejection rounds. e. If boss rejects a second time, notify messenger:
   "BLOCKED: plan rejected twice by boss -- escalate."
5. Do not finalize or send to messenger until boss approves.

### 5.5. Step 5: Beginner-Friendly Final Plan Packaging

This step augments the base orchestrator plan template. The sections below are
ADDITIONAL to the base template defined in the orchestrator skill. Sections
already in the base template (Purpose, Source, Context, Investigation Summary,
Acceptance Criteria, Decision Log, Risks, Test Strategy, Progress, Surprises)
must still be present. The sections listed here must also be added for
beginner-friendly plan outputs.

Additional required sections:

1. Plain-language background
2. Glossary (define all domain terms/acronyms used)
3. Prerequisites
   - tools + versions
   - auth checks
4. Access matrix
   - required permissions per phase
   - owner/escalation path
5. Phase-by-phase command blocks
   - copy-paste commands
   - expected outputs
   - explicit Definition of Done per phase
6. Decision gates
   - replace placeholders with concrete decisions or owner/date gates
7. Rollback per phase
   - trigger + steps + verification

## 6. Reusable Planner -> Worker -> Evaluator Contract

Use this contract whenever work may span multiple turns, compactions, or agent
handoffs. The goal is to keep one compact artifact that any later session can
resume without replaying the whole transcript.

### Planner responsibilities

- Define the objective in one concrete sentence.
- Name the success/acceptance criteria.
- Record the next action that should happen first on resume.
- Record known blockers or open decisions.
- List the active plan/artifact paths that later stages must reopen.
- Define the verification the worker must return.

### Worker responsibilities

- Execute only the scoped slice from the planner artifact.
- Update the artifact with the latest verification outcome.
- Update active file/artifact paths when implementation shifts.
- Replace stale blockers with current blockers or explicitly clear them.
- Leave a concrete next action for the next worker or resumed session.

### Evaluator responsibilities

- Validate the worker result against the planner objective and acceptance
  criteria.
- Check that verification evidence exists and matches the claimed outcome.
- Either accept the artifact for promotion or return a retry contract with
  concrete gaps.
- Preserve the current objective, blockers, active paths, and next action so a
  later session can resume from the evaluator output directly.

`subagent-review` is the default evaluator pattern when the output needs a
formal review gate or merged multi-reviewer judgment.

## 7. Worker Routing Strategy (Default)

- Investigation tasks: dispatch to `worker` + `worker-alt` in parallel.
- Execution (complex reasoning/design): `worker`.
- Execution (mechanical/simple): `worker-alt`.

If risk is high or ambiguity is high, run parallel and compare.

## 8. Ambiguity Escalation (Mandatory)

If any worker encounters ambiguous or unclear points while rewriting content for
a beginner audience:

1. Stop -- do NOT make assumptions and proceed.
2. Flag the ambiguity explicitly in the DONE/BLOCKED report to orchestrator.
3. Orchestrator runs the full critic + guardian + boss review cycle on the
   revised content.
4. Notify messenger of the ambiguity and the review outcome before finalizing.

This rule applies to all plan rewriting tasks, including glossary entries,
command templates, and decision gate prose.

## 9. Quality Checklist Before Approval

A plan is ready for boss review only if all are true:

- Every technical term used is defined once.
- Every phase has commands + expected outputs + done criteria.
- Prerequisites and access requirements are explicit.
- Placeholder decisions are resolved or converted into named decision gates.
- Critic approved (with guardian's endorsement).

## 10. Deliverables

- Plan file created via:
  - `mkmd --dir plans --label plan`
- Progress updates and status changes recorded in the plan.
- Final handoff summary including:
  - Key decisions
  - Unresolved gates
  - Evidence of verification outputs
