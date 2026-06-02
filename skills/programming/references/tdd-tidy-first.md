# TDD And Tidy First

Use this reference for small, verifiable implementation loops.

## 1. Core Defaults

- Prefer the smallest next step that can be verified quickly.
- For behavioral changes, start with a failing test or minimal reproducer when
  it is cheap to add.
- Implement only enough code to pass the new check.
- Refactor only after the behavior is verified.
- Keep structural and behavioral changes separate when practical.
- Every changed line should trace directly to the current request.
- Limit cleanup to artifacts introduced or invalidated by the current change.

## 2. Red, Green, Refactor

1. Write the smallest failing test or reproducer for the next behavior.
2. Make it pass with the minimum code change.
3. Run the fastest relevant verification for that slice.
4. Refactor for clarity or duplication only after the check passes.
5. Re-run verification after each refactor step.

## 3. Bug Fix Pattern

- Start with a failing API-level test when one is easy to add.
- If the failure is hard to isolate, add the smallest reproducer that exposes
  the defect.
- If the bug is not understood, use `systematic-debugging` before changing
  code.

## 4. Repo Fit

- Use `mkmd` plan and research artifacts when planning is needed.
- Do not run every test after every tiny edit by default; run focused checks
  during iteration and broader checks before reporting success.
