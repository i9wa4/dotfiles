# Git Rules

## 1. Basic Rules

- YOU MUST: Start work by understanding commits added to the branch
- YOU MUST: Get permission before executing restricted Git operations
- EXCEPTION: If user requests commit (add, commit), execute without asking

## 2. Prohibited Commands (Destructive Operations)

Never execute these commands:

```sh
git push                # Push
git reset               # Reset (except noted exceptions)
git merge               # Merge
git stash               # Stash
git checkout -b         # Create branch
git branch -d           # Delete branch
```

## 3. Permission Required (Non-destructive)

Get permission before these commands:

```sh
git add <files>         # Staging
git commit -m "msg"     # Commit
git rebase              # Rebase (for commit edits etc.)
```

## 4. No Permission Needed (Read-only)

Execute freely:

```sh
git status              # Status check
git diff                # Diff check
git log                 # Log check
git branch              # Branch list
git show                # Commit details
git remote -v           # Remote check
```

## 5. Editing Commit Messages (Rebase)

To edit commit messages in a local branch using interactive rebase:

Prerequisites:

- Local branch not yet pushed
- Automate interactive operations with environment variables
- Understand that hash values will change

Steps:

```sh
# 1. Find the commit hash to edit
git log --oneline -10

# 2. Start rebase with "edit" via environment variable
GIT_SEQUENCE_EDITOR="sed -i '' 's/^pick <HASH>/edit <HASH>/'" git rebase -i <HASH>^

# 3. Edit the commit message
git commit --amend --allow-empty --no-verify -m "New message"

# 4. Continue rebase (get user permission)
git rebase --continue
```

Notes:

- Interactive rebase (`-i` flag) is allowed but must be automated
- Always get user permission before `git rebase --continue`
- Do not use on pushed commits as hash values change

## 6. (Claude Code) TodoWrite Tool Integration

When creating tasks with TodoWrite for permission-required Git operations,
always add (requires permission):

```text
- Good example
    - [ ] Complete model changes
    - [ ] Run tests for verification
    - [ ] Commit changes (requires permission)
    - [ ] Push to remote (requires permission)
- Bad example
    - [ ] Complete model changes
    - [ ] Run tests for verification
    - [ ] Commit changes <- Risk of auto-execution without permission mark
```

## 7. Commit Message Guidelines

Basic rules:

- YOU MUST: Check recent commits and match language (English or Japanese)
- IMPORTANT: Granularity for resumption: commits should help resume work easily
- IMPORTANT: Rich descriptions: include changes,
  problem resolution, technical details
- NEVER: Do not include Co-Authored-By
- NEVER: Do not include "Generated with [Claude Code]"
  or similar AI tool notices
- NEVER: Do not mention `.i9wa4/` files (in global `.gitignore`)
- NEVER: Do not mention `/tmp/` files
- NEVER: Do not include local file paths (e.g., `.i9wa4/xxx.md`, `/tmp/xxx.log`)

External Repository Reference Rules (Mention Prevention):

- NEVER: Do not include paths in external repo URLs (triggers notifications)
    - NG: `https://github.com/owner/repo/issues/123`
    - NG: `https://github.com/owner/repo/pull/456`
    - NG: `https://github.com/owner/repo/discussions/789`
- NEVER: Do not use `owner/repo#123` format (triggers notifications)
- YOU MUST: Use these formats for external repo references
    - Repository root URL only (e.g., `https://github.com/nix-darwin/nix-darwin`)
    - `cf. <repo-name> issue <number>` (e.g., `cf. nix-darwin issue 149`)
    - Wrap in backticks (e.g., `` `https://github.com/nix-darwin/nix-darwin/issues/149` ``)

Format (Conventional Commits):

```text
<type>: <brief description> (#<Issue number>)

<detailed description>

## Summary

- Same as detailed description is OK

## Background

- Briefly explain the background and purpose

## Changes

- Specific change 1
- Specific change 2

## Technical Details

- Technical implementation details
- Reasons for design decisions
- Focus on "why" throughout

## Verification

- Describe verification if performed

## Related URLs

- <Related Issue>
- <External URL>
- Others if applicable
```
