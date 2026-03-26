---
name: tdd-tidy-first
description: |
  Kent Beck style workflow for code changes using small verifiable steps,
  Red-Green-Refactor, and Tidy First separation of structural versus
  behavioral changes.
  Use when:
  - Implementing or fixing code where a cheap failing test or reproducer is possible
  - Refactoring mixed changes into structural and behavioral slices
  - Choosing the smallest safe next step for a code change
---

# TDD Tidy First Skill

Use this skill to keep code changes small, verifiable, and easy to review.

## 1. Core Defaults

- Prefer the smallest next step that can be verified quickly
- For behavioral changes, start with a failing test or minimal reproducer when
  that is cheap to add
- Implement only enough code to pass the new check
- Refactor only after the behavior is verified
- Keep structural changes separate from behavioral changes when practical

## 2. Red -> Green -> Refactor

1. Write the smallest failing test or reproducer that demonstrates the next
   behavior
2. Make it pass with the minimum code change
3. Run the fastest relevant verification for that slice
4. Refactor for clarity or duplication removal only after the check passes
5. Re-run verification after each refactor step

## 3. Tidy First Split

- Structural changes: renames, extraction, moves, dependency reshaping, or
  cleanup that should not change behavior
- Behavioral changes: new features, bug fixes, changed outputs, or changed side
  effects
- When both are needed, do structural work first, verify it preserved behavior,
  then apply the behavioral change

## 4. Bug-Fix Pattern

- Start with a failing API-level test when one is easy to add
- If the failure is hard to isolate, add the smallest reproducer that exposes
  the defect clearly
- Fix the bug only after the reproducer fails for the expected reason

## 5. Repo Fit

- Do not assume a `plan.md` workflow; this repo uses `mkmd` plan and research
  artifacts when planning is needed
- Do not adopt a universal "run all tests every time" rule; run the fastest
  relevant checks during iteration, then run broader verification before
  reporting success when available
- When commits are requested and structural plus behavioral changes are both
  present, prefer separate commits or state the split explicitly
- Skip this workflow for doc-only or config-only tasks with no meaningful test
  surface
