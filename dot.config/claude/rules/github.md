# GitHub Rules

## 1. Basic Rules

- YOU MUST: When citing Issue/PR numbers, use `#` prefix with spaces
  (e.g., `#240`)
- YOU MUST: Use `gh` command for GitHub information retrieval
- YOU MUST: Always fetch all comments when getting Issues or PRs with `gh`
- YOU MUST: Get Issue/PR body and all comments using `gh` command

## 2. External Repository Reference Rules (Mention Prevention)

Applies to all text posted to GitHub: Issues, PRs, commit messages, etc.

- NEVER: Do not include paths in external repo URLs (triggers notifications)
    - NG: `https://github.com/owner/repo/issues/123`
    - NG: `https://github.com/owner/repo/pull/456`
    - NG: `https://github.com/owner/repo/discussions/789`
- NEVER: Do not use `owner/repo#123` format (triggers notifications)
- YOU MUST: Use these formats for external repo references
    - Repository root URL only (e.g., `https://github.com/nix-darwin/nix-darwin`)
    - `cf. <repo-name> issue <number>` (e.g., `cf. nix-darwin issue 149`)
    - Wrap in backticks (e.g., `` `https://github.com/nix-darwin/nix-darwin/issues/149` ``)
