# GitHub Rules

Mandatory rules for GitHub operations.

Git command prohibitions are enforced by `prohibited-bash-commands.nix` (SSOT).

## 1. GitHub CLI Rules

- YOU MUST: Use `gh` command for GitHub information retrieval
- YOU MUST: Always fetch all comments when getting Issues or PRs
- YOU MUST: Get Issue/PR body and all comments using `gh` command
- YOU MUST: When citing Issue/PR numbers, use `#` prefix (e.g., `#240`)

## 2. Issue Creation Rules

- YOU MUST: Check `.github/ISSUE_TEMPLATE/` before creating an Issue
- YOU MUST: Follow the template format if it exists

## 3. External Repository Reference Rules (Mention Prevention)

Applies to: Issues, PRs, commit messages, and all GitHub-posted text.

Before posting issue/PR/discussion URLs, check org membership:

```sh
gh api user/memberships/orgs --jq '.[].organization.login'
```

- Same org (user is member): bare URLs and `org/repo#123` are OK
- Cross-org or external: must escape with backticks or describe in plain text
- Non-GitHub URLs and GitHub blob/tree URLs: always safe, no escaping needed

## 4. Commit Message Rules

- YOU MUST: Check recent commits and match language (English or Japanese)
- IMPORTANT: Commits should help resume work easily (granularity for resumption)
- IMPORTANT: Include changes, problem resolution, technical details

### 4.1. Prohibited Content (Commits, PRs, Issues)

- NEVER: Include Co-Authored-By or AI tool notices
- NEVER: Mention `.i9wa4/` files, `/tmp/` files, or local file paths

## 5. TodoWrite Integration (Claude Code)

Mark permission-required operations in TodoWrite tasks:

```text
- [ ] Commit changes (requires permission)
- [ ] Push to remote (requires permission)
```

## 6. PR Review Comment Rules

### 6.1. Tag Format

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

### 6.2. Comment Style

- Write in Japanese
- Be concise: describe the problem, not the fix
- Do not include Before/After code blocks
- One concern per comment
- Tone reference: match writing style from
  @~/ghq/github.com/i9wa4/i9wa4.github.io/blog/ and
  @~/ghq/github.com/i9wa4/i9wa4.github.io/zenn/
