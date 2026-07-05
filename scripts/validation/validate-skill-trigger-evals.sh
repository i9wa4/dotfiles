#!/usr/bin/env bash
# Runs every skill's offline trigger-accuracy eval suite (mock executor,
# deterministic trigger graders). Fails when any task fails.
# Usage: validate-skill-trigger-evals.sh [skills-root]
set -eu

WAZA="${WAZA_BIN:-waza}"
root="${1:-skills}"
fail=0

for spec in "$root"/*/evals/eval.yaml; do
  [ -f "$spec" ] || continue
  skill=$(basename "$(dirname "$(dirname "$spec")")")
  if ! "$WAZA" --no-update-check run "$spec" >/dev/null 2>&1; then
    echo "FAIL: trigger eval failed for $skill ($spec)" >&2
    "$WAZA" --no-update-check run "$spec" 2>&1 | grep -A3 'Failed Tests' >&2 || true
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  echo "FAIL: offline trigger evals detected trigger-accuracy regressions" >&2
  exit 1
fi
echo "trigger evals: OK"
