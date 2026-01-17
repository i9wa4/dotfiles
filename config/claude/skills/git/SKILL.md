---
name: git
description: |
  Git operations guide. Provides how-to for common git tasks.
  Use when:
  - Editing commit messages via rebase
  - Writing commit messages (Conventional Commits format)
  - Understanding git workflows
---

# Git Skill

Guide for Git operations. For mandatory rules and permissions,
see `rules/git-github.md`.

## 1. Editing Commit Messages (Rebase)

Edit commit messages in a local branch using interactive rebase.

### 1.1. Prerequisites

- Local branch not yet pushed
- Automate interactive operations with environment variables
- Understand that hash values will change

### 1.2. Steps

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

### 1.3. Notes

- Interactive rebase (`-i` flag) is allowed but must be automated
- Always get user permission before `git rebase --continue`
- Do not use on pushed commits as hash values change

## 2. Commit Message Format (Conventional Commits)

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

### 2.1. Type Examples

| Type     | Description                    |
| -------- | ------------------------------ |
| feat     | New feature                    |
| fix      | Bug fix                        |
| docs     | Documentation only             |
| style    | Formatting, no code change     |
| refactor | Code change without fix/feat   |
| test     | Adding/updating tests          |
| chore    | Maintenance, dependencies      |

## 3. Related Resources

| Resource           | Purpose                        |
| ------------------ | ------------------------------ |
| rules/git-github   | Mandatory rules and permissions|
| skills/github      | GitHub-specific operations     |
