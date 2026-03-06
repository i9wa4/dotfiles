# Bash Rules

## 1. General Command Usage

- NEVER: Do not use the `rm` command (denied in settings.json)
- YOU MUST: Use `mv /tmp/` when you need to delete files

## 2. Bash Tool Syntax Restrictions

The Bash tool has syntax limitations. Keep these in mind.

### 2.1. Basic Rules

- NEVER: Do not use subshells `()` (causes parse error)
- YOU MUST: Use braces `{ }` to group multiple commands
- YOU MUST: Wrap pipe `|` commands in braces `{ }` when redirecting

### 2.2. Command Splitting Rules

- YOU MUST: Split complex operations across multiple Bash tool calls
- YOU MUST: Avoid complex command chains with variable assignments
- NEVER: Do not cram complex `jq` filters with variable assignments in one line

### 2.3. Good Example (Command Splitting)

```sh
# First Bash tool call - create file and run command
FILE=$(mkoutput --dir tmp --label output)
gh issue view 1 --json title,body > "$FILE"

# Second Bash tool call (separate invocation)
jq -r '.title' "$FILE"
```

### 2.4. Bad Example (Causes Parse Error)

```sh
# Overly complex one-liner with variable assignments
FILE=$(mkoutput --dir tmp --label issue) && gh issue view 1 --json title > "$FILE" && TITLE=$(jq -r '.title' "$FILE") && echo "$TITLE"
```

### 2.5. Brace Group Examples

Good example (wrap pipes in braces when redirecting)

```sh
FILE=$(mkoutput --dir tmp --label output) && { git branch -r | grep issue; } > "$FILE" 2>&1 && cat "$FILE"
```

Bad example (causes parse error - missing braces around pipe)

```sh
FILE=$(mkoutput --dir tmp --label output) && git branch -r | grep issue > "$FILE" 2>&1 && cat "$FILE"
```

Bad example (subshell not allowed)

```sh
FILE=$(mkoutput --dir tmp --label output) && (for i in 1 2 3; do echo "$i"; done) > "$FILE" 2>&1
```

### 2.6. HEREDOC Usage

- YOU MUST: Use HEREDOC (`cat << 'EOF'`) for multi-line file creation
- IMPORTANT: HEREDOC works correctly

```sh
cat > /path/to/file.md << 'EOF'
# Title

Content here
EOF
```
