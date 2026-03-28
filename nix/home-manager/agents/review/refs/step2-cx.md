### Step 2: Launch 5 Codex Subagents in Parallel

```bash
if [ "$(uname -s)" = "Linux" ]; then
  FALLBACK_LABEL="cc"
  if ! PREFLIGHT_OUTPUT=$(codex sandbox linux -- /bin/true 2>&1); then
    PREFLIGHT_FILE=$(mkmd --dir reviews --label "sandbox-preflight-${LABEL}")
    {
      printf '%s\n' "$PREFLIGHT_OUTPUT"
      printf '\n'
      printf 'HALT: Codex Linux sandbox preflight failed before reviewer fan-out.\n'
      printf 'Fallback on this host: use %s instead.\n' "$FALLBACK_LABEL"
    } > "$PREFLIGHT_FILE"
    echo "HALT: Codex Linux sandbox preflight failed. See $PREFLIGHT_FILE"
    exit 1
  fi
fi

for ROLE in security architecture historian "${ROLE4}" qa; do
  PROMPT_FILE=$(mkmd --dir reviews --label "prompt-${ROLE}-${LABEL}")
  OUTPUT_FILE=$(mkmd --dir reviews --label "review-${ROLE}-${LABEL}")
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
    -o "$OUTPUT_FILE" "$(cat "$PROMPT_FILE")" &
done
wait
```

If the Linux sandbox preflight fails: stop immediately, report BLOCKED with the
`sandbox-preflight-${LABEL}` artifact path, and do NOT launch or retry the 5
Codex reviewers in this run.
