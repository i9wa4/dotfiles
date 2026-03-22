# Bash Rules

## 1. Bash Tool Syntax

- NEVER: Do not use subshells `()`; use braces `{ }` instead
- YOU MUST: Wrap pipe `|` commands in braces `{ }` when redirecting
- YOU MUST: Split complex operations across multiple Bash tool calls
- YOU MUST: Use HEREDOC (`cat << 'EOF'`) for multi-line file creation

Example (brace group with pipe):

```sh
FILE=$(mkmd --dir tmp --label output) && { git branch -r | grep issue; } > "$FILE" 2>&1
```
