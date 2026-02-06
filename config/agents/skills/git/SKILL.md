---
name: git
description: |
  Git operations guide. Provides how-to for common git tasks.
  Use when:
  - Writing commit messages (Conventional Commits format)
  - Understanding git workflows
---

# Git Skill

Guide for Git operations. For mandatory rules and permissions,
see `rules/git-github.md`.

## 1. Commit Message Format (Conventional Commits)

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

### 1.1. Type Examples

| Type     | Description                  |
| -------- | ---------------------------- |
| feat     | New feature                  |
| fix      | Bug fix                      |
| docs     | Documentation only           |
| style    | Formatting, no code change   |
| refactor | Code change without fix/feat |
| test     | Adding/updating tests        |
| chore    | Maintenance, dependencies    |

## 2. Related Resources

| Resource         | Purpose                         |
| ---------------- | ------------------------------- |
| rules/git-github | Mandatory rules and permissions |
| skills/github    | GitHub-specific operations      |
