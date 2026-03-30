---
name: brainstorming
description: Ambiguity-reduction workflow for requests that are not yet plan-ready or implementation-ready. Use when there are multiple plausible approaches, the task is user-facing or design-shaping, requirements are fuzzy, or Codex needs to compare 2-3 options with trade-offs before choosing a direction.
---

# Brainstorming

Use this skill to turn a fuzzy request into a concrete direction without
pretending every task needs a full design exercise.

## 1. Core Defaults

- Use this skill only when the task is genuinely ambiguous or multi-approach.
- Do not block already-clear work behind extra ideation.
- Ask at most one clarifying question at a time when interaction is needed.
- In non-interactive lanes, make the safest explicit assumption and record it.
- Produce 2-3 viable approaches with trade-offs before recommending one.
- Stop brainstorming once the direction is stable enough for planning or
  implementation.

## 2. Workflow

1. Restate the objective in plain language.
   - what success looks like
   - what must not change

2. Pull out hard constraints.
   - repo rules
   - scope limits
   - approval boundaries
   - user or lane constraints

3. Identify the real unknowns.
   - missing requirement
   - unresolved design choice
   - unclear audience or operator

4. Resolve the next blocking unknown.
   - ask one concise clarifying question when interactive
   - otherwise state the least-risk assumption you will use

5. Generate 2-3 approaches.
   For each approach, include:
   - shape of the solution
   - main benefit
   - main risk
   - why it fits or does not fit this repo

6. Recommend one approach.
   - explain why it is the best local fit
   - name the next concrete step

## 3. Repo Fit

- Use `mkmd` artifacts when the brainstorming output needs to persist as
  research or a plan input.
- Hand off to `plan-design` when the outcome is a multi-phase execution plan.
- Hand off directly to implementation when the scope is now narrow and stable.
- Do not require tracked design docs or a universal approval loop.

## 4. Good Triggers

- Multiple valid implementation shapes exist.
- The request mixes product, UX, and technical choices.
- The user asked for options, trade-offs, or a recommendation.
- The task is user-facing and failure would come from solving the wrong problem.

## 5. Bad Triggers

- The task already has a clear acceptance target.
- The next step is obviously a small mechanical change.
- The work is already in an approved plan with concrete milestones.

In those cases, skip this skill and proceed with the narrower workflow.
