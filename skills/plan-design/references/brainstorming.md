# Brainstorming

Use this reference when a planning request is still fuzzy, has multiple viable
approaches, or could fail by solving the wrong problem. The goal is to reduce
ambiguity just enough to choose a direction, not to force every task through a
full design exercise.

## 1. Core Defaults

- Use this reference only when the task is genuinely ambiguous or
  multi-approach.
- Do not block already-clear work behind extra ideation.
- Ask at most one clarifying question at a time when interaction is required.
- In non-interactive lanes, make the safest explicit assumption and record it.
- Produce 2-3 viable approaches with trade-offs before recommending one.
- Stop brainstorming once the direction is stable enough for planning or
  implementation.

## 2. Workflow

1. Restate the objective in plain language, including what success looks like
   and what must not change.
2. Pull out hard constraints: repo rules, scope limits, approval boundaries, and
   lane constraints.
3. Identify the real unknowns: missing requirements, unresolved design choices,
   unclear audience, or unclear operator.
4. Resolve the next blocking unknown by asking one concise clarifying question
   when interactive; otherwise state the least-risk assumption.
5. Generate 2-3 approaches. For each approach, include the solution shape, main
   benefit, main risk, and why it fits or does not fit this repo.
6. Recommend one approach and name the next concrete step.

## 3. Repo Fit

- Use `mkmd` artifacts when the brainstorming output needs to persist as
  research or plan input.
- Continue into the main `plan-design` workflow when the outcome is a
  multi-phase execution plan.
- Hand off directly to implementation when the scope is now narrow and stable.
- Do not require tracked design docs or a universal approval loop for small
  settled tasks.

## 4. Good Triggers

- Multiple valid implementation shapes exist.
- The request mixes product, user experience, and technical choices.
- The user asked for options, trade-offs, or a recommendation.
- The task is user-facing and the largest risk is choosing the wrong objective.

## 5. Bad Triggers

- The task already has a clear acceptance target.
- The next step is a small mechanical change.
- The work is already in an approved plan with concrete milestones.
