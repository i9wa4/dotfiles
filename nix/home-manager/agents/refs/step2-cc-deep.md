### Step 2: Launch 5 Claude Tier 1 Subagents in Parallel

Launch all 5 reviewers in a single turn using the native Agent tool.
Use this prompt template for each:

```text
reviewer-{ROLE}-cc-deep
git diff {BASE}...HEAD
Context: {CONTEXT_FILE}
```

Roles (in order):

| Priority | Role         |
| -------- | ------------ |
| 1        | security     |
| 2        | architecture |
| 3        | historian    |
| 4        | {ROLE4}      |
| 5        | qa           |

After each reviewer responds, materialize its response to disk:

```bash
OUTPUT_FILE=$(mkmd --dir reviews --label "review-${ROLE}-${LABEL}")
# Write the subagent's response to OUTPUT_FILE
```
