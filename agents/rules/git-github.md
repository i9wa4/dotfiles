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

OK examples (output as-is):

- https://github.com/my-org/other-repo/issues/123
- https://github.com/my-org/other-repo/pull/456
- my-org/other-repo#123

### 4.3. Cross-Org or External -- Must Escape

If the URL points to a repo in a different org, escaping is required.

NG examples (bare URLs trigger mentions):

- https://github.com/external-org/repo/issues/123
- https://github.com/external-org/repo/pull/456
- external-org/repo#123

OK examples (escaped, output as-is):

- cf. nix-darwin issue 149
- `https://github.com/nix-darwin/nix-darwin/issues/149`

### 4.4. Non-GitHub URLs -- Always OK

Non-GitHub URLs never trigger mentions (output as-is):

- https://genda-inc.slack.com/archives/C070AJC0A81/p1772703119689899
- https://dbc-55810bf1-184f.cloud.databricks.com/dashboardsv3/...

### 4.5. GitHub URLs That Do Not Trigger Mentions -- Always OK

Regardless of org, these GitHub URL types do not trigger mentions (output as-is):

- https://github.com/owner/repo
- https://github.com/owner/repo/blob/main/README.md
- https://github.com/owner/repo/tree/main/src

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

## 7. PR Review Comment Rules

### 7.1. Tag Format

Every review comment MUST start with a severity tag:

| Tag      | Meaning                         | Action   |
| -------- | ------------------------------- | -------- |
| [must]   | Must fix before merge           | Fix      |
| [want]   | Strongly prefer, not blocking   | Respond  |
| [imo]    | Suggestion, take it or leave it | Optional |
| [nits]   | Minor style/readability nitpick | Optional |
| [ask]    | Question, needs clarification   | Respond  |
| [fyi]    | Informational, no action needed | None     |
| [praise] | Good code, positive feedback    | None     |

### 7.2. Comment Style

- Write in Japanese
- Be concise: describe the problem, not the fix
- Do not include Before/After code blocks
- One concern per comment
- Tone reference: match writing style from
  @~/ghq/github.com/i9wa4/i9wa4.github.io/blog/ and
  @~/ghq/github.com/i9wa4/i9wa4.github.io/zenn/
