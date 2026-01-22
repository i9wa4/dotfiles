# Bash Rules

## 1. General Command Usage

- YOU MUST: Save command outputs to `.i9wa4/tmp/` using `touchfile.sh`
- NEVER: Do not use the `rm` command (denied in settings.json)
- YOU MUST: Use `mv .i9wa4/tmp/` when you need to delete files

Command output format:

```sh
FILE=$(${CLAUDE_CONFIG_DIR}/scripts/touchfile.sh .i9wa4/tmp --role output) && <command> > "$FILE" 2>&1 && cat "$FILE"
```

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
gh issue view 1 --json title,body > .i9wa4/tmp/issue.json

# Second Bash tool call (separate invocation)
jq -r '.title' .i9wa4/tmp/issue.json
```

### 2.4. Bad Example (Causes Parse Error)

```sh
# Overly complex one-liner
_json=".i9wa4/tmp/issue.json" && gh issue view 1 --json title > "$_json" && _title=$(jq -r '.title' "$_json") && echo "$_title"
```

### 2.5. Brace Group Examples

Good example

```sh
NOW=$(date +%Y%m%d-%H%M%S) && { for i in 1 2 3; do echo "$i"; done; } > .i9wa4/tmp/${NOW}-output.txt 2>&1 && cat .i9wa4/tmp/${NOW}-output.txt
```

```sh
NOW=$(date +%Y%m%d-%H%M%S) && { git branch -r | grep issue; } > .i9wa4/tmp/${NOW}-output.txt 2>&1 && cat .i9wa4/tmp/${NOW}-output.txt
```

Bad example (causes parse error)

```sh
NOW=$(date +%Y%m%d-%H%M%S) && (for i in 1 2 3; do echo "$i"; done) > .i9wa4/tmp/${NOW}-output.txt 2>&1 && cat .i9wa4/tmp/${NOW}-output.txt
```

```sh
NOW=$(date +%Y%m%d-%H%M%S) && git branch -r | grep issue > .i9wa4/tmp/${NOW}-output.txt 2>&1 && cat .i9wa4/tmp/${NOW}-output.txt
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
