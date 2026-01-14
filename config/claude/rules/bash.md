# Bash Rules

## 1. General Command Usage

- YOU MUST: Follow this format when executing commands

    ```sh
    NOW=$(date +%Y%m%d-%H%M%S) && echo "${NOW}" && <command> > /tmp/"${NOW}"-<filename>.txt 2>&1 && cat /tmp/"${NOW}"-<filename>.txt
    ```

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
# First Bash tool call
gh issue view 1 --json title,body > /tmp/issue.json

# Second Bash tool call (separate invocation)
jq -r '.title' /tmp/issue.json
```

### 2.4. Bad Example (Causes Parse Error)

```sh
# Overly complex one-liner
_json="/tmp/issue.json" && gh issue view 1 --json title > "$_json" && _title=$(jq -r '.title' "$_json") && echo "$_title"
```

### 2.5. Brace Group Examples

Good example

```sh
NOW=$(date +%Y%m%d-%H%M%S) && { for i in 1 2 3; do echo "$i"; done; } > /tmp/${NOW}-output.txt 2>&1 && cat /tmp/${NOW}-output.txt
```

```sh
NOW=$(date +%Y%m%d-%H%M%S) && { git branch -r | grep issue; } > /tmp/${NOW}-output.txt 2>&1 && cat /tmp/${NOW}-output.txt
```

Bad example (causes parse error)

```sh
NOW=$(date +%Y%m%d-%H%M%S) && (for i in 1 2 3; do echo "$i"; done) > /tmp/${NOW}-output.txt 2>&1 && cat /tmp/${NOW}-output.txt
```

```sh
NOW=$(date +%Y%m%d-%H%M%S) && git branch -r | grep issue > /tmp/${NOW}-output.txt 2>&1 && cat /tmp/${NOW}-output.txt
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
