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

### 4.1. Determine Org Membership

Before posting issue/PR/discussion URLs, check if the referenced repo's
org matches the current repo's org AND the user is a member:

```sh
gh api user/memberships/orgs --jq '.[].organization.login'
```

### 4.2. Same Org (User is a Member) -- Bare URLs OK

If the URL points to a repo in the same org as the current repo
and the user belongs to that org, bare issue/PR/discussion URLs are allowed.

- OK: `https://github.com/my-org/other-repo/issues/123`
- OK: `https://github.com/my-org/other-repo/pull/456`
- OK: `my-org/other-repo#123`

### 4.3. Cross-Org or External -- Must Escape

If the URL points to a repo in a different org, escaping is required.

- NEVER: Use `owner/repo#123` format (triggers notifications)
- NEVER: Include bare external issue/PR/discussion URLs without backticks
  - NG: `https://github.com/external-org/repo/issues/123` (bare, triggers mention)
  - NG: `https://github.com/external-org/repo/pull/456` (bare, triggers mention)
  - NG: `https://github.com/external-org/repo/discussions/789` (bare, triggers mention)
- YOU MUST: For external issue/PR/discussion references, use these safe formats
  - `cf. <repo-name> issue <number>` (e.g., `cf. nix-darwin issue 149`)
  - Wrap in backticks (e.g., `` `https://github.com/nix-darwin/nix-darwin/issues/149` ``)

### 4.4. Always OK (No Escaping Needed)

Regardless of org, these URL types do not trigger mentions:

- `https://github.com/owner/repo` (root URL)
- `https://github.com/owner/repo/blob/...` (file link)
- `https://github.com/owner/repo/tree/...` (directory link)

## 5. Commit Message Rules

### 5.1. Basic Rules

- YOU MUST: Start work by understanding commits added to the branch
- YOU MUST: Check recent commits and match language (English or Japanese)
- IMPORTANT: Commits should help resume work easily (granularity for resumption)
- IMPORTANT: Include changes, problem resolution, technical details

### 5.2. Prohibited Content (Commits, PRs, Issues)

Applies to: commit messages, PR descriptions, Issue comments

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
