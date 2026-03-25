### Step 2: Launch 5 Codex Tier 1 Subagents in Parallel

```bash
for ROLE in security architecture historian "${ROLE4}" qa; do
  PROMPT_FILE=$(mkmd --dir reviews --label "prompt-${ROLE}-${LABEL}")
  OUTPUT_FILE=$(mkmd --dir reviews --label "review-${ROLE}-${LABEL}")
  cat << EOF > "$PROMPT_FILE"
reviewer-${ROLE}-deep
git diff ${BASE}...HEAD
Context: ${CONTEXT_FILE}
EOF
  # NOTE: --sandbox workspace-write requires codex >=0.x; omit if unavailable
  codex exec --model gpt-5.4 \
    --config model_reasoning_effort=xhigh \
    --sandbox workspace-write \
    -o "$OUTPUT_FILE" "$(cat "$PROMPT_FILE")" &
done
wait
```
