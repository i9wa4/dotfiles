# Bash Scripting

Use this reference for Bash scripts and shell command design in this repo.

## 1. Command Discipline

- Do not use subshells `()` where braces `{ }` are enough.
- Wrap pipe commands in braces when redirecting grouped output.
- Split complex operations across multiple shell calls.
- Prefer repo wrappers and existing scripts before adding new shell logic.
- Avoid interactive prompts in agent panes.

## 2. Hook And Permission Handling

- Do not retry denied commands silently.
- On hook or permission denial, report the denial and exact operation.
- If a shell tool stalls past the role idle boundary, suspect prompt deadlock
  before assuming the command is still doing useful work.

## 3. Example

```sh
FILE=$(mkmd --dir tmp --label output)
{ git branch -r | rg issue; } >"$FILE" 2>&1
```

## 4. Verification

- `bash -n <script>`
- `nix run nixpkgs#shellcheck -- <script>`
- Focused repo pre-commit hooks for changed files.
