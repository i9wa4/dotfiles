# Git and GitHub Rules

Mandatory rules for Git and GitHub operations.

## 1. Git Command Classification

### 1.1. Prohibited Commands (Never Execute)

```sh
git push                # Push
git commit --amend      # Amend (causes force push requirement)
git reset               # Reset
git merge               # Merge
git stash               # Stash
git checkout -b         # Create branch
git branch -d           # Delete branch
```

### 1.2. Permission Required (Ask Before Execute)

```sh
git add <files>         # Staging
git commit -m "msg"     # Commit
git rebase              # Rebase
```

EXCEPTION: If user explicitly requests commit (add, commit),
execute without asking.

### 1.3. Read-only Commands (Execute Freely)

```sh
git status              # Status check
git diff                # Diff check
git log                 # Log check
git branch              # Branch list
git show                # Commit details
git remote -v           # Remote check
```

## 2. GitHub CLI Rules

- YOU MUST: Use `gh` command for GitHub information retrieval
- YOU MUST: Always fetch all comments when getting Issues or PRs
- YOU MUST: Get Issue/PR body and all comments using `gh` command
- YOU MUST: When citing Issue/PR numbers, use `#` prefix (e.g., `#240`)

## 3. Issue Creation Rules

- YOU MUST: Check `.github/ISSUE_TEMPLATE/` before creating an Issue
- YOU MUST: Follow the template format if it exists

## 4. External Repository Reference Rules (Mention Prevention)

Applies to: Issues, PRs, commit messages, and all GitHub-posted text.

- NEVER: Include paths in external repo URLs (triggers notifications)
    - NG: `https://github.com/owner/repo/issues/123`
    - NG: `https://github.com/owner/repo/pull/456`
    - NG: `https://github.com/owner/repo/discussions/789`
- NEVER: Use `owner/repo#123` format (triggers notifications)
- YOU MUST: Use these formats for external repo references
    - Repository root URL only (e.g., `https://github.com/nix-darwin/nix-darwin`)
    - `cf. <repo-name> issue <number>` (e.g., `cf. nix-darwin issue 149`)
    - Wrap in backticks (e.g., `` `https://github.com/nix-darwin/nix-darwin/issues/149` ``)

## 5. Commit Message Rules

### 5.1. Basic Rules

- YOU MUST: Start work by understanding commits added to the branch
- YOU MUST: Check recent commits and match language (English or Japanese)
- IMPORTANT: Commits should help resume work easily (granularity for resumption)
- IMPORTANT: Include changes, problem resolution, technical details

### 5.2. Prohibited Content

- NEVER: Include Co-Authored-By
- NEVER: Include "Generated with [Claude Code]" or similar AI tool notices
- NEVER: Mention `.i9wa4/` files (in global `.gitignore`)
- NEVER: Mention `/tmp/` files
- NEVER: Include local file paths (e.g., `.i9wa4/xxx.md`, `/tmp/xxx.log`)

## 6. TodoWrite Integration (Claude Code)

When creating tasks with TodoWrite for permission-required Git operations,
always add (requires permission):

```text
Good example:
- [ ] Complete model changes
- [ ] Run tests for verification
- [ ] Commit changes (requires permission)
- [ ] Push to remote (requires permission)

Bad example:
- [ ] Commit changes  <- Risk of auto-execution without permission mark
```
