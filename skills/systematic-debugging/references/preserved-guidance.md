# Preserved Guidance

Original SKILL.md guidance before Waza compaction. Use this reference when the
concise skill needs domain-specific details.

~~~~~~~~~~~~markdown
---
name: systematic-debugging
license: MIT
description: |
  Root-cause-first debugging for unknown failures: reproducer isolation, working-pattern comparison. Use when mechanism is unclear.
---

# Systematic Debugging

Use this skill to stop guessing, gather evidence, and narrow the actual cause
before attempting a fix.

## 1. Core Defaults

- Reproduce the problem before changing code.
- Read the exact error, output, or observed behavior first.
- Change one variable at a time.
- Compare the broken path with a nearby working path when possible.
- Prefer the smallest probe that can confirm or kill one hypothesis.
- Stop after repeated failed fix attempts and re-check the mental model.

## 2. Investigation Loop

1. State the failure clearly.
   - observed behavior
   - expected behavior
   - where it happens

2. Capture the cheapest reliable reproducer.
   - failing command
   - failing test
   - exact log line
   - concrete input that triggers the problem

3. Read the relevant files in full.
   - do not patch based on a snippet alone
   - include nearby config or wrapper files when they shape the behavior

4. Check recent change surfaces.
   - `git diff`
   - recent commits
   - changed config
   - dependency or environment shifts

5. Compare with a working pattern.
   - sibling file
   - older version
   - another command path
   - similar code path that still behaves correctly

6. Form one hypothesis.
   - say what should be true if the hypothesis is correct
   - run the narrowest probe that can prove or disprove it

7. Only after the cause is credible, hand off to execution.
   - use local `tdd-tidy-first` for the smallest verified code or config change

## 3. Repo Fit

- Prefer `rg` for text and file discovery.
- Record the reproducer command and the exact output you observed.
- Use `mkmd` research artifacts when the debugging trail will span many steps
  or multiple turns.
- Prefer POSIX-compatible and repo-managed tools over ad hoc global setup.
- Do not hide uncertainty with speculative cleanup or defensive code.

## 4. Stop Conditions

Stop and reassess when any of these happen:

- three fix attempts failed
- the reproducer changed unexpectedly
- the observed behavior contradicts the current hypothesis
- the failure depends on permissions, hooks, or environment boundaries outside
  the current lane

At that point, summarize:

- what is proven
- what is still unknown
- which hypothesis failed
- what to test next

## 5. Handoff To Implementation

When the likely cause is clear, switch to `tdd-tidy-first` and keep the next
step narrow:

- add or tighten the reproducer when cheap
- make the smallest change that should fix the proven cause
- run the fastest relevant verifier
- widen verification only after the narrow slice passes
~~~~~~~~~~~~
