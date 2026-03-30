### Step 2: Launch 5 Codex Subagents in Parallel

```bash
LAUNCH_FAILURE_FILE=$(mkmd --dir reviews --label "launch-failures-${LABEL}")
LAUNCH_STATE_FILE=$(mkmd --dir tmp --label "launch-state-${LABEL}")
: > "$LAUNCH_FAILURE_FILE"
: > "$LAUNCH_STATE_FILE"

for ROLE in security architecture historian "${ROLE4}" qa; do
  PROMPT_FILE=$(mkmd --dir reviews --label "prompt-${ROLE}-${LABEL}")
  OUTPUT_FILE=$(mkmd --dir reviews --label "review-${ROLE}-${LABEL}")
  LAUNCH_LOG=$(mkmd --dir reviews --label "launch-${ROLE}-${LABEL}")
  # Inline the review context: the mkmd path lives outside the child
  # workspace-write sandbox, so passing only the path breaks Codex-side review.
  {
    printf 'reviewer-%s\n' "$ROLE"
    printf 'git diff %s...HEAD\n' "$BASE"
    printf 'Review context follows:\n'
    cat "$CONTEXT_FILE"
  } > "$PROMPT_FILE"
  # NOTE: --sandbox workspace-write requires codex >=0.x; omit if unavailable
  # NOTE: inherits parent Codex session model (model pin removed)
  codex exec --sandbox workspace-write \
    -o "$OUTPUT_FILE" "$(cat "$PROMPT_FILE")" > "$LAUNCH_LOG" 2>&1 &
  printf '%s\t%s\t%s\n' "$!" "$ROLE" "$LAUNCH_LOG" >> "$LAUNCH_STATE_FILE"
done

FAILED=0
while IFS="$(printf '\t')" read -r PID ROLE LAUNCH_LOG; do
  if ! wait "$PID"; then
    FAILED=1
    {
      printf 'role: %s\n' "$ROLE"
      printf 'launch log: %s\n' "$LAUNCH_LOG"
    } >> "$LAUNCH_FAILURE_FILE"
  fi
done < "$LAUNCH_STATE_FILE"

if [ "$FAILED" -ne 0 ]; then
  echo "BLOCKED: codex reviewer launch failure; see $LAUNCH_FAILURE_FILE" >&2
  exit 1
fi
```

Do not run `codex sandbox linux -- /bin/true` as a separate preflight here.
This skill already uses `codex exec --sandbox workspace-write`, and that actual
launch path is the one that must be trusted and verified on the host.

When a launch fails, persist the aggregate failure artifact
`launch-failures-${LABEL}` and the per-role `launch-${ROLE}-${LABEL}` log so
the wrapper can surface concrete evidence instead of retrying blindly.
