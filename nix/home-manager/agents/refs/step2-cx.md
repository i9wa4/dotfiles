### Step 2: Launch 5 Codex Subagents in Parallel

```bash
for ROLE in security architecture historian "${ROLE4}" qa; do
  PROMPT_FILE=$(mkmd --dir reviews --label "prompt-${ROLE}-${LABEL}")
  OUTPUT_FILE=$(mkmd --dir reviews --label "review-${ROLE}-${LABEL}")
  cat << EOF > "$PROMPT_FILE"
reviewer-${ROLE}
git diff ${BASE}...HEAD
Context: ${CONTEXT_FILE}
EOF
  # NOTE: --sandbox workspace-write requires codex >=0.x; omit if unavailable
  # NOTE: inherits parent Codex session model (model pin removed)
  codex exec --sandbox workspace-write \
    -o "$OUTPUT_FILE" "$(cat "$PROMPT_FILE")" &
done
wait
```
